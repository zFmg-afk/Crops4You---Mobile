const router = require('express').Router();
const actividadController = require('../controllers/actividadController');
const auth = require('../middlewares/auth');

router.get('/', auth, actividadController.getAll);
router.get('/:id', auth, actividadController.getById);
router.post('/', auth, actividadController.create);
router.put('/:id', auth, actividadController.update);
router.delete('/:id', auth, actividadController.remove);

module.exports = router;
