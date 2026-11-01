const multer = require("multer");
const path = require("path");
const fs = require("fs");
const User = require("../models/User");
const Teacher = require("../models/Teacher");
const Student = require("../models/Student");

// Ensure upload directory exists
const uploadDir = path.join(__dirname, "../uploads/avatars");
if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
}

// Storage configuration
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
        const ext = path.extname(file.originalname).toLowerCase() || ".png";
        cb(null, `avatar-${uniqueSuffix}${ext}`);
    }
});

// File filter for images only
const fileFilter = (req, file, cb) => {
    const allowedMimeTypes = ["image/jpeg", "image/png", "image/webp", "image/jpg"];
    if (allowedMimeTypes.includes(file.mimetype.toLowerCase())) {
        cb(null, true);
    } else {
        cb(new Error("Only JPEG, PNG, and WebP images are allowed"), false);
    }
};

const upload = multer({
    storage,
    limits: { fileSize: 5 * 1024 * 1024 }, // 5 MB max
    fileFilter
});

exports.uploadMiddleware = upload.single("avatar");

exports.uploadAvatar = async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({
                success: false,
                message: "No image file provided"
            });
        }

        const avatarRelativeUrl = `/uploads/avatars/${req.file.filename}`;
        const { userId, role, email } = req.body;

        // Synchronize avatar across User, Teacher, and Student collections
        if (userId) {
            await User.findByIdAndUpdate(userId, { avatar: avatarRelativeUrl });
            await Teacher.findByIdAndUpdate(userId, { avatar: avatarRelativeUrl });
            await Student.findByIdAndUpdate(userId, { avatar: avatarRelativeUrl });
        }

        if (email) {
            const cleanEmail = email.toLowerCase().trim();
            await User.findOneAndUpdate({ email: cleanEmail }, { avatar: avatarRelativeUrl });
            await Teacher.findOneAndUpdate({ email: cleanEmail }, { avatar: avatarRelativeUrl });
            await Student.findOneAndUpdate({ email: cleanEmail }, { avatar: avatarRelativeUrl });
        }

        return res.status(200).json({
            success: true,
            message: "Avatar uploaded successfully",
            avatarUrl: avatarRelativeUrl
        });

    } catch (error) {
        console.error("Avatar upload error:", error);
        return res.status(500).json({
            success: false,
            message: error.message
        });
    }
};
