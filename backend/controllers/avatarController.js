const User = require("../models/User");
const Teacher = require("../models/Teacher");
const cloudinary = require("../config/cloudinary");

const uploadToCloudinary = (buffer) => {
  return new Promise((resolve, reject) => {
    const stream = cloudinary.uploader.upload_stream(
      {
        folder: "college-erp/avatars",
        resource_type: "image",
        transformation: [
          { width: 500, height: 500, crop: "limit" },
        ],
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

    // Identify the authenticated user
    const user = await User.findById(req.user.userId);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    // Upload to Cloudinary
    const result = await uploadToCloudinary(req.file.buffer);
    uploadedPublicId = result.public_id;

    const oldPublicId = user.avatarPublicId;

    // Update User collection
    user.avatar = result.secure_url;
    user.avatarPublicId = result.public_id;
    await user.save();

    // Synchronize teacher profile using email, not User ID
    if (["TEACHER", "HOD"].includes(user.role)) {
      await Teacher.findOneAndUpdate(
        { email: user.email },
        { avatar: result.secure_url }
      );
    }

    // Delete old Cloudinary image after successful update
    if (oldPublicId && oldPublicId !== uploadedPublicId) {
      try {
        await cloudinary.uploader.destroy(oldPublicId);
      } catch (error) {
        console.error("Old avatar deletion failed:", error.message);
      }
    }

    return res.status(200).json({
      success: true,
      message: "Avatar updated successfully",
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
        avatar: user.avatar,
      },
    });

  } catch (error) {
    if (uploadedPublicId) {
      try {
        await cloudinary.uploader.destroy(uploadedPublicId);
      } catch (cleanupError) {
        console.error("Avatar cleanup failed:", cleanupError.message);
      }
    }

    console.error("Avatar upload error:", error);

    return res.status(500).json({
      success: false,
      message: "Failed to update avatar",
    });
  }
};