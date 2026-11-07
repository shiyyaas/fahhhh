
const User = require("../models/User");
const Teacher = require("../models/Teacher");
const cloudinary = require("../config/cloudinary");

const hasValidImageSignature = (file) => {
  if (!file || !Buffer.isBuffer(file.buffer)) return false;

  if (file.mimetype === "image/png") {
    return file.buffer.length >= 8 &&
      file.buffer.subarray(0, 8).equals(
        Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a])
      );
  }

  if (file.mimetype === "image/jpeg") {
    return file.buffer.length >= 3 &&
      file.buffer[0] === 0xff &&
      file.buffer[1] === 0xd8 &&
      file.buffer[2] === 0xff;
  }

  if (file.mimetype === "image/webp") {
    return file.buffer.length >= 12 &&
      file.buffer.toString("ascii", 0, 4) === "RIFF" &&
      file.buffer.toString("ascii", 8, 12) === "WEBP";
  }

  return false;
};

const uploadToCloudinary = (buffer) => {
  return new Promise((resolve, reject) => {
    const stream = cloudinary.uploader.upload_stream(
      {
        folder: "college-erp/avatars",
        resource_type: "image",
        transformation: [{ width: 500, height: 500, crop: "limit" }],
      },
      (error, result) => {
        if (error) return reject(error);
        resolve(result);
      }
    );

    stream.end(buffer);
  });
};

exports.updateAvatar = async (req, res) => {
  let uploadedPublicId = null;

  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: "Please select an image",
      });
    }

    if (!hasValidImageSignature(req.file)) {
      return res.status(400).json({
        success: false,
        message: "Uploaded file is not a valid JPG, PNG, or WEBP image",
      });
    }

    const user = await User.findById(req.user.userId);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    // Upload image to Cloudinary
    const result = await uploadToCloudinary(req.file.buffer);
    uploadedPublicId = result.public_id;

    const oldPublicId = user.avatarPublicId;
    const avatarUrl = result.secure_url;

    // Update User collection
    user.avatar = avatarUrl;
    user.avatarPublicId = uploadedPublicId;
    await user.save();

    // Synchronize Teacher collection
    if (user.role === "TEACHER" || user.role === "HOD") {
      const escapedEmail = user.email.trim().replace(
        /[.*+?^${}()|[\]\\]/g,
        "\\$&"
      );

      const teacher = await Teacher.findOneAndUpdate(
        {
          email: {
            $regex: `^${escapedEmail}$`,
            $options: "i",
          },
        },
        {
          $set: { avatar: avatarUrl },
        },
        { new: true }
      );

      if (!teacher) console.warn("Teacher record not found");
    }

    // Delete old Cloudinary image after successful updates
    if (oldPublicId && oldPublicId !== uploadedPublicId) {
      try {
        await cloudinary.uploader.destroy(oldPublicId);
      } catch (error) {
        console.error("Old avatar deletion failed");
      }
    }

    return res.status(200).json({
      success: true,
      message: "Avatar updated successfully",
      avatarUrl,
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
        avatar: avatarUrl,
      },
    });

  } catch (error) {
    console.error("Avatar upload failed");

    return res.status(500).json({
      success: false,
      message: "Failed to update avatar",
    });
  }
};

exports.hasValidImageSignature = hasValidImageSignature;
