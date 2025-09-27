const mongoose = require("mongoose");

const musicSchema = new mongoose.Schema({
  filename: String,
  filepath: String,
});

module.exports = mongoose.model("Music", musicSchema);
