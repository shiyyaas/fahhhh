const mongoose = require("mongoose");

const subjectSchema = new mongoose.Schema({
    subjectName: {
        type: String,
        required: true,
        trim: true
    },

    subjectCode: {
        type: String,
        required: true,
        unique: true,
        uppercase: true,
        trim: true
    },

    departments: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: "Department"
    }],

    teachers: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: "Teacher"
    }],

    semester: {
        type: Number,
        required: true,
        min: 1,
        max: 6
    },

    credits: {
        type: Number,
        default: 4
    },

    isActive: {
        type: Boolean,
        default: true
    }
}, {
    timestamps: true
});

module.exports = mongoose.model("Subject", subjectSchema);