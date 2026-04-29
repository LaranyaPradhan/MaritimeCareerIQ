// backend/routes/companyRoutes.js
const express = require('express');
const router  = express.Router();
const ctrl    = require('../controllers/companyController');
router.get('/',              ctrl.getAllCompanies);
router.get('/stats/summary', ctrl.getStats);
router.get('/:id',           ctrl.getCompanyById);
module.exports = router;
