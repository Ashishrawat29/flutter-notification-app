const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const path = require("path");

const app = express();
app.use(express.json());
app.use(cors());

// MongoDB connection
mongoose.connect("mongodb://localhost:27017/notification_app", {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

// Static uploads folder
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

// Routes
app.use("/music", require("./routes/music"));
app.use("/events", require("./routes/events"));

app.listen(5000, () => {
  console.log("✅ Server running on http://localhost:5000");
});
