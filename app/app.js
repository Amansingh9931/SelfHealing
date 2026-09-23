const express = require("express");

const app = express();

const PORT = 5000;

app.get("/", (req, res) => {
    res.json({
        message: "Self-Healing DevOps Demo",
        status: "running"
    });
});

app.get("/api/health", (req, res) => {
    res.status(200).json({
        status: "healthy",
        service: "self-healing-demo",
        timestamp: new Date().toISOString()
    });
});

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});