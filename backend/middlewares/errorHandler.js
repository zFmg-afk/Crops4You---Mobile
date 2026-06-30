// eslint-disable-next-line no-unused-vars
const errorHandler = (err, req, res, next) => {
  console.error("❌ Error:", err.message);

  const status = err.status || 500;
  res.status(status).json({
    error: true,
    mensaje: err.message || "Error interno del servidor",
  });
};

module.exports = errorHandler;
