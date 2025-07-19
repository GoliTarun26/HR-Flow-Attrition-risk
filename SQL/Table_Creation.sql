CREATE TABLE dim_employee (
    EmployeeID INT PRIMARY KEY,
    Age INT,
    Gender VARCHAR(10),
    MaritalStatus VARCHAR(20),
    Education VARCHAR(50)
);
CREATE TABLE dim_job (
    JobRoleID INT PRIMARY KEY,
    Department VARCHAR(50),
    JobRole VARCHAR(50),
    OverTime VARCHAR(5)
);
CREATE TABLE dim_satisfaction (
    SatisfactionID INT PRIMARY KEY,
    JobSatisfaction VARCHAR(30),
    EnvironmentSatisfaction VARCHAR(30),
    RelationshipSatisfaction VARCHAR(30),
    JobInvolvement VARCHAR(30),
    WorkLifeBalance VARCHAR(30)
);
CREATE TABLE dim_satisfaction (
    SatisfactionID INT PRIMARY KEY,
    JobSatisfaction VARCHAR(30),
    EnvironmentSatisfaction VARCHAR(30),
    RelationshipSatisfaction VARCHAR(30),
    JobInvolvement VARCHAR(30),
    WorkLifeBalance VARCHAR(30)
);
CREATE TABLE dim_time (
    DateKey INT PRIMARY KEY,
    YearsAtCompany INT,
    YearsInCurrentRole INT
);
CREATE TABLE fact_attrition (
    EmployeeID INT,
    JobRoleID INT,
    SatisfactionID INT,
    AttritionFlag VARCHAR(5),
    MonthlyIncome FLOAT,
    YearsAtCompany INT,
);
SELECT * FROM INFORMATION_SCHEMA.TABLES;
SELECT * FROM dim_employee;
SELECT * FROM dim_job;
SELECT * FROM dim_satisfaction;
SELECT * FROM dim_time;
SELECT TOP 10 * FROM fact_attrition;









