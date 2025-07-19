-- This query calculates the attrition percentage for each education level
SELECT 
    e.Education,
    ROUND(
        100.0 * SUM(CASE WHEN f.AttritionFlag = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 
        2
    ) AS AttritionPercentage
FROM fact_attrition f
JOIN dim_employee e ON f.EmployeeID = e.EmployeeID
GROUP BY e.Education;
-- This query shows average monthly income for each job satisfaction level
SELECT 
    s.JobSatisfaction,
    AVG(f.MonthlyIncome) AS AverageIncome
FROM fact_attrition f
JOIN dim_satisfaction s ON f.SatisfactionID = s.SatisfactionID
GROUP BY s.JobSatisfaction
ORDER BY AverageIncome DESC;
-- This query lists the top 5 job roles with the highest number of attritions
SELECT 
    j.JobRole,
    COUNT(*) AS AttritionCount
FROM fact_attrition f
JOIN dim_job j ON f.JobRoleID = j.JobRoleID
WHERE f.AttritionFlag = 'Yes'
GROUP BY j.JobRole
ORDER BY AttritionCount DESC
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;
-- This query shows how different levels of work-life balance affect attrition
SELECT 
    s.WorkLifeBalance,
    COUNT(*) AS TotalEmployees,
    SUM(CASE WHEN f.AttritionFlag = 'Yes' THEN 1 ELSE 0 END) AS AttritionCount
FROM fact_attrition f
JOIN dim_satisfaction s ON f.SatisfactionID = s.SatisfactionID
GROUP BY s.WorkLifeBalance;


