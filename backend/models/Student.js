const mongoose = require("mongoose");

const studentSchema = new mongoose.Schema({
    studentName: {
        type: String,
        required: true
    },

    registerNo: {
        type: String,
        required: true,
        unique: true
    },

    email: {
        type: String,
        required: true,
        unique: true
    },

    password: {
        type: String,
        required: true
    },

    phoneNo: {
        type: String
    },

    apaarId: {
        type: String
    },

    aadhaarEncrypted: {
        type: String
    },

    batchId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Batch",
        required: true
    },
    department: {
        type: String,
        default: "Computer Science"
    },

    role: {
        type: String,
        default: "STUDENT"
    },

    isFirstLogin: {
        type: Boolean,
        default: true
    },

    isActive: {
        type: Boolean,
        default: true
    }
},
{
    timestamps: true
});

module.exports = mongoose.model("Student", studentSchema);