const mongoose = require("mongoose");

const leaveSchema = new mongoose.Schema({

    applicantId: {
        type: mongoose.Schema.Types.ObjectId,
        required: true
    },

    applicantType: {
        type: String,
        enum: ["STUDENT", "TEACHER"],
        required: true
    },

    reason: {
        type: String,
        required: true
    },

    fromDate: {
        type: Date,
        required: true
    },

    toDate: {
        type: Date,
        required: true
    },

    status: {
        type: String,
        enum: [
            "PENDING_TEACHER",
            "PENDING_HOD",
            "APPROVED",
            "REJECTED"
        ],
        default: "PENDING_TEACHER"
    },

    teacherApproval: {
        type: Boolean,
        default: false
    },

    hodApproval: {
        type: Boolean,
        default: false
    },

    approvedBy: {
        type: mongoose.Schema.Types.ObjectId,
        default: null
    }

}, {
    timestamps: true
});

module.exports = mongoose.model(
    "Leave",
    leaveSchema
);