-- Update popular policies view
CREATE OR REPLACE VIEW popular_policies AS
SELECT
  id, title, category, description, content, deadline,
  start_date, end_date, application_url, contact_info,
  requirements, benefits, documents, region, target_age,
  target_education, tags, image_url, status, view_count,
  popularity_score, cached_at, updated_at,
  mclsfnm, plcypvsnmthdcd, mrgsttscd, jobcd, schoolcd,
  plcymajorcd, earncndsecd, addaplyqlfccndcn,
  plcysprtcn, plcyaplymthdcn, operinstcdnm, sprvsninstcdnm,
  rgtrinstcdnm, sprttrgtminage, sprttrgtmaxage, zipcd,
  sbmsndcmntcn, refurladdr1, refurladdr2, srngmthdcn,
  etcmttrcn, operinstpicnm, sprvsninstpicnm
FROM policies
WHERE status = 'active'
  AND (end_date IS NULL OR end_date > CURRENT_DATE)
ORDER BY popularity_score DESC, view_count DESC, updated_at DESC;

-- Update deadline approaching policies view (use end_date instead of deadline)
CREATE OR REPLACE VIEW deadline_approaching_policies AS
SELECT
  id, title, category, description, content, deadline,
  start_date, end_date, application_url, contact_info,
  requirements, benefits, documents, region, target_age,
  target_education, tags, image_url, status, view_count,
  popularity_score, cached_at, updated_at,
  mclsfnm, plcypvsnmthdcd, mrgsttscd, jobcd, schoolcd,
  plcymajorcd, earncndsecd, addaplyqlfccndcn,
  plcysprtcn, plcyaplymthdcn, operinstcdnm, sprvsninstcdnm,
  rgtrinstcdnm, sprttrgtminage, sprttrgtmaxage, zipcd,
  sbmsndcmntcn, refurladdr1, refurladdr2, srngmthdcn,
  etcmttrcn, operinstpicnm, sprvsninstpicnm,
  (end_date - CURRENT_DATE) as days_until_deadline
FROM policies
WHERE status = 'active'
  AND end_date IS NOT NULL
  AND end_date > CURRENT_DATE
  AND end_date <= CURRENT_DATE + INTERVAL '30 days'
ORDER BY end_date ASC, popularity_score DESC;
