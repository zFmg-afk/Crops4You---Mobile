const router = require('express').Router();
const climaController = require('../controllers/climaController');

// GET /clima?lat=...&lon=...
router.get('/', climaController.getClima);

// GET /clima/pronostico?lat=...&lon=...
router.get('/pronostico', climaController.getPronostico);

module.exports = router;