const express = require("express");
const Event = require("../models/event");

const router = express.Router();

// Create new event
router.post("/", async (req, res) => {
  try {
    const { title, date, musicId } = req.body;
    const newEvent = new Event({ title, date, musicId });
    await newEvent.save();
    res.json({ message: "Event created!", event: newEvent });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get all events
router.get("/", async (req, res) => {
  try {
    const events = await Event.find().populate("musicId");
    res.json(events);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
