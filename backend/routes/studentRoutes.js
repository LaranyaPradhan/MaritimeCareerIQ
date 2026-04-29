// backend/routes/studentRoutes.js
const express = require('express');
const router  = express.Router();
const auth    = require('../middleware/auth');
const upload  = require('../config/upload');
const ctrl    = require('../controllers/studentController');

router.post('/register',                ctrl.register);
router.post('/login',                   ctrl.login);
router.get('/profile',            auth, ctrl.getProfile);
router.get('/dashboard',          auth, ctrl.getDashboard);
router.get('/documents',          auth, ctrl.getDocuments);
router.post('/documents/upload',  auth, upload.single('file'), ctrl.uploadDocument);
router.get('/exam-scores',        auth, ctrl.getExamScores);

module.exports = router;
