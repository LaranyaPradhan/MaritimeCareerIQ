// backend/controllers/eligibilityController.js
const db = require('../config/db');

const checkByStudentId = async (req, res) => {
  try {
    const { studentId } = req.params;
    const [sRows] = await db.query(
      `SELECT student_id,name,pcm_percentage,tenth_percentage,twelfth_percentage,
              tenth_english,twelfth_english,aggregate_percentage,imu_cet_rank,
              eyesight,medical_status,swimming_certified,academic_pathway,age
       FROM STUDENTS WHERE student_id=?`, [studentId]);
    if (!sRows.length) return res.status(404).json({ success:false, message:'Student not found.' });

    const [all] = await db.query(
      `SELECT sc.company_id,sc.company_name,sc.country,sc.stipend_dns,sc.bond_years,
              sc.tax_policy,sc.female_crew_policy,sc.waiting_period_months,
              sr.min_pcm,sr.max_eye_power,sr.swimming_required,sr.medical_standard,
              sr.accepts_pending_medical,sr.imu_cet_required,sr.own_cbt_test,
              sr.psychometric_test,sr.min_10th_percentage,sr.min_12th_percentage,
              sr.min_10th_english,sr.min_12th_english,sr.min_aggregate,
              sr.age_min,sr.age_max,sr.accepts_dns,sr.accepts_bsc,
              (s.pcm_percentage >= sr.min_pcm)                                             AS pcm_ok,
              (s.eyesight <= sr.max_eye_power)                                             AS eye_ok,
              (s.medical_status='Fit' OR (sr.accepts_pending_medical=TRUE AND s.medical_status='Pending')) AS med_ok,
              (sr.swimming_required=FALSE OR s.swimming_certified=TRUE)                    AS swim_ok,
              (sr.imu_cet_required=FALSE OR s.imu_cet_rank IS NOT NULL)                   AS imu_ok,
              (s.tenth_percentage IS NULL OR sr.min_10th_percentage IS NULL OR s.tenth_percentage >= sr.min_10th_percentage) AS tenth_ok,
              (s.twelfth_percentage IS NULL OR sr.min_12th_percentage IS NULL OR s.twelfth_percentage >= sr.min_12th_percentage) AS twelfth_ok,
              (s.aggregate_percentage IS NULL OR sr.min_aggregate IS NULL OR s.aggregate_percentage >= sr.min_aggregate) AS agg_ok,
              ((sr.accepts_dns=TRUE AND s.academic_pathway='DNS') OR (sr.accepts_bsc=TRUE AND s.academic_pathway='BSc Nautical Science')) AS pathway_ok,
              (s.age >= sr.age_min AND s.age <= sr.age_max) AS age_ok,
              (
                s.pcm_percentage >= sr.min_pcm AND
                s.eyesight <= sr.max_eye_power AND
                (s.medical_status='Fit' OR (sr.accepts_pending_medical=TRUE AND s.medical_status='Pending')) AND
                (sr.swimming_required=FALSE OR s.swimming_certified=TRUE) AND
                (sr.imu_cet_required=FALSE OR s.imu_cet_rank IS NOT NULL) AND
                (s.tenth_percentage IS NULL OR sr.min_10th_percentage IS NULL OR s.tenth_percentage >= sr.min_10th_percentage) AND
                (s.twelfth_percentage IS NULL OR sr.min_12th_percentage IS NULL OR s.twelfth_percentage >= sr.min_12th_percentage) AND
                ((sr.accepts_dns=TRUE AND s.academic_pathway='DNS') OR (sr.accepts_bsc=TRUE AND s.academic_pathway='BSc Nautical Science'))
              ) AS is_eligible
       FROM STUDENTS s
       CROSS JOIN SPONSORSHIP_REQUIREMENTS sr
       JOIN SHIPPING_COMPANIES sc ON sr.company_id=sc.company_id
       WHERE s.student_id=?
       ORDER BY is_eligible DESC, sc.stipend_dns DESC`, [studentId, studentId]);

    return res.json({ success:true, student:sRows[0], all_companies:all,
      eligible_companies:all.filter(c=>c.is_eligible),
      eligible_count:all.filter(c=>c.is_eligible).length, total_companies:all.length });
  } catch(err) { console.error(err); return res.status(500).json({ success:false, message:'Server error.' }); }
};

const checkByForm = async (req, res) => {
  try {
    const { pcm_percentage, imu_cet_rank, eyesight, medical_status, swimming_certified,
            tenth_percentage, twelfth_percentage, age, academic_pathway } = req.body;

    const pcm   = parseFloat(pcm_percentage||0);
    const eye   = parseFloat(eyesight||0);
    const swim  = swimming_certified===true||swimming_certified==='true';
    const med   = medical_status||'Pending';
    const imu   = imu_cet_rank ? parseInt(imu_cet_rank) : null;
    const tenth = tenth_percentage ? parseFloat(tenth_percentage) : null;
    const twelfth = twelfth_percentage ? parseFloat(twelfth_percentage) : null;
    const agg   = (tenth&&twelfth) ? (tenth+twelfth)/2 : null;
    const studentAge = parseInt(age||18);
    const pathway = academic_pathway||'DNS';

    const [all] = await db.query(
      `SELECT sc.company_id,sc.company_name,sc.country,sc.stipend_dns,sc.bond_years,
              sc.tax_policy,sc.female_crew_policy,sc.waiting_period_months,
              sr.min_pcm,sr.max_eye_power,sr.swimming_required,sr.medical_standard,
              sr.accepts_pending_medical,sr.imu_cet_required,sr.own_cbt_test,
              sr.psychometric_test,sr.min_10th_percentage,sr.min_12th_percentage,
              sr.min_aggregate,sr.age_min,sr.age_max,sr.accepts_dns,sr.accepts_bsc,
              (? >= sr.min_pcm) AS pcm_ok,
              (? <= sr.max_eye_power) AS eye_ok,
              (? = 'Fit' OR (sr.accepts_pending_medical=TRUE AND ? = 'Pending')) AS med_ok,
              (sr.swimming_required=FALSE OR ? = TRUE) AS swim_ok,
              (sr.imu_cet_required=FALSE OR ? IS NOT NULL) AS imu_ok,
              (? IS NULL OR sr.min_10th_percentage IS NULL OR ? >= sr.min_10th_percentage) AS tenth_ok,
              (? IS NULL OR sr.min_12th_percentage IS NULL OR ? >= sr.min_12th_percentage) AS twelfth_ok,
              ((sr.accepts_dns=TRUE AND ?='DNS') OR (sr.accepts_bsc=TRUE AND ?='BSc Nautical Science')) AS pathway_ok,
              (? >= sr.age_min AND ? <= sr.age_max) AS age_ok,
              (
                ? >= sr.min_pcm AND ? <= sr.max_eye_power AND
                (? = 'Fit' OR (sr.accepts_pending_medical=TRUE AND ? = 'Pending')) AND
                (sr.swimming_required=FALSE OR ? = TRUE) AND
                (sr.imu_cet_required=FALSE OR ? IS NOT NULL) AND
                (? IS NULL OR sr.min_10th_percentage IS NULL OR ? >= sr.min_10th_percentage) AND
                (? IS NULL OR sr.min_12th_percentage IS NULL OR ? >= sr.min_12th_percentage) AND
                ((sr.accepts_dns=TRUE AND ?='DNS') OR (sr.accepts_bsc=TRUE AND ?='BSc Nautical Science'))
              ) AS is_eligible
       FROM SHIPPING_COMPANIES sc
       JOIN SPONSORSHIP_REQUIREMENTS sr ON sc.company_id=sr.company_id
       ORDER BY is_eligible DESC, sc.stipend_dns DESC`,
      [pcm, eye, med, med, swim, imu, tenth, tenth, twelfth, twelfth,
       pathway, pathway, studentAge, studentAge,
       pcm, eye, med, med, swim, imu, tenth, tenth, twelfth, twelfth, pathway, pathway]);

    return res.json({ success:true,
      criteria:{ pcm, eyesight:eye, swimming_certified:swim, medical_status:med,
                 imu_cet_rank:imu, tenth_percentage:tenth, twelfth_percentage:twelfth,
                 aggregate:agg, age:studentAge, academic_pathway:pathway },
      all_companies:all, eligible_companies:all.filter(c=>c.is_eligible),
      eligible_count:all.filter(c=>c.is_eligible).length, total_companies:all.length });
  } catch(err) { console.error(err); return res.status(500).json({ success:false, message:'Server error.' }); }
};

module.exports = { checkByStudentId, checkByForm };
