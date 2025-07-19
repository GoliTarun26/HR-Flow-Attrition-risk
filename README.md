# HR-Flow-Attrition-risk
HRFlow helps HR teams analyze employee attrition using cloud-scale tools. The project simulates real HR data ingestion, transforms encoded metrics, applies dimensional modeling, and builds dashboards for actionable insights—mirroring enterprise use cases.
This project demonstrates end-to-end HR Attrition Analysis using Azure Data Factory, Azure SQL, Data Lake, Power BI, and SQL for analytics.

Setup Instructions
1. Python Preprocessing

1.1 Load and Clean Dataset
	•	Load the raw HR dataset using Pandas
	•	Drop nulls and remove irrelevant columns
	•	Encode categorical fields (Gender, AttritionFlag, OverTime, etc.)

1.2 Map Encoded Data to Dimensions
	•	Generate unique IDs for JobRole, Satisfaction, Time dimensions
	•	Create cleaned dimension tables:
	•	dim_employee.csv
	•	dim_job.csv
	•	dim_satisfaction.csv
	•	dim_time.csv
	•	fact_attrition.csv
	•	Save all as CSV files for later upload to Azure Data Lake

2. Azure Cloud Setup

2.1 Create Resource Group
	•	Go to Azure Portal
	•	Navigate to: Resource Groups > Create
	•	Name: HRFlow-RG
	•	Region: East US or nearest
	•	Click Review + Create

2.2 Create Storage Account (Azure Data Lake Gen2)
	•	Go to Storage Accounts > Create
	•	Name: hrflowstorage
	•	Enable Hierarchical namespace
	•	Access Tier: Hot
	•	Create a container: clean-data
	•	Upload files:
	•	dim_employee.csv
	•	dim_job.csv
	•	dim_satisfaction.csv
	•	dim_time.csv
	•	fact_attrition.csv

2.3 Create Azure SQL Database
	•	Go to: SQL Databases > Create
	•	Name: hrflowdb
	•	Create a new SQL Server: hrflowserver
	•	Set admin username and password
	•	Click Review + Create
	•	Configure Firewall:
Allow Azure services and client IP

3. Azure Data Studio (SQL)

3.1 Connect to Azure SQL Server
	•	Use Azure Data Studio
	•	Connect using server name, username, and password

3.2 Create Tables

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
    YearsAtCompany INT
);

4. Azure Data Factory (ADF)

4.1 Create ADF Pipeline
	•	Go to ADF Studio > Author > Pipelines > New Pipeline
	•	For each csv:
	•	Add DelimitedText dataset (Source)
	•	Create linked service for Data Lake
	•	Set file path (e.g., clean-data/dim_job.csv)
	•	Add Azure SQL Database dataset (Sink)
	•	Auto-map and Debug
	•	Repeat for:
	•	Load_dim_employee
	•	Load_dim_job
- Load_dim_satisfaction
	•	Load_dim_time
	•	Load_fact_attrition

4.2 Publish Pipelines
	•	Click Publish All
	•	Pipelines will now be available in ADF monitoring

5. SQL Analytics
	•	Attrition % by education level:

SELECT
    d.Education,
    ROUND(
        100.0 * SUM(CASE WHEN f.AttritionFlag = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS AttritionPercentage
FROM fact_attrition f
JOIN dim_employee d ON f.EmployeeID = d.EmployeeID
GROUP BY d.Education;

	•	Income trends across satisfaction levels:

SELECT
    s.JobSatisfaction,
    s.EnvironmentSatisfaction,
    ROUND(AVG(f.MonthlyIncome), 2) AS AvgIncome
FROM fact_attrition f
JOIN dim_satisfaction s ON f.SatisfactionID = s.SatisfactionID
GROUP BY s.JobSatisfaction, s.EnvironmentSatisfaction;

	•	Top 5 job roles with highest attrition:

SELECT TOP 5
    j.JobRole,
    COUNT(*) AS AttritionCount
FROM fact_attrition f
JOIN dim_job j ON f.JobRoleID = j.JobRoleID
WHERE f.AttritionFlag = 'Yes'
GROUP BY j.JobRole
ORDER BY AttritionCount DESC;

	•	WorkLifeBalance impact on attrition:

SELECT
    s.WorkLifeBalance,
    COUNT(CASE WHEN f.AttritionFlag = 'Yes' THEN 1 END) AS Attritions,
    COUNT(*) AS Total,
    ROUND(100.0 * COUNT(CASE WHEN f.AttritionFlag = 'Yes' THEN 1 END) / COUNT(*), 2) AS AttritionPercentage
FROM fact_attrition f
JOIN dim_satisfaction s ON f.SatisfactionID = s.SatisfactionID
GROUP BY s.WorkLifeBalance;

6. Power BI Dashboard

6.1 Connect to Azure SQL
	•	Open Power BI Desktop
	•	Click Get Data > Azure SQL Database
	•	Enter:
	•	Server: hrflowserver.database.windows.net
	•	Database: hrflowdb
	•	Choose Import

6.2 Create Relationships (if not auto-detected)
	•	fact_attrition.EmployeeID -> dim_employee.EmployeeID
	•	JobRoleID -> dim_job.JobRoleID
	•	SatisfactionID -> dim_satisfaction.SatisfactionID

6.3 Visuals to Build
	•	Bar Chart: JobRole vs Attrition Rate
DAX Measure:

Attrition Rate % =
DIVIDE(
    CALCULATE(COUNTROWS(fact_attrition), fact_attrition[AttritionFlag] = "Yes"),
    COUNTROWS(fact_attrition),
    0
)

	•	Heatmap: JobSatisfaction vs EnvironmentSatisfaction
Use Matrix, conditional formatting
	•	Pie Chart: Attrition by Education Level
Drag Education to Legend and AttritionFlag to Filters, select Yes
	•	Slicers:
	•	Gender from dim_employee
	•	WorkLifeBalance from dim_satisfaction
	•	Department from dim_job

7. Security & Monitoring

7.1 Azure Key Vault
	•	Go to Key Vaults > Create
	•	Name: HRFlowKeyVault
	•	Add Secrets:
	•	Sql-Username
	•	Sql-Password
	•	Storage-Key
	•	In ADF > Manage > Linked Services > Use Key Vault to reference these secrets securely

7.2 Azure Monitor
	•	Go to Monitor > Diagnostic Settings
	•	Enable Logs for:
	•	PipelineRuns
	•	ActivityRuns
	•	Destination: Log Analytics Workspace or Storage Account
  Architecture diagram
  ![ARCD1](https://github.com/user-attachments/assets/fb54508c-264d-4620-8209-f252b45ddd08)

  Code Explaination 
  Clean_transform(Python script for mapping encoded data)
  We loaded the HR attrition dataset and decoded encoded metrics for better readability in dashboards:

Importing Libraries
Used pandas and numpy for data handling and transformation.

#Loading Data
df = pd.read_csv("Attrition_data.csv")
Read the raw HR dataset containing numerically encoded fields.

Data Type Conversion
Converted columns with encoded ratings to integer type (Int64) for safe mapping:

Education, JobSatisfaction, EnvironmentSatisfaction

RelationshipSatisfaction, JobInvolvement

PerformanceRating, WorkLifeBalance

Mapping Encoded Values to Labels
Mapped numerical codes to human-readable labels:

Education: 1 → "Below College", 5 → "Doctor"

Satisfaction metrics: 1 → "Low", 4 → "Very High"

PerformanceRating: 1 → "Low", 4 → "Outstanding"

WorkLifeBalance: 1 → "Bad", 4 → "Best"

#Saving the Cleaned Data
df.to_csv("Attrition_data_cleaned.csv", index=False)
Exported the cleaned dataset for use in Power BI dashboards and further analysis.

#Star Schema Creation for HR Attrition Analysis
This script restructures the cleaned HR dataset into a star schema format by creating dimension and fact tables. These tables are used for efficient reporting and dashboarding in tools like Power BI.

Step-by-Step Breakdown:

1. Load Cleaned Dataset
df = pd.read_csv("Attrition_data_cleaned.csv")

->Loads the pre-cleaned HR attrition dataset into a DataFrame.

2. Create dim_employee
dim_employee = df[['EmployeeNumber', 'Age', 'Gender', 'MaritalStatus', 'Education']].drop_duplicates()
dim_employee = dim_employee.rename(columns={'EmployeeNumber': 'EmployeeID'})

->Contains unique employee-related details.

->Renames EmployeeNumber to EmployeeID for consistency.

3. Create dim_job
dim_job = df[['Department', 'JobRole', 'OverTime']].drop_duplicates().reset_index(drop=True)
dim_job.insert(0, 'JobRoleID', range(1, len(dim_job) + 1))

->Stores unique job combinations.

->Adds a surrogate JobRoleID as a primary key.

4. Create dim_satisfaction
dim_satisfaction = df[['JobSatisfaction', 'EnvironmentSatisfaction', 'RelationshipSatisfaction',
                       'JobInvolvement', 'WorkLifeBalance']].drop_duplicates().reset_index(drop=True)
dim_satisfaction.insert(0, 'SatisfactionID', range(1, len(dim_satisfaction) + 1))

->Groups unique satisfaction profiles.

->Adds a surrogate SatisfactionID

5. Create dim_time
dim_time = df[['YearsAtCompany', 'YearsInCurrentRole']].drop_duplicates().reset_index(drop=True)
dim_time.insert(0, 'DateKey', range(1, len(dim_time) + 1))

->Captures unique combinations of tenure information.

->Adds a surrogate DateKey to act as a time dimension.

6. Prepare the Fact Table
fact_df = df[['EmployeeNumber', 'Department', 'JobRole', 'OverTime',
              'JobSatisfaction', 'EnvironmentSatisfaction', 'RelationshipSatisfaction',
              'JobInvolvement', 'WorkLifeBalance', 'MonthlyIncome',
              'Attrition', 'YearsAtCompany', 'YearsInCurrentRole']].copy()
   
->Extracts required columns from the main DataFrame for the fact table.

7. Merge Dimension Keys into Fact Table
fact_df = fact_df.merge(dim_job, on=['Department', 'JobRole', 'OverTime'], how='left')
fact_df = fact_df.merge(dim_satisfaction, on=['JobSatisfaction', 'EnvironmentSatisfaction',
                                               'RelationshipSatisfaction', 'JobInvolvement', 'WorkLifeBalance'], how='left')
fact_df = fact_df.merge(dim_time, on=['YearsAtCompany', 'YearsInCurrentRole'], how='left')
->Joins the dimension tables to the fact table to get surrogate keys (JobRoleID, SatisfactionID, DateKey).

8. Finalize and Rename Fact Table
fact_attrition = fact_df[['EmployeeNumber', 'JobRoleID', 'SatisfactionID',
                          'Attrition', 'MonthlyIncome', 'YearsAtCompany']]
fact_attrition = fact_attrition.rename(columns={
    'EmployeeNumber': 'EmployeeID',
    'Attrition': 'AttritionFlag'

}) 

->Selects only relevant fields for the fact table.

->Renames columns for clarity.

9. Export Tables to CSV
dim_employee.to_csv("dim_employee.csv", index=False)
dim_job.to_csv("dim_job.csv", index=False)
dim_satisfaction.to_csv("dim_satisfaction.csv", index=False)
dim_time.to_csv("dim_time.csv", index=False)
fact_attrition.to_csv("fact_attrition.csv", index=False)

->Saves all dimension and fact tables as separate CSV files for use in Power BI or other analytics platforms.

SQL Schema for Star Model
The following SQL script defines the star schema tables created from the cleaned HR attrition dataset. It includes dimension tables and the central fact table to support analytics and reporting.

1. dim_employee
Stores basic employee demographics.
CREATE TABLE dim_employee (
    EmployeeID INT PRIMARY KEY,
    Age INT,
    Gender VARCHAR(10),
    MaritalStatus VARCHAR(20),
    Education VARCHAR(50)
);
2. dim_job
Captures unique combinations of department, job role, and overtime status.
CREATE TABLE dim_job (
    JobRoleID INT PRIMARY KEY,
    Department VARCHAR(50),
    JobRole VARCHAR(50),
    OverTime VARCHAR(5)
);
3. dim_satisfaction
Represents unique satisfaction and engagement profiles.
CREATE TABLE dim_satisfaction (
    SatisfactionID INT PRIMARY KEY,
    JobSatisfaction VARCHAR(30),
    EnvironmentSatisfaction VARCHAR(30),
    RelationshipSatisfaction VARCHAR(30),
    JobInvolvement VARCHAR(30),
    WorkLifeBalance VARCHAR(30)
);

4. dim_time
Holds time-related attributes such as tenure.
CREATE TABLE dim_time (
    DateKey INT PRIMARY KEY,
    YearsAtCompany INT,
    YearsInCurrentRole INT
);
5. fact_attrition
Central fact table that joins all dimension tables and holds measurable data.
CREATE TABLE fact_attrition (
    EmployeeID INT,
    JobRoleID INT,
    SatisfactionID INT,
    AttritionFlag VARCHAR(5),
    MonthlyIncome FLOAT,
    YearsAtCompany INT
);
6. Sample Queries
Check table existence:
SELECT * FROM INFORMATION_SCHEMA.TABLES;

View data:
SELECT * FROM dim_employee;
SELECT * FROM dim_job;
SELECT * FROM dim_satisfaction;
SELECT * FROM dim_time;
SELECT TOP 10 * FROM fact_attrition;

SQL Insights for HR Attrition Analysis
These queries were designed to extract meaningful insights from the star schema tables created from the HR dataset.

1. Attrition by Education Level

SELECT 
    e.Education,
    ROUND(
        100.0 * SUM(CASE WHEN f.AttritionFlag = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 
        2
    ) AS AttritionPercentage
FROM fact_attrition f
JOIN dim_employee e ON f.EmployeeID = e.EmployeeID
GROUP BY e.Education;

Insight: Calculates the percentage of employees who left the company (AttritionFlag = 'Yes') across different education levels.

2. Average Monthly Income by Job Satisfaction

SELECT 
    s.JobSatisfaction,
    AVG(f.MonthlyIncome) AS AverageIncome
FROM fact_attrition f
JOIN dim_satisfaction s ON f.SatisfactionID = s.SatisfactionID
GROUP BY s.JobSatisfaction
ORDER BY AverageIncome DESC;

Insight: Displays how employee income varies with job satisfaction levels.

3. Top 5 Job Roles with Highest Attrition

SELECT 
    j.JobRole,
    COUNT(*) AS AttritionCount
FROM fact_attrition f
JOIN dim_job j ON f.JobRoleID = j.JobRoleID
WHERE f.AttritionFlag = 'Yes'
GROUP BY j.JobRole
ORDER BY AttritionCount DESC
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;

Insight: Identifies the five job roles most affected by attrition.

4. Attrition by Work-Life Balance Level

SELECT 
    s.WorkLifeBalance,
    COUNT(*) AS TotalEmployees,
    SUM(CASE WHEN f.AttritionFlag = 'Yes' THEN 1 ELSE 0 END) AS AttritionCount
FROM fact_attrition f
JOIN dim_satisfaction s ON f.SatisfactionID = s.SatisfactionID
GROUP BY s.WorkLifeBalance;

Insight: Analyzes how different levels of work-life balance relate to employee attrition.


  

