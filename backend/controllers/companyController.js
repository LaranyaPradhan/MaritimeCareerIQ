// backend/controllers/companyController.js
const db = require('../config/db');

const getAllCompanies = async (req, res) => {
  try {
    const [companies] = await db.query(
      `SELECT sc.company_id,sc.company_name,sc.country,sc.hq_city,sc.india_office,
              sc.stipend_dns,sc.stipend_onboard_trainee,sc.bond_years,sc.promotion_period_years,
              sc.minimum_contract_months,sc.maximum_contract_months,sc.waiting_period_months,
              sc.tax_policy,sc.female_crew_policy,sc.company_description,sc.total_fleet_size,
              sr.min_pcm,sr.max_eye_power,sr.swimming_required,sr.medical_standard,
              sr.accepts_pending_medical,sr.imu_cet_required,sr.own_cbt_test,
              sr.psychometric_test,sr.min_10th_percentage,sr.min_12th_percentage,
              sr.min_10th_english,sr.min_12th_english,sr.min_aggregate,
              sr.age_min,sr.age_max,sr.accepts_dns,sr.accepts_bsc,sr.additional_notes,
              cd.forms_open_date,cd.forms_close_date,cd.exam_date,
              cd.interview_month,cd.dns_joining_month,cd.status AS deadline_status,cd.notes AS deadline_notes
       FROM SHIPPING_COMPANIES sc
       LEFT JOIN SPONSORSHIP_REQUIREMENTS sr ON sc.company_id=sr.company_id
       LEFT JOIN COMPANY_DEADLINES cd ON sc.company_id=cd.company_id
       ORDER BY sc.stipend_dns DESC`);
    return res.json({ success:true, companies });
  } catch(err) { console.error(err); return res.status(500).json({ success:false, message:'Server error.' }); }
};

const getCompanyById = async (req, res) => {
  try {
    const { id } = req.params;
    const [company] = await db.query(
      `SELECT sc.*,sr.min_pcm,sr.max_eye_power,sr.swimming_required,sr.medical_standard,
              sr.accepts_pending_medical,sr.imu_cet_required,sr.own_cbt_test,sr.psychometric_test,
              sr.min_10th_percentage,sr.min_12th_percentage,sr.min_10th_english,sr.min_12th_english,
              sr.min_aggregate,sr.age_min,sr.age_max,sr.accepts_dns,sr.accepts_bsc,sr.additional_notes
       FROM SHIPPING_COMPANIES sc
       LEFT JOIN SPONSORSHIP_REQUIREMENTS sr ON sc.company_id=sr.company_id
       WHERE sc.company_id=?`, [id]);
    if (!company.length) return res.status(404).json({ success:false, message:'Company not found.' });

    const [fleet] = await db.query(
      `SELECT st.ship_type_name,st.description,cf.number_of_ships
       FROM COMPANY_FLEET cf JOIN SHIP_TYPES st ON cf.ship_type_id=st.ship_type_id
       WHERE cf.company_id=? ORDER BY cf.number_of_ships DESC`, [id]);

    const [colleges] = await db.query(
      `SELECT c.*,cc.is_preferred
       FROM COLLEGES c JOIN COMPANY_COLLEGE cc ON c.college_id=cc.college_id
       WHERE cc.company_id=? ORDER BY cc.is_preferred DESC`, [id]);

    const [process_steps] = await db.query(
      `SELECT step_order,step_name,step_desc,is_eliminatory
       FROM COMPANY_SELECTION_PROCESS WHERE company_id=? ORDER BY step_order`, [id]);

    const [doctors] = await db.query(
      `SELECT * FROM COMPANY_APPROVED_DOCTORS WHERE company_id=? ORDER BY city`, [id]);

    const [deadline] = await db.query(
      `SELECT * FROM COMPANY_DEADLINES WHERE company_id=? ORDER BY batch_year DESC LIMIT 1`, [id]);

    const [financial] = await db.query(
      `SELECT * FROM COMPANY_FINANCIAL WHERE company_id=?`, [id]);

    const [salary] = await db.query(
      `SELECT * FROM COMPANY_SALARY_PROGRESSION WHERE company_id=? ORDER BY years_experience_min`, [id]);

    const [appStats] = await db.query(
      `SELECT application_status, COUNT(*) AS cnt FROM APPLICATIONS WHERE company_id=? GROUP BY application_status`, [id]);

    return res.json({ success:true, company:{
      ...company[0], fleet, colleges, process_steps, doctors,
      deadline: deadline[0]||null, financial: financial[0]||null,
      salary_progression: salary, application_stats: appStats
    }});
  } catch(err) { console.error(err); return res.status(500).json({ success:false, message:'Server error.' }); }
};

const getStats = async (req, res) => {
  try {
    const [perCompany] = await db.query(
      `SELECT sc.company_name,sc.stipend_dns,
              COUNT(a.application_id) AS total_applications,
              SUM(a.application_status='Selected') AS selected,
              SUM(a.application_status='Rejected') AS rejected,
              SUM(a.application_status='Applied')  AS applied
       FROM SHIPPING_COMPANIES sc
       LEFT JOIN APPLICATIONS a ON sc.company_id=a.company_id
       GROUP BY sc.company_id ORDER BY total_applications DESC`);
    const [overview] = await db.query(
      `SELECT AVG(stipend_dns) AS avg_stipend, MAX(stipend_dns) AS max_stipend,
              MIN(stipend_dns) AS min_stipend, COUNT(*) AS total_companies
       FROM SHIPPING_COMPANIES`);
    return res.json({ success:true, per_company:perCompany, overview:overview[0] });
  } catch(err) { return res.status(500).json({ success:false, message:'Server error.' }); }
};

module.exports = { getAllCompanies, getCompanyById, getStats };
