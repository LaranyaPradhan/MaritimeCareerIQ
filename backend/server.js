// backend/server.js
require('dotenv').config();
const express = require('express');
const cors    = require('cors');
const path    = require('path');

const app = express();
app.use(cors({ origin:'*' }));
app.use(express.json());
app.use(express.urlencoded({ extended:true }));
app.use('/uploads', express.static(path.join(__dirname,'uploads')));
app.use(express.static(path.join(__dirname,'..','frontend')));

app.use('/api/students',     require('./routes/studentRoutes'));
app.use('/api/companies',    require('./routes/companyRoutes'));
app.use('/api/eligibility',  require('./routes/eligibilityRoutes'));
app.use('/api/applications', require('./routes/applicationRoutes'));
app.get('/api/health', (_,res) => res.json({ status:'ok', version:'2.0.0' }));
app.get('*', (req,res) => {
  if (!req.path.startsWith('/api'))
    res.sendFile(path.join(__dirname,'..','frontend','index.html'));
  else res.status(404).json({ success:false, message:'Not found.' });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`\n🚢  Maritime System v2 → http://localhost:${PORT}`);
  console.log(`📡  API → http://localhost:${PORT}/api`);
  console.log(`🌐  Frontend → http://localhost:${PORT}\n`);
});
