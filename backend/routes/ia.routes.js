const router = require('express').Router();
const iaController = require('../controllers/ia.controller');
const auth = require('../middlewares/auth');

router.post('/analisis', auth, iaController.analizar);

module.exports = router;