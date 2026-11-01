const express = require("express");
const router = express.Router();
const { uploadMiddleware, uploadAvatar } = require("../controllers/uploadController");

router.post("/avatar", uploadMiddleware, uploadAvatar);

module.exports = router;
