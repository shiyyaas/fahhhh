const Timetable = require("../models/Timetable");

// Create Timetable Entry

exports.createTimetable = async (req, res) => {

    try {

        const {
            batch,
            subject,
            teacher,
            day,
            startTime,
            endTime,
            roomNo
        } = req.body;

        const timetable =
            await Timetable.create({
                batch,
                subject,
                teacher,
                day,
                startTime,
                endTime,
                roomNo
            });

        res.status(201).json({
            success: true,
            message: "Timetable entry created",
            timetable
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
        });

    }

};

// Get All Timetable Entries

exports.getTimetable = async (req, res) => {

    try {

        const timetable =
            await Timetable.find()
                .populate("batch")
                .populate("subject")
                .populate("teacher")
                .sort({
                    day: 1,
                    startTime: 1
                });

        res.status(200).json({
            success: true,
            timetable
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
        });

    }

};

// Get Batch Timetable

exports.getBatchTimetable = async (req, res) => {

    try {

        const timetable =
            await Timetable.find({
                batch: req.params.id
            })
                .populate("batch")
                .populate("subject")
                .populate("teacher");

        res.status(200).json({
            success: true,
            timetable
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
        });

    }

};

// Get Teacher Timetable

exports.getTeacherTimetable = async (req, res) => {

    try {

        const timetable =
            await Timetable.find({
                teacher: req.params.id
            })
                .populate("batch")
                .populate("subject")
                .populate("teacher");

        res.status(200).json({
            success: true,
            timetable
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
        });

    }

};

// Delete Timetable Entry

exports.deleteTimetable = async (req, res) => {

    try {

        const timetable =
            await Timetable.findByIdAndDelete(
                req.params.id
            );

        if (!timetable) {

            return res.status(404).json({
                success: false,
                message: "Timetable not found"
            });

        }

        res.status(200).json({
            success: true,
            message: "Timetable deleted"
        });

    } catch (error) {

        res.status(500).json({
            success: false,
            message: error.message
        });

    }

};