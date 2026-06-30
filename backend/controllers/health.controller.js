const healthService = require("../services/health.service");

exports.check = (req, res) => {
  const data = healthService.getStatus();
  res.status(200).json(data);
};
