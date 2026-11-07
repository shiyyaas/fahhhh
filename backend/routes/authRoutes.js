
const express = require("express");
const router = express.Router();

const { login } = require("../controllers/authController");

const {
  forgotPassword,
  resetPassword,
} = require("../controllers/passwordController");

const { updateAvatar } = require("../controllers/avatarController");
const { verifyToken } = require("../middleware/authMiddleware");
const upload = require("../middleware/upload");
const { authRateLimit } = require("../middleware/rateLimit");

router.post("/login", authRateLimit, login);
router.post("/forgot-password", authRateLimit, forgotPassword);
router.post("/reset-password", authRateLimit, resetPassword);

// Avatar update
router.put("/avatar",verifyToken,upload.single("avatar"),updateAvatar);

module.exports = router;
