// backend/routes/applicationRoutes.js
const express = require('express');
const router  = express.Router();
const auth    = require('../middleware/auth');
const ctrl    = require('../controllers/applicationController');
router.post('/',           auth, ctrl.applyToCompany);
router.get('/my',          auth, ctrl.getMyApplications);
router.get('/analytics',   auth, ctrl.getAnalytics);
router.delete('/:id',      auth, ctrl.withdrawApplication);
module.exports = router;
