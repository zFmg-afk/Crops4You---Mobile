const router = require('express').Router();
const climaController = require('../controllers/climaController');

// GET /clima?lat=...&lon=...
router.get('/', climaController.getClima);

module.exports = router;