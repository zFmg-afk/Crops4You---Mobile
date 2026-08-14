const router = require('express').Router();
const recordatorioController = require('../controllers/recordatorioController');
const auth = require('../middlewares/auth');

router.get('/', auth, recordatorioController.getAll);
router.get('/:id', auth, recordatorioController.getById);
router.post('/', auth, recordatorioController.create);
router.put('/:id', auth, recordatorioController.update);
router.delete('/:id', auth, recordatorioController.remove);

module.exports = router;