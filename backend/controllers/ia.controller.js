const iaService = require('../services/ia.service');

exports.analizar = async (req, res, next) => {
  try {
    const { base64Image, mimeType, modo } = req.body;

    if (!base64Image) {
      return res.status(400).json({
        error: true,
        mensaje: 'La imagen en base64 es requerida'
      });
    }

    const resultado = await Promise.race([
      iaService.analizar(base64Image, mimeType || 'image/jpeg', modo || 'cultivo'),
      new Promise((_, reject) =>
        setTimeout(() => reject(new Error('timeout')), 115000)
      )
    ]);

    res.json({ resultado });

  } catch (err) {
    if (err.message === 'timeout') {
      return res.status(503).json({
        error: true,
        mensaje: 'El servicio de IA no respondió a tiempo'
      });
    }
    next(err);
  }
};