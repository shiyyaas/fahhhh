const mongoose = require("mongoose");

const attendanceSchema = new mongoose.Schema({
    student: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Student",
        required: true
    },

    subject: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Subject",
        required: true
    },

    teacher: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Teacher",
        required: true
    },

    batch: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Batch",
        required: true
    },

    date: {
        type: Date,
        default: Date.now
    },

    status: {
        type: String,
        enum: ["Present", "Absent", "Late"],
        required: true
    }

}, {
    timestamps: true
});

attendanceSchema.index({ student: 1, subject: 1, batch: 1, date: 1 }, { unique: true });

module.exports = mongoose.model("Attendance", attendanceSchema);