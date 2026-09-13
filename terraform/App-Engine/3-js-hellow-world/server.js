const express = require("express");

const app = express();

const PORT = process.env.PORT || 8080;

app.get("/", (req, res) => {
  res.send("Hello from Node.js App Engine Flexible");
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});