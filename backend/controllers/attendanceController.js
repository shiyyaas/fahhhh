const Attendance = require("../models/Attendance");
const Student = require("../models/Student");
const Teacher = require("../models/Teacher");
const User = require("../models/User");
const Subject = require("../models/Subject");
const Batch = require("../models/Batch");
const Department = require("../models/Department");

const respondWithError = (res, error) => {
  console.error("Attendance API error:", error);
  const notFound = error.name === "CastError";
  return res.status(notFound ? 404 : 500).json({
    success: false,
    message: notFound ? "Resource not found" : "Internal server error"
  });
};

const findLinkedProfile = async (req, role, Model, select) => {
  const user = await User.findOne({ _id: req.user.userId, role }).select("email");
  if (!user) return null;

  const escapedEmail = user.email.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  const profiles = await Model.find({
    email: new RegExp(`^${escapedEmail}$`, "i")
  }).select(select).limit(2);
  return profiles.length === 1 ? profiles[0] : null;
};

const authorizeStudentResource = async (req, res, studentId) => {
  if (req.user.role !== "STUDENT") return true;

  const student = await findLinkedProfile(req, "STUDENT", Student, "_id");
  if (!student || String(student._id) !== String(studentId)) {
    res.status(403).json({ success: false, message: "Forbidden" });
    return false;
  }
  return true;
};

const findTeacherProfile = (req) =>
  findLinkedProfile(req, "TEACHER", Teacher, "_id departments");

const authorizeTeacherTarget = async (teacher, studentId, subjectId, batchId) => {
  const [student, subject, batch] = await Promise.all([
    Student.findById(studentId).select("batchId"),
    Subject.findOne({ _id: subjectId, teachers: teacher._id }).select("departments"),
    Batch.findById(batchId).select("department")
  ]);

  if (!student || !batch) return { notFound: true };
  if (!subject || String(student.batchId) !== String(batch._id)) return { forbidden: true };

  const authorizedDepartments = teacher.departments.filter((departmentId) =>
    subject.departments.some((subjectDepartmentId) =>
      String(subjectDepartmentId) === String(departmentId)
    )
  );
  if (authorizedDepartments.length === 0) return { forbidden: true };

  const matchingDepartment = await Department.exists({
    _id: { $in: authorizedDepartments },
    departmentName: batch.department
  });
  return matchingDepartment ? { authorized: true } : { forbidden: true };
};

// Update Attendance
exports.updateAttendance = async (req, res) => {
  try {
    const { id } = req.params;
    const teacher = await findTeacherProfile(req);
    if (!teacher) {
      return res.status(403).json({ success: false, message: "Forbidden" });
    }

    const attendance = await Attendance.findById(id);
    if (!attendance) {
      return res.status(404).json({ success: false, message: "Attendance record not found" });
    }
    if (String(attendance.teacher) !== String(teacher._id)) {
      return res.status(403).json({ success: false, message: "Forbidden" });
    }

    const student = req.body.student || attendance.student;
    const subject = req.body.subject || attendance.subject;
    const batch = req.body.batch || attendance.batch;
    const authorization = await authorizeTeacherTarget(teacher, student, subject, batch);
    if (authorization.notFound) {
      return res.status(404).json({ success: false, message: "Attendance resource not found" });
    }
    if (authorization.forbidden) {
      return res.status(403).json({ success: false, message: "Forbidden" });
    }

    attendance.status = req.body.status || attendance.status;
    attendance.date = req.body.date || attendance.date;
    attendance.student = student;
    attendance.subject = subject;
    attendance.batch = batch;
    attendance.teacher = teacher._id;
    const updated = await attendance.save();
    res.status(200).json({ success: true, attendance: updated });
  } catch (error) {
    return respondWithError(res, error);
  }
};

// Delete Attendance
exports.deleteAttendance = async (req, res) => {
  try {
    const { id } = req.params;
    const teacher = await findTeacherProfile(req);
    if (!teacher) {
      return res.status(403).json({ success: false, message: "Forbidden" });
    }

    const attendance = await Attendance.findById(id);
    if (!attendance) {
      return res.status(404).json({ success: false, message: "Attendance record not found" });
    }
    if (String(attendance.teacher) !== String(teacher._id)) {
      return res.status(403).json({ success: false, message: "Forbidden" });
    }
    const authorization = await authorizeTeacherTarget(
      teacher,
      attendance.student,
      attendance.subject,
      attendance.batch
    );
    if (authorization.notFound) {
      return res.status(404).json({ success: false, message: "Attendance resource not found" });
    }
    if (authorization.forbidden) {
      return res.status(403).json({ success: false, message: "Forbidden" });
    }

    const deleted = await Attendance.findByIdAndDelete(id);
    if (!deleted) {
      return res.status(404).json({ success: false, message: "Attendance record not found" });
    }
    res.status(200).json({ success: true, message: "Attendance deleted" });
  } catch (error) {
    return respondWithError(res, error);
  }
};

// Helper to calculate effective present count based on Late policy
const effectivePresent = (present, late, policy) => {
  if (policy === "present") return present + late; // Late counted as present
  if (policy === "partial") return present + late * 0.5; // Late counts half
  if (policy === "absent") return present; // Late ignored (treated as absent)
  return present + late;
};

// Get Student Report (aggregated)
exports.getStudentReport = async (req, res) => {
  try {
    const studentId = req.params.id;
    const latePolicy = process.env.LATE_AS || "present"; // present | partial | absent
    if (!(await authorizeStudentResource(req, res, studentId))) return;
    const student = await Student.findById(studentId).populate({
      path: "batchId",
      select: "batchName program department admissionYear currentSemester"
    });
    if (!student) {
      return res.status(404).json({ success: false, message: "Student not found" });
    }
    // Subject-wise aggregation
    const subjectAgg = await Attendance.aggregate([
      { $match: { student: student._id } },
      {
        $group: {
          _id: "$subject",
          totalClasses: { $sum: 1 },
          present: { $sum: { $cond: [{ $eq: ["$status", "Present"] }, 1, 0] } },
          late: { $sum: { $cond: [{ $eq: ["$status", "Late"] }, 1, 0] } },
          absent: { $sum: { $cond: [{ $eq: ["$status", "Absent"] }, 1, 0] } }
        }
      },
      {
        $lookup: {
          from: "subjects",
          localField: "_id",
          foreignField: "_id",
          as: "subjectInfo"
        }
      },
      { $unwind: "$subjectInfo" },
      {
        $project: {
          subjectId: "$_id",
          subjectName: "$subjectInfo.subjectName",
          totalClasses: 1,
          present: 1,
          late: 1,
          absent: 1
        }
      }
    ]);
    // Overall aggregation
    const overallAgg = await Attendance.aggregate([
      { $match: { student: student._id } },
      {
        $group: {
          _id: null,
          totalClasses: { $sum: 1 },
          present: { $sum: { $cond: [{ $eq: ["$status", "Present"] }, 1, 0] } },
          late: { $sum: { $cond: [{ $eq: ["$status", "Late"] }, 1, 0] } },
          absent: { $sum: { $cond: [{ $eq: ["$status", "Absent"] }, 1, 0] } }
        }
      }
    ]);
    const overall = overallAgg[0] || { totalClasses: 0, present: 0, late: 0, absent: 0 };
    const effective = effectivePresent(overall.present, overall.late, latePolicy);
    const overallPercentage = overall.totalClasses === 0 ? 0 : (effective / overall.totalClasses) * 100;

    // Build response
    const subjects = subjectAgg.map((s) => {
      const eff = effectivePresent(s.present, s.late, latePolicy);
      const perc = s.totalClasses === 0 ? 0 : (eff / s.totalClasses) * 100;
      return {
        subjectId: s.subjectId,
        subjectName: s.subjectName,
        totalClasses: s.totalClasses,
        present: s.present,
        late: s.late,
        absent: s.absent,
        attendancePercentage: perc.toFixed(2)
      };
    });

    res.status(200).json({
      success: true,
      student: {
        _id: student._id,
        studentName: student.studentName,
        registerNo: student.registerNo,
        department: student.department,
        batch: student.batchId,
        email: student.email,
        phoneNo: student.phoneNo
      },
      overall: {
        totalClasses: overall.totalClasses,
        present: overall.present,
        late: overall.late,
        absent: overall.absent,
        attendancePercentage: overallPercentage.toFixed(2)
      },
      subjects
    });
  } catch (error) {
    return respondWithError(res, error);
  }
};

// Existing functions ... (unchanged)
exports.markAttendance = async (req, res) => {
    try {

        const {
            student,
            subject,
            batch,
            status,
            date
        } = req.body;

        if (!student || !subject || !batch || !status) {
            return res.status(400).json({ success: false, message: "Student, subject, batch and status are required" });
        }

        const teacherProfile = await findTeacherProfile(req);
        if (!teacherProfile) {
            return res.status(403).json({ success: false, message: "Forbidden" });
        }
        const authorization = await authorizeTeacherTarget(teacherProfile, student, subject, batch);
        if (authorization.notFound) {
            return res.status(404).json({ success: false, message: "Attendance resource not found" });
        }
        if (authorization.forbidden) {
            return res.status(403).json({ success: false, message: "Forbidden" });
        }

        const targetDate = date ? new Date(date) : new Date();
        if (Number.isNaN(targetDate.getTime())) {
            return res.status(400).json({ success: false, message: "Invalid attendance date" });
        }
        const startOfDay = new Date(targetDate);
        startOfDay.setHours(0, 0, 0, 0);
        const endOfDay = new Date(targetDate);
        endOfDay.setHours(23, 59, 59, 999);

        const attendance = await Attendance.findOneAndUpdate(
            {
                student,
                subject,
                batch,
                date: { $gte: startOfDay, $lte: endOfDay }
            },
            {
                student,
                subject,
                teacher: teacherProfile._id,
                batch,
                status,
                date: targetDate
            },
            { new: true, upsert: true, setDefaultsOnInsert: true }
        );

        res.status(200).json({
            success: true,
            message: "Attendance marked successfully",
            attendance
        });

    } catch (error) {

        return respondWithError(res, error);

    }
};

// Get Student Attendance
exports.getStudentAttendance = async (req, res) => {
    try {
        if (!(await authorizeStudentResource(req, res, req.params.id))) return;

        const attendance =
            await Attendance.find({
                student: req.params.id
            })
               .populate({
                    path: "student",
                   select: "studentName registerNo department batchId"
                })
                .populate({
                    path: "teacher",
                   select: "teacherName employeeId"
                })
               .populate({ path: "subject", select: "subjectName subjectCode semester" })
               .populate({ path: "batch", select: "batchName department program" });

        res.status(200).json({
            success: true,
            attendance
        });

    } catch (error) {

        return respondWithError(res, error);

    }
};
// Get List (<75%) 
exports.getDefaulters = async (req, res) => {
    try {

        const Student = require("../models/Student");
        const latePolicy = process.env.LATE_AS || "present";

        const students = await Student.find();

        const defaulters = [];

        for (const student of students) {

            const presentClasses =
                await Attendance.countDocuments({
                    student: student._id,
                    status: "Present"
                });

            const lateClasses =
                await Attendance.countDocuments({
                    student: student._id,
                    status: "Late"
                });

            const absentClasses =
                await Attendance.countDocuments({
                    student: student._id,
                    status: "Absent"
                });

            const totalClasses = presentClasses + lateClasses + absentClasses;
            const percentage =
                totalClasses === 0
                    ? 0
                    : (effectivePresent(presentClasses, lateClasses, latePolicy) / totalClasses) * 100;

            if (percentage < 75) {
                defaulters.push({
                    studentId: student._id,
                    studentName: student.studentName,
                    registerNo: student.registerNo,
                    attendancePercentage:
                        percentage.toFixed(2)
                });
            }
        }

        res.status(200).json({
            success: true,
            totalDefaulters: defaulters.length,
            defaulters
        });

    } catch (error) {
        return respondWithError(res, error);
    }
};
// Attendance Percentage
exports.getAttendancePercentage = async (req, res) => {
    try {

        const studentId = req.params.studentId;
        if (!(await authorizeStudentResource(req, res, studentId))) return;
        const latePolicy = process.env.LATE_AS || "present";

        const presentClasses =
            await Attendance.countDocuments({
                student: studentId,
                status: "Present"
            });

        const lateClasses =
            await Attendance.countDocuments({
                student: studentId,
                status: "Late"
            });

        const absentClasses =
            await Attendance.countDocuments({
                student: studentId,
                status: "Absent"
            });

        const totalClasses = presentClasses + lateClasses + absentClasses;
        const attendancePercentage =
            totalClasses === 0
                ? 0
                : ((effectivePresent(presentClasses, lateClasses, latePolicy) / totalClasses) * 100).toFixed(2);

        res.status(200).json({
            success: true,
            totalClasses,
            presentClasses,
            lateClasses,
            absentClasses,
            attendancePercentage
        });

    } catch (error) {

        return respondWithError(res, error);

    }
};

//   Batch Attendance
exports.getBatchAttendance = async (req, res) => {
    try {

        const attendance =
            await Attendance.find({
                batch: req.params.id
            })
                .populate({ path: "student", select: "studentName registerNo department batchId" })
                .populate({ path: "subject", select: "subjectName subjectCode semester" })
                .populate({ path: "teacher", select: "teacherName employeeId" })
                .populate({ path: "batch", select: "batchName department program" });

        res.status(200).json({
            success: true,
            attendance
        });

    } catch (error) {

        return respondWithError(res, error);

    }
};

// Get Subject Attendance
exports.getSubjectAttendance = async (req, res) => {
    try {
        let query = { subject: req.params.id };

        if (req.user.role === "TEACHER") {
            const teacher = await findTeacherProfile(req);
            if (!teacher) {
                return res.status(403).json({ success: false, message: "Forbidden" });
            }
            const subject = await Subject.findOne({
                _id: req.params.id,
                teachers: teacher._id
            }).select("departments");
            if (!subject) {
                return res.status(403).json({ success: false, message: "Forbidden" });
            }

            const authorizedDepartments = teacher.departments.filter((departmentId) =>
                subject.departments.some((subjectDepartmentId) =>
                    String(subjectDepartmentId) === String(departmentId)
                )
            );
            if (authorizedDepartments.length === 0) {
                return res.status(403).json({ success: false, message: "Forbidden" });
            }
            const departments = await Department.find({
                _id: { $in: authorizedDepartments }
            }).select("departmentName");
            const batches = await Batch.find({
                department: { $in: departments.map((department) => department.departmentName) }
            }).select("_id");
            query.batch = { $in: batches.map((batch) => batch._id) };
        }

        const attendance =
            await Attendance.find(query)
                .populate({ path: "student", select: "studentName registerNo department batchId" })
                .populate({ path: "subject", select: "subjectName subjectCode semester" })
                .populate({ path: "teacher", select: "teacherName employeeId" })
                .populate({ path: "batch", select: "batchName department program" });

        res.status(200).json({
            success: true,
            attendance
        });

    } catch (error) {

        return respondWithError(res, error);

    }
};