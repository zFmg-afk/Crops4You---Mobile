const router = require('express').Router();
const insumoController = require('../controllers/insumo.controller');
const auth = require('../middlewares/auth');

router.post('/', auth, insumoController.create);
router.get('/', auth, insumoController.getAll);
router.put('/:id', auth, insumoController.update);
router.delete('/:id', auth, insumoController.delete);

module.exports = router;