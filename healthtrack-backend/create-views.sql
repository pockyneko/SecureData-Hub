-- Create the v_user_personalized_standards view
-- This view combines user health profiles with health standards for personalized recommendations

DROP VIEW IF EXISTS v_user_personalized_standards;

CREATE VIEW v_user_personalized_standards AS
SELECT 
    uhp.user_id,
    uhp.id as profile_id,
    u.identifier as username,
    u.email,
    uhp.age,
    uhp.gender,
    uhp.height,
    uhp.weight,
    uhp.activity_level,
    ROUND(uhp.weight / ((uhp.height / 100) * (uhp.height / 100)), 2) as bmi,
    hsr.standard_type,
    hsr.age_group,
    hsr.activity_category,
    hsr.min_value,
    hsr.max_value,
    hsr.unit,
    hsr.description,
    COALESCE(
        CASE 
            WHEN hsr.age_group = '18-30' AND uhp.age BETWEEN 18 AND 30 THEN 1
            WHEN hsr.age_group = '31-50' AND uhp.age BETWEEN 31 AND 50 THEN 1
            WHEN hsr.age_group = '51-70' AND uhp.age BETWEEN 51 AND 70 THEN 1
            WHEN hsr.age_group = '70+' AND uhp.age > 70 THEN 1
            ELSE 0
        END,
        0
    ) as is_applicable_age,
    COALESCE(
        CASE 
            WHEN hsr.activity_category = uhp.activity_level THEN 1
            WHEN hsr.activity_category IS NULL OR hsr.activity_category = '' THEN 1
            ELSE 0
        END,
        0
    ) as is_applicable_activity,
    uhp.created_at,
    uhp.updated_at
FROM user_health_profiles uhp
INNER JOIN users u ON uhp.user_id = u.id
LEFT JOIN health_standards_reference hsr ON 1=1;
