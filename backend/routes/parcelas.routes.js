const router = require('express').Router();
const parcelaController = require('../controllers/parcelaController');

router.get('/', parcelaController.getAll);
router.get('/:id', parcelaController.getById);
router.post('/', parcelaController.create);
router.put('/:id', parcelaController.update);
router.delete('/:id', parcelaController.remove);

module.exports = router;
