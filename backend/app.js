const express = require("express");
const cors = require("cors");
const app = express();

// Middlewares globales
app.use(cors());
app.use(express.json());

// Rutas de prueba (Objetivo 1)
app.use("/health", require("./routes/health.routes"));
app.use("/status", require("./routes/health.routes"));

// Middleware de errores (al final)
app.use(require("./middlewares/errorHandler"));

module.exports = app;
