const climaService = require('../services/climaService');

exports.getClima = async (req, res, next) => {
  try {
    const { lat, lon } = req.query;
    const clima = await climaService.obtenerClima(lat, lon);
    res.json(clima);
  } catch (err) {
    next(err);
  }
};

exports.getPronostico = async (req, res, next) => {
  try {
    const { lat, lon } = req.query;
    const pronostico = await climaService.obtenerPronostico(lat, lon);
    res.json(pronostico);
  } catch (err) {
    next(err);
  }
};