const express = require("express");
const client = require("prom-client");

const app = express();

const PORT = 5000;

// Collect default Node.js metrics
client.collectDefaultMetrics();

// Counter for HTTP requests
const httpRequestsTotal = new client.Counter({
    name: "http_requests_total",
    help: "Total number of HTTP requests",
    labelNames: ["method", "route", "status_code"]
});

// Track request duration
const httpRequestDuration = new client.Histogram({
    name: "http_request_duration_seconds",
    help: "HTTP request duration in seconds",
    labelNames: ["method", "route", "status_code"],
    buckets: [0.1, 0.5, 1, 2, 5]
});

// Middleware for monitoring requests
app.use((req, res, next) => {

    const start = process.hrtime();

    res.on("finish", () => {

        const diff = process.hrtime(start);

        const duration =
            diff[0] + diff[1] / 1e9;

        const route = req.route?.path || req.path;

        httpRequestsTotal.inc({
            method: req.method,
            route: route,
            status_code: res.statusCode
        });

        httpRequestDuration.observe(
            {
                method: req.method,
                route: route,
                status_code: res.statusCode
            },
            duration
        );
    });

    next();
});

// Home route
app.get("/", (req, res) => {
    res.json({
        message: "Self-Healing DevOps Demo",
        status: "running"
    });
});

// Health endpoint
app.get("/api/health", (req, res) => {
    res.status(200).json({
        status: "healthy",
        service: "self-healing-app",
        timestamp: new Date().toISOString()
    });
});

// Prometheus metrics endpoint
app.get("/metrics", async (req, res) => {

    res.set("Content-Type", client.register.contentType);

    res.end(await client.register.metrics());
});

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});