
const mongoose = require("mongoose");
const Timetable = require("../models/Timetable");

const DAYS = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday"
];

const populateTimetable = (query) =>
    query
        .populate("batch")
        .populate("subject")
        .populate("teacher");

// Validate required fields and time range.
const validateTimetableData = (data) => {
    const {
        batch,
        subject,
        teacher,
        day,
        startTime,
        endTime,
        roomNo
    } = data;

    if (!batch || !subject || !teacher || !day ||
        !startTime || !endTime || !roomNo?.trim()) {
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
            { teacher: data.teacher },
            { roomNo: data.roomNo.trim() }
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

    if (conflict.roomNo.trim() === data.roomNo.trim()) {
        return "This room is already booked during this time";
    }

    return "Timetable conflict detected";
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
            roomNo: req.body.roomNo.trim()
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
        console.error("Create timetable error:", error);

        return res.status(500).json({
            success: false,
            message: error.message
        });
    }
};

// GET all timetable entries
exports.getTimetable = async (req, res) => {
    try {
        const timetable = await populateTimetable(
            Timetable.find().sort({ day: 1, startTime: 1 })
        );

        return res.status(200).json({
            success: true,
            timetable
        });
    } catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message
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
            message: error.message
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
            message: error.message
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

        const existing = await Timetable.findById(req.params.id);

        if (!existing) {
            return res.status(404).json({
                success: false,
                message: "Timetable not found"
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
        existing.roomNo = req.body.roomNo.trim();

        await existing.save();
        await existing.populate(["batch", "subject", "teacher"]);

        return res.status(200).json({
            success: true,
            message: "Timetable updated successfully",
            timetable: existing
        });
    } catch (error) {
        console.error("Update timetable error:", error);

        return res.status(500).json({
            success: false,
            message: error.message
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

        const timetable = await Timetable.findByIdAndDelete(
            req.params.id
        );

        if (!timetable) {
            return res.status(404).json({
                success: false,
                message: "Timetable not found"
            });
        }

        return res.status(200).json({
            success: true,
            message: "Timetable deleted"
        });
    } catch (error) {
        return res.status(500).json({
            success: false,
            message: error.message
        });
    }
};
