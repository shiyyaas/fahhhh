
const mongoose = require("mongoose");
const Timetable = require("../models/Timetable");
const User = require("../models/User");
const Department = require("../models/Department");
const Batch = require("../models/Batch");
const Subject = require("../models/Subject");
const Teacher = require("../models/Teacher");

const DAYS = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday"
];

const timetablePopulation = [
    { path: "batch", select: "batchName department program currentSemester" },
    { path: "subject", select: "subjectName subjectCode semester" },
    { path: "teacher", select: "teacherName employeeId avatar" }
];

const populateTimetable = (query) =>
    query.populate(timetablePopulation);

// Validate required fields and time range.
const validateTimetableData = (data) => {
    const {
        batch,
        subject,
        teacher,
        day,
        startTime,
        endTime, 
    } = data;

    if (!batch || !subject || !teacher || !day ||
        !startTime || !endTime ) {
        return "All timetable fields are required";
    }

    if (!DAYS.includes(day)) {
        return "Invalid timetable day";
    }

    const timePattern = /^([01]\d|2[0-3]):[0-5]\d$/;

    if (!timePattern.test(startTime) || !timePattern.test(endTime)) {
        return "Time must use HH:mm format";
    }

    if (startTime >= endTime) {
        return "End time must be later than start time";
    }

    for (const id of [batch, subject, teacher]) {
        if (!mongoose.Types.ObjectId.isValid(id)) {
            return "Invalid batch, subject, or teacher ID";
        }
    }

    return null;
};

// Prevent overlapping entries for the same batch, teacher, or room.
const findScheduleConflict = async (data, excludeId = null) => {
    const query = {
        day: data.day,
        isActive: true,
        startTime: { $lt: data.endTime },
        endTime: { $gt: data.startTime },
        $or: [
            { batch: data.batch },
            { teacher: data.teacher}
        ]
    };

    if (excludeId) {
        query._id = { $ne: excludeId };
    }

    const conflict = await Timetable.findOne(query);

    if (!conflict) return null;

    if (conflict.batch.toString() === data.batch.toString()) {
        return "This batch already has a class during this time";
    }

    if (conflict.teacher.toString() === data.teacher.toString()) {
        return "This teacher is already assigned during this time";
    }
 

    return "Timetable conflict detected";
};

const isHodTimetableAssignmentAuthorized = async (req, data) => {
    const user = await User.findById(req.user.userId)
        .select("role department");
    const department = user && user.role === "HOD" && user.department
        ? await Department.findOne({ departmentName: user.department }).select("_id")
        : null;
    if (!department) return false;

    const [batch, subject, teacher] = await Promise.all([
        Batch.findOne({ _id: data.batch, department: user.department }).select("_id"),
        Subject.findOne({
            _id: data.subject,
            departments: department._id,
            teachers: data.teacher
        }).select("_id"),
        Teacher.findOne({
            _id: data.teacher,
            departments: department._id
        }).select("_id")
    ]);
    return Boolean(batch && subject && teacher);
};

// CREATE timetable entry
exports.createTimetable = async (req, res) => {
    try {
        const validationError = validateTimetableData(req.body);

        if (validationError) {
            return res.status(400).json({
                success: false,
                message: validationError
            });
        }
        if (!await isHodTimetableAssignmentAuthorized(req, req.body)) {
            return res.status(403).json({
                success: false,
                message: "Forbidden"
            });
        }

        const conflict = await findScheduleConflict(req.body);

        if (conflict) {
            return res.status(409).json({
                success: false,
                message: conflict
            });
        }

        const timetable = await Timetable.create({
            batch: req.body.batch,
            subject: req.body.subject,
            teacher: req.body.teacher,
            day: req.body.day,
            startTime: req.body.startTime,
            endTime: req.body.endTime, 
        });

        await populateTimetable(
            Timetable.findById(timetable._id)
        );

        return res.status(201).json({
            success: true,
            message: "Timetable entry created",
            timetable
        });
    } catch (error) {
        console.error("Create timetable request failed");

        return res.status(500).json({
            success: false,
            message: "Internal server error"
        });
    }
};

// GET all timetable entries
exports.getTimetable = async (req, res) => {
    try {
        const user = await User.findById(req.user.userId)
            .select("role department");
        const department = user && user.role === "HOD" && user.department
            ? await Department.findOne({ departmentName: user.department }).select("_id")
            : null;
        if (!department) {
            return res.status(403).json({
                success: false,
                message: "Forbidden"
            });
        }
        const batchIds = await Batch.find({ department: user.department }).distinct("_id");
        const timetable = await populateTimetable(
            Timetable.find({ batch: { $in: batchIds } }).sort({ day: 1, startTime: 1 })
        );

        return res.status(200).json({
            success: true,
            timetable
        });
    } catch (error) {
        return res.status(500).json({
            success: false,
            message: "Internal server error"
        });
    }
};

// GET timetable by batch
exports.getBatchTimetable = async (req, res) => {
    try {
        const timetable = await populateTimetable(
            Timetable.find({ batch: req.params.id })
        );

        return res.status(200).json({
            success: true,
            timetable
        });
    } catch (error) {
        return res.status(500).json({
            success: false,
            message: "Internal server error"
        });
    }
};

// GET timetable by teacher
exports.getTeacherTimetable = async (req, res) => {
    try {
        const timetable = await populateTimetable(
            Timetable.find({ teacher: req.params.id })
        );

        return res.status(200).json({
            success: true,
            timetable
        });
    } catch (error) {
        return res.status(500).json({
            success: false,
            message: "Internal server error"
        });
    }
};

// UPDATE timetable entry
exports.updateTimetable = async (req, res) => {
    try {
        if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
            return res.status(400).json({
                success: false,
                message: "Invalid timetable ID"
            });
        }

        const validationError = validateTimetableData(req.body);

        if (validationError) {
            return res.status(400).json({
                success: false,
                message: validationError
            });
        }
        if (!await isHodTimetableAssignmentAuthorized(req, req.body)) {
            return res.status(403).json({
                success: false,
                message: "Forbidden"
            });
        }

        const existing = await Timetable.findById(req.params.id);

        if (!existing) {
            return res.status(404).json({
                success: false,
                message: "Timetable not found"
            });
        }
        if (!await isHodTimetableAssignmentAuthorized(req, existing)) {
            return res.status(403).json({
                success: false,
                message: "Forbidden"
            });
        }

        const conflict = await findScheduleConflict(
            req.body,
            req.params.id
        );

        if (conflict) {
            return res.status(409).json({
                success: false,
                message: conflict
            });
        }

        existing.batch = req.body.batch;
        existing.subject = req.body.subject;
        existing.teacher = req.body.teacher;
        existing.day = req.body.day;
        existing.startTime = req.body.startTime;
        existing.endTime = req.body.endTime; 

        await existing.save();
        await existing.populate(timetablePopulation);

        return res.status(200).json({
            success: true,
            message: "Timetable updated successfully",
            timetable: existing
        });
    } catch (error) {
        console.error("Update timetable request failed");

        return res.status(500).json({
            success: false,
            message: "Internal server error"
        });
    }
};

// DELETE timetable entry
exports.deleteTimetable = async (req, res) => {
    try {
        if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
            return res.status(400).json({
                success: false,
                message: "Invalid timetable ID"
            });
        }

        const existing = await Timetable.findById(req.params.id);

        if (!existing) {
            return res.status(404).json({
                success: false,
                message: "Timetable not found"
            });
        }
        if (!await isHodTimetableAssignmentAuthorized(req, existing)) {
            return res.status(403).json({
                success: false,
                message: "Forbidden"
            });
        }
        await existing.deleteOne();

        return res.status(200).json({
            success: true,
            message: "Timetable deleted"
        });
    } catch (error) {
        return res.status(500).json({
            success: false,
            message: "Internal server error"
        });
    }
};
