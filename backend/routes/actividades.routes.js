const router = require('express').Router();
const actividadController = require('../controllers/actividadController');

router.get('/', actividadController.getAll);
router.get('/:id', actividadController.getById);
router.post('/', actividadController.create);
router.put('/:id', actividadController.update);
router.delete('/:id', actividadController.remove);

module.exports = router;
