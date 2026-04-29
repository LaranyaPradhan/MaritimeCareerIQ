// backend/controllers/studentController.js
const db     = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt    = require('jsonwebtoken');
require('dotenv').config();
const SECRET = process.env.JWT_SECRET || 'maritime_secret';

const register = async (req, res) => {
  try {
    const { name, email, password, phone, age, gender, city, state, pincode,
            institute, academic_pathway, pcm_percentage, tenth_percentage,
            twelfth_percentage, tenth_english, twelfth_english, imu_cet_rank,
            eyesight, medical_status, swimming_certified } = req.body;

    if (!name || !email || !password || !age || !gender || !institute ||
        !academic_pathway || !pcm_percentage || eyesight === undefined || !medical_status)
      return res.status(400).json({ success: false, message: 'All required fields must be provided.' });

    const [exist] = await db.query('SELECT student_id FROM STUDENTS WHERE email = ?', [email]);
    if (exist.length) return res.status(409).json({ success: false, message: 'Email already registered.' });

    const hash = await bcrypt.hash(password, 10);
    let agg = null;
    if (tenth_percentage && twelfth_percentage)
      agg = ((parseFloat(tenth_percentage) + parseFloat(twelfth_percentage)) / 2).toFixed(2);

    const [result] = await db.query(
      `INSERT INTO STUDENTS (name,email,password_hash,phone,age,gender,city,state,pincode,
        institute,academic_pathway,pcm_percentage,tenth_percentage,twelfth_percentage,
        tenth_english,twelfth_english,aggregate_percentage,imu_cet_rank,eyesight,
        medical_status,swimming_certified)
       VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`,
      [name,email,hash,phone||null,age,gender,city||null,state||null,pincode||null,
       institute,academic_pathway,pcm_percentage,tenth_percentage||null,twelfth_percentage||null,
       tenth_english||null,twelfth_english||null,agg,imu_cet_rank||null,
       eyesight,medical_status,swimming_certified?1:0]
    );
    const token = jwt.sign({ student_id: result.insertId, name, email }, SECRET, { expiresIn:'7d' });
    return res.status(201).json({ success:true, message:'Registration successful!', token,
      student:{ student_id:result.insertId, name, email, academic_pathway } });
  } catch(err) {
    if (err.code==='ER_DUP_ENTRY') return res.status(409).json({ success:false, message:'IMU-CET rank already exists.' });
    console.error('register:',err);
    return res.status(500).json({ success:false, message:'Server error.' });
  }
};

const login = async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email||!password) return res.status(400).json({ success:false, message:'Email and password required.' });
    const [rows] = await db.query('SELECT * FROM STUDENTS WHERE email = ?', [email]);
    if (!rows.length) return res.status(401).json({ success:false, message:'Invalid credentials.' });
    const s = rows[0];
    const ok = s.password_hash==='$demo$' ? password==='password123' : await bcrypt.compare(password,s.password_hash);
    if (!ok) return res.status(401).json({ success:false, message:'Invalid credentials.' });
    const token = jwt.sign({ student_id:s.student_id, name:s.name, email:s.email }, SECRET, { expiresIn:'7d' });
    const { password_hash, ...safe } = s;
    return res.json({ success:true, token, student:safe });
  } catch(err) {
    console.error('login:',err);
    return res.status(500).json({ success:false, message:'Server error.' });
  }
};

const getProfile = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT student_id,name,email,phone,age,gender,city,state,pincode,institute,
              academic_pathway,pcm_percentage,tenth_percentage,twelfth_percentage,
              tenth_english,twelfth_english,aggregate_percentage,imu_cet_rank,
              eyesight,medical_status,swimming_certified,created_at
       FROM STUDENTS WHERE student_id=?`, [req.student.student_id]);
    if (!rows.length) return res.status(404).json({ success:false, message:'Student not found.' });
    return res.json({ success:true, student:rows[0] });
  } catch(err) { return res.status(500).json({ success:false, message:'Server error.' }); }
};

const getDashboard = async (req, res) => {
  try {
    const sid = req.student.student_id;
    const [[profile]] = await db.query(
      `SELECT student_id,name,email,phone,age,gender,city,state,institute,academic_pathway,
              pcm_percentage,tenth_percentage,twelfth_percentage,tenth_english,twelfth_english,
              aggregate_percentage,imu_cet_rank,eyesight,medical_status,swimming_certified
       FROM STUDENTS WHERE student_id=?`, [sid]);
    const [apps] = await db.query(
      `SELECT a.application_id,a.application_status,a.interview_date,a.applied_at,
              sc.company_name,sc.country,sc.stipend_dns,sc.hq_city
       FROM APPLICATIONS a JOIN SHIPPING_COMPANIES sc ON a.company_id=sc.company_id
       WHERE a.student_id=? ORDER BY a.applied_at DESC`, [sid]);
    const [scores] = await db.query(
      `SELECT e.exam_name,es.score,es.rank_obtained,es.exam_date
       FROM EXAM_SCORES es JOIN EXAMS e ON es.exam_id=e.exam_id WHERE es.student_id=?`, [sid]);
    const [docs] = await db.query(
      `SELECT d.document_name,sd.verification_status,sd.submitted_at,sd.file_name
       FROM STUDENT_DOCUMENTS sd JOIN DOCUMENTS d ON sd.document_id=d.document_id WHERE sd.student_id=?`, [sid]);
    return res.json({ success:true, profile, applications:apps, exam_scores:scores, documents:docs,
      stats:{ total_applications:apps.length,
              selected:apps.filter(a=>a.application_status==='Selected').length,
              under_review:apps.filter(a=>a.application_status==='Under Review').length,
              applied:apps.filter(a=>a.application_status==='Applied').length,
              docs_verified:docs.filter(d=>d.verification_status==='Verified').length,
              docs_total:docs.length } });
  } catch(err) { console.error('dashboard:',err); return res.status(500).json({ success:false, message:'Server error.' }); }
};

const getDocuments = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT sd.record_id,d.document_id,d.document_name,d.is_mandatory,d.description,
              sd.verification_status,sd.submitted_at,sd.file_name,sd.file_path,
              sc.company_name
       FROM STUDENT_DOCUMENTS sd
       JOIN DOCUMENTS d ON sd.document_id=d.document_id
       LEFT JOIN SHIPPING_COMPANIES sc ON sd.company_id=sc.company_id
       WHERE sd.student_id=? ORDER BY sd.submitted_at DESC`, [req.student.student_id]);
    const [allDocs] = await db.query('SELECT * FROM DOCUMENTS ORDER BY is_mandatory DESC, document_id');
    return res.json({ success:true, uploaded:rows, all_documents:allDocs });
  } catch(err) { return res.status(500).json({ success:false, message:'Server error.' }); }
};

const uploadDocument = async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ success:false, message:'No file uploaded.' });
    const { document_id, company_id } = req.body;
    if (!document_id) return res.status(400).json({ success:false, message:'document_id required.' });
    await db.query(
      `INSERT INTO STUDENT_DOCUMENTS (student_id,document_id,company_id,file_path,file_name,verification_status)
       VALUES (?,?,?,?,?,'Pending')
       ON DUPLICATE KEY UPDATE file_path=VALUES(file_path),file_name=VALUES(file_name),verification_status='Pending',submitted_at=NOW()`,
      [req.student.student_id, document_id, company_id||null, req.file.path, req.file.originalname]);
    return res.json({ success:true, message:'Document uploaded successfully!', file:req.file.originalname });
  } catch(err) { console.error('upload:',err); return res.status(500).json({ success:false, message:'Server error.' }); }
};

const getExamScores = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT e.exam_name,es.score,es.rank_obtained,es.exam_date
       FROM EXAM_SCORES es JOIN EXAMS e ON es.exam_id=e.exam_id WHERE es.student_id=?`, [req.student.student_id]);
    return res.json({ success:true, scores:rows });
  } catch(err) { return res.status(500).json({ success:false, message:'Server error.' }); }
};

module.exports = { register, login, getProfile, getDashboard, getDocuments, uploadDocument, getExamScores };
