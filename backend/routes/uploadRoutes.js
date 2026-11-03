const express = require("express");
const router = express.Router();

const { updateAvatar } = require("../controllers/avatarController");
const { verifyToken } = require("../middleware/authMiddleware");
const upload = require("../middleware/upload");

router.post(
  "/avatar",
  verifyToken,
  upload.single("avatar"),
  updateAvatar
);

module.exports = router;