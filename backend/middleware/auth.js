// backend/middleware/auth.js
const jwt = require('jsonwebtoken');
require('dotenv').config();
module.exports = (req, res, next) => {
  const token = (req.headers['authorization'] || '').split(' ')[1];
  if (!token) return res.status(401).json({ success: false, message: 'No token provided.' });
  try { req.student = jwt.verify(token, process.env.JWT_SECRET || 'maritime_secret'); next(); }
  catch { return res.status(403).json({ success: false, message: 'Invalid or expired token.' }); }
};
