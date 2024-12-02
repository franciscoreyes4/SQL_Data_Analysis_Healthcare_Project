-- Step 1: Create Database and Table if they do not already exist
CREATE DATABASE IF NOT EXISTS Healthcare;
USE Healthcare;

CREATE TABLE IF NOT EXISTS healthcare (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255),
    age INT,
    medical_condition VARCHAR(255),
    test_results VARCHAR(50),
    date_of_admission DATE,
    discharge_date DATE,
    billing_amount DECIMAL(10,2),
    blood_type VARCHAR(5),
    insurance_provider VARCHAR(255),
    hospital VARCHAR(255),
    medication VARCHAR(255)
);

-- Step 2: Insert Data in Bulk
INSERT INTO healthcare (name, age, medical_condition, test_results, date_of_admission, discharge_date, billing_amount, blood_type, insurance_provider, hospital, medication)
VALUES
    ('John Doe', 45, 'Hypertension', 'Normal', '2024-11-01', '2024-11-10', 1200.50, 'O-', 'ABC Health', 'City Hospital', 'Medicine A'),
    ('Jane Smith', 30, 'Diabetes', 'Abnormal', '2024-10-15', '2024-10-25', 950.00, 'AB+', 'XYZ Insurance', 'Green Valley Hospital', 'Medicine B'),
    ('Alice Brown', 50, 'Asthma', 'Normal', '2024-09-01', '2024-09-05', 400.00, 'A+', 'ABC Health', 'City Hospital', 'Medicine C'),
    ('Bob Johnson', 25, 'Flu', 'Normal', '2024-08-01', '2024-08-03', 150.00, 'B-', 'XYZ Insurance', 'Green Valley Hospital', 'Medicine D');

-- Step 3: Create Indexes to Improve Query Performance
CREATE INDEX idx_medical_condition ON healthcare(medical_condition);
CREATE INDEX idx_age ON healthcare(age);
CREATE INDEX idx_hospital ON healthcare(hospital);

-- Step 4: Combine Aggregations
SELECT 
    COUNT(*) AS Total_Records,
    MAX(age) AS Maximum_Age,
    ROUND(AVG(age), 0) AS Average_Age
FROM healthcare;

-- Step 5: Age-Wise Hospitalized Patients (Group and Rank)
WITH AgeGroups AS (
    SELECT 
        age, 
        COUNT(*) AS Total,
        DENSE_RANK() OVER (ORDER BY COUNT(*) DESC, age DESC) AS Ranking
    FROM healthcare
    GROUP BY age
)
SELECT * FROM AgeGroups;

-- Step 6: Most Common Medical Conditions
SELECT 
    medical_condition, 
    COUNT(*) AS Total_Patients
FROM healthcare
GROUP BY medical_condition
ORDER BY Total_Patients DESC;

-- Step 7: Most Common Insurance Providers
SELECT 
    insurance_provider, 
    COUNT(*) AS Total
FROM healthcare
GROUP BY insurance_provider
ORDER BY Total DESC;

-- Step 8: Most Visited Hospitals
SELECT 
    hospital, 
    COUNT(*) AS Total
FROM healthcare
GROUP BY hospital
ORDER BY Total DESC;

-- Step 9: Average Billing by Medical Condition
SELECT 
    medical_condition, 
    ROUND(AVG(billing_amount), 2) AS Avg_Billing
FROM healthcare
GROUP BY medical_condition;

-- Step 10: Total Billing and Days Spent by Hospital
SELECT 
    medical_condition, 
    name, 
    hospital, 
    DATEDIFF(discharge_date, date_of_admission) AS Number_of_Days, 
    SUM(ROUND(billing_amount, 2)) OVER (PARTITION BY hospital ORDER BY hospital DESC) AS Total_Amount
FROM healthcare;

-- Step 11: Patient Hospitalization Days by Condition
SELECT 
    name, 
    medical_condition, 
    ROUND(billing_amount, 2) AS Billing_Amount, 
    hospital, 
    DATEDIFF(discharge_date, date_of_admission) AS Total_Hospitalized_Days
FROM healthcare;

-- Step 12: Test Results Normal with Hospitalization Days
SELECT 
    medical_condition, 
    hospital, 
    DATEDIFF(discharge_date, date_of_admission) AS Total_Hospitalized_Days, 
    test_results
FROM healthcare
WHERE test_results = 'Normal';

-- Step 13: Blood Types Between Ages 20 and 45
SELECT 
    age, 
    blood_type, 
    COUNT(blood_type) AS Count_Blood_Type
FROM healthcare
WHERE age BETWEEN 20 AND 45
GROUP BY age, blood_type;

-- Step 14: Universal Blood Donors and Receivers
SELECT 
    (SELECT COUNT(*) FROM healthcare WHERE blood_type = 'O-') AS Universal_Blood_Donors, 
    (SELECT COUNT(*) FROM healthcare WHERE blood_type = 'AB+') AS Universal_Blood_Receivers;

-- Step 15: Create Procedure for Blood Matching
DELIMITER $$

CREATE PROCEDURE Blood_Matcher(IN patient_name VARCHAR(200))
BEGIN 
    SELECT 
        D.name AS Donor_Name, 
        D.blood_type AS Donor_Blood_Type, 
        D.hospital AS Donor_Hospital, 
        R.name AS Receiver_Name, 
        R.blood_type AS Receiver_Blood_Type, 
        R.hospital AS Receiver_Hospital
    FROM healthcare D 
    INNER JOIN healthcare R 
        ON D.blood_type = 'O-' AND R.blood_type = 'AB+'
    WHERE R.name LIKE CONCAT('%', patient_name, '%');
END $$

DELIMITER ;

-- Step 16: Call the Procedure
CALL Blood_Matcher('Matthew Cruz');

-- Step 17: Admissions in 2024 and 2025
SELECT 
    hospital, 
    COUNT(*) AS Total_Admissions
FROM healthcare
WHERE YEAR(date_of_admission) BETWEEN 2024 AND 2025
GROUP BY hospital
ORDER BY Total_Admissions DESC;

-- Step 18: Billing Statistics by Insurance Provider
SELECT 
    insurance_provider, 
    ROUND(AVG(billing_amount), 2) AS Average_Billing, 
    ROUND(MIN(billing_amount), 2) AS Minimum_Billing, 
    ROUND(MAX(billing_amount), 2) AS Maximum_Billing
FROM healthcare
GROUP BY insurance_provider;

-- Step 19: Categorize Patients Based on Risk
SELECT 
    name, 
    medical_condition, 
    test_results,
    CASE 
        WHEN test_results = 'Inconclusive' THEN 'High Risk'
        WHEN test_results = 'Abnormal' THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS Risk_Level, 
    hospital
FROM healthcare;
