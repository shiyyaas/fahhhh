const mongoose = require("mongoose");

const batchSchema = new mongoose.Schema({
    batchName: {
        type: String,
        required: true,
        unique: true,
        trim: true
    },

    department: {
        type: String,
        required: true,
        trim: true
    },

    currentSemester: {
        type: Number,
        default: 1,
        min: 1,
        max: 8
    },

    startYear: {
        type: Number,
        required: true
    },

    endYear: {
        type: Number,
        required: true
    },

    isActive: {
        type: Boolean,
        default: true
    }
}, {
    timestamps: true
});

module.exports = mongoose.model("Batch", batchSchema);