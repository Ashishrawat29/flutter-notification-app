const express = require("express");
const multer = require("multer");
const path = require("path");
const Music = require("../models/music");

const router = express.Router();

// File storage config
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, "uploads/"),
  filename: (req, file, cb) =>
    cb(null, Date.now() + path.extname(file.originalname)),
});

const upload = multer({ storage });

// Upload a music file
router.post("/upload", upload.single("file"), async (req, res) => {
  try {
    const newMusic = new Music({
      filename: req.file.filename,
      filepath: `/uploads/${req.file.filename}`,
    });
    await newMusic.save();
    res.json({ message: "Music uploaded!", music: newMusic });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Fetch all music files
router.get("/", async (req, res) => {
  try {
    const musicFiles = await Music.find();
    res.json(musicFiles);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
