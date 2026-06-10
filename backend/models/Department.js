const mongoose = require("mongoose");

const departmentSchema = new mongoose.Schema({
    departmentName: {
        type: String,
        required: true,
        unique: true,
        trim: true
    },

    departmentCode: {
        type: String,
        required: true,
        unique: true,
        uppercase: true,
        trim: true
    },

    hodName: {
        type: String,
        required: true,
        trim: true
    },

    isActive: {
        type: Boolean,
        default: true
    }
}, {
    timestamps: true
});

module.exports = mongoose.model("Department", departmentSchema);    