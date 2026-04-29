// backend/controllers/applicationController.js
const db = require('../config/db');

const applyToCompany = async (req, res) => {
  const conn = await db.getConnection();
  try {
    await conn.beginTransaction();
    const { company_id, interview_date } = req.body;
    const student_id = req.student.student_id;
    if (!company_id) return res.status(400).json({ success:false, message:'company_id is required.' });

    // Check eligibility
    const [elig] = await conn.query(
      `SELECT (
         s.pcm_percentage >= sr.min_pcm AND s.eyesight <= sr.max_eye_power AND
         (s.medical_status='Fit' OR (sr.accepts_pending_medical=TRUE AND s.medical_status='Pending')) AND
         (sr.swimming_required=FALSE OR s.swimming_certified=TRUE) AND
         (sr.imu_cet_required=FALSE OR s.imu_cet_rank IS NOT NULL) AND
         ((sr.accepts_dns=TRUE AND s.academic_pathway='DNS') OR (sr.accepts_bsc=TRUE AND s.academic_pathway='BSc Nautical Science'))
       ) AS eligible
       FROM STUDENTS s JOIN SPONSORSHIP_REQUIREMENTS sr ON sr.company_id=?
       WHERE s.student_id=?`, [company_id, student_id]);

    if (!elig.length||!elig[0].eligible) {
      await conn.rollback();
      return res.status(403).json({ success:false, message:'You do not meet this company\'s eligibility criteria.' });
    }

    const [result] = await conn.query(
      `INSERT INTO APPLICATIONS (student_id,company_id,application_status,interview_date) VALUES (?,?,'Applied',?)`,
      [student_id, company_id, interview_date||null]);
    await conn.commit();
    return res.status(201).json({ success:true, message:'Application submitted!', application_id:result.insertId });
  } catch(err) {
    await conn.rollback();
    if (err.code==='ER_DUP_ENTRY') return res.status(409).json({ success:false, message:'Already applied to this company.' });
    console.error(err); return res.status(500).json({ success:false, message:'Server error.' });
  } finally { conn.release(); }
};

const getMyApplications = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT a.application_id,a.application_status,a.interview_date,a.applied_at,
              sc.company_name,sc.country,sc.stipend_dns,sc.bond_years,sc.tax_policy,
              sc.female_crew_policy,sc.hq_city,sc.waiting_period_months,
              (SELECT COUNT(*) FROM INTERVIEWS i WHERE i.application_id=a.application_id) AS interview_count
       FROM APPLICATIONS a JOIN SHIPPING_COMPANIES sc ON a.company_id=sc.company_id
       WHERE a.student_id=? ORDER BY a.applied_at DESC`, [req.student.student_id]);
    return res.json({ success:true, applications:rows });
  } catch(err) { return res.status(500).json({ success:false, message:'Server error.' }); }
};

const withdrawApplication = async (req, res) => {
  try {
    const [result] = await db.query(
      `DELETE FROM APPLICATIONS WHERE application_id=? AND student_id=? AND application_status='Applied'`,
      [req.params.id, req.student.student_id]);
    if (!result.affectedRows) return res.status(400).json({ success:false, message:'Cannot withdraw — not found or already processed.' });
    return res.json({ success:true, message:'Application withdrawn.' });
  } catch(err) { return res.status(500).json({ success:false, message:'Server error.' }); }
};

const getAnalytics = async (req, res) => {
  try {
    const [avgPcm]    = await db.query('SELECT AVG(pcm_percentage) AS avg_pcm FROM STUDENTS');
    const [appDist]   = await db.query('SELECT application_status, COUNT(*) AS cnt FROM APPLICATIONS GROUP BY application_status');
    const [topCo]     = await db.query(`SELECT sc.company_name,COUNT(*) AS apps FROM APPLICATIONS a JOIN SHIPPING_COMPANIES sc ON a.company_id=sc.company_id GROUP BY a.company_id ORDER BY apps DESC LIMIT 5`);
    const [totals]    = await db.query('SELECT (SELECT COUNT(*) FROM STUDENTS) AS students,(SELECT COUNT(*) FROM APPLICATIONS) AS apps,(SELECT COUNT(*) FROM SHIPPING_COMPANIES) AS companies');
    return res.json({ success:true, avg_pcm:avgPcm[0].avg_pcm, application_distribution:appDist, top_companies:topCo, ...totals[0] });
  } catch(err) { return res.status(500).json({ success:false, message:'Server error.' }); }
};

module.exports = { applyToCompany, getMyApplications, withdrawApplication, getAnalytics };
