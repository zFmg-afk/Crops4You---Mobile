const router = require('express').Router();
const parcelaController = require('../controllers/parcelaController');
const auth = require('../middlewares/auth');

router.get('/', auth, parcelaController.getAll);
router.get('/:id', auth, parcelaController.getById);
router.post('/', auth, parcelaController.create);
router.put('/:id', auth, parcelaController.update);
router.delete('/:id', auth, parcelaController.remove);

module.exports = router;
