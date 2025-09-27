const mongoose = require("mongoose");

const eventSchema = new mongoose.Schema({
  title: String,
  date: Date,
  musicId: { type: mongoose.Schema.Types.ObjectId, ref: "Music" },
});

module.exports = mongoose.model("Event", eventSchema);
