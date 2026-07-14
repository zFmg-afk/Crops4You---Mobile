const { createAuthenticatedClient } = require('../config/db');

const auth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        error: true,
        mensaje: 'Token de autenticación requerido',
      });
    }

    const token = authHeader.split(' ')[1];

    const tempClient = createAuthenticatedClient(token);
    const { data, error } = await tempClient.auth.getUser(token);

    if (error || !data.user) {
      return res.status(401).json({
        error: true,
        mensaje: 'Token inválido o expirado',
      });
    }

    req.user = data.user;
    req.supabase = createAuthenticatedClient(token);
    next();
  } catch (err) {
    return res.status(500).json({
      error: true,
      mensaje: 'Error al autenticar',
    });
  }
};

module.exports = auth;
