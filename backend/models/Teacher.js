const mongoose = require("mongoose");

const teacherSchema = new mongoose.Schema({
    teacherName: {
        type: String,
        required: true,
        trim: true
    },

    employeeId: {
        type: String,
        required: true,
        unique: true,
        trim: true
    },

    email: {
        type: String,
        required: true,
        unique: true,
        lowercase: true,
        trim: true
    },

    password: {
        type: String,
        required: true
    },

    phoneNo: {
        type: String
    },

    departments: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: "Department"
    }],

    role: {
        type: String,
        default: "TEACHER"
    },

    isActive: {
        type: Boolean,
        default: true
    }
}, {
    timestamps: true
});

module.exports = mongoose.model("Teacher", teacherSchema);