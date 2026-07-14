const router = require('express').Router();
const cultivoController = require('../controllers/cultivo.controller');
const auth = require('../middlewares/auth');

router.post('/', auth, cultivoController.create);
router.get('/', auth, cultivoController.getAll);
router.put('/:id', auth, cultivoController.update);
router.delete('/:id', auth, cultivoController.delete);

module.exports = router;
