const express = require("express");

const router = express.Router();

const {
    createBatch,
    getBatches,
    promoteBatch
} = require("../controllers/batchController");

router.post("/", createBatch);

router.get("/", getBatches);

router.put("/:id/promote", promoteBatch);

module.exports = router;