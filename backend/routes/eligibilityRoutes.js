// backend/routes/eligibilityRoutes.js
const express = require('express');
const router  = express.Router();
const auth    = require('../middleware/auth');
const ctrl    = require('../controllers/eligibilityController');
router.post('/check',          ctrl.checkByForm);
router.get('/:studentId', auth, ctrl.checkByStudentId);
module.exports = router;

// backend/routes/applicationRoutes.js — written to separate file below
