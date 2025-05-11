
--CLEANING 
Select* from Employee$;
--Remove extra spaces from the name
Update Employee$
Set FirstName = LTRIM(RTRIM(FirstName));

Update Employee$
Set LastName = LTRIM(RTRIM(LastName));


--Gender spelling correction
UPDATE Employee$
SET Gender = CASE
    WHEN LOWER(Gender) IN ('male', 'm') THEN 'Male'
    WHEN LOWER(Gender) IN ('female', 'f') THEN 'Female'
    WHEN LOWER(Gender) IN ('non-binary', 'nb') THEN 'Non-binary'
    ELSE Gender
END;

-- Remove any row without ID or name
Delete From Employee$
Where EmployeeID is null or FirstName is null or LastName is null;


--Remove illogical ages
Delete From  Employee$
Where Age < 18 or Age > 65;


--Delete rows with negative or illogical salaries.
Delete From Employee$
Where Salary is null or Salary <= 0;

-- Correction of hire dates
Delete From Employee$
Where HireDate is null or HireDate > GETDATE();


--Update state abbreviations to full name
Update Employee$
Set State = CASE 
    When State = 'IL' THEN 'Illinois'
    When State = 'CA' THEN 'California'
    When State = 'NY' THEN 'New York'
    Else null 
End;



Select* from PerformanceRating$;
-- Check for any NULL values
Select * From PerformanceRating$
Where
    PerformanceID is null
    or EmployeeID is null
    or ReviewDate is null
    or EnvironmentSatisfaction is null
    or JobSatisfaction is null
    or RelationshipSatisfaction is null
    or TrainingOpportunitiesWithinYear is null
    or TrainingOpportunitiesTaken is null
    or WorkLifeBalance is null
    or SelfRating is null
    or ManagerRating is null;


-- Delete rows that contain NULL
Delete From PerformanceRating$
Where 
    PerformanceID is null
    or EmployeeID is null
    or ReviewDate is null
    or EnvironmentSatisfaction is null
    or JobSatisfaction is null
    or RelationshipSatisfaction is null
    or TrainingOpportunitiesWithinYear is null
    or TrainingOpportunitiesTaken is null
    or WorkLifeBalance is null
    or SelfRating is null
    or ManagerRating is null;


-- Check future dates
Select * From PerformanceRating$
Where ReviewDate > GETDATE();


-- Checking for out-of-range values
Select * From PerformanceRating$
Where 
    EnvironmentSatisfaction not between 1 and 5
    or JobSatisfaction not between 1 and 5
    or RelationshipSatisfaction not between 1 and 5
    or WorkLifeBalance not between 1 and 5
    or SelfRating not between 1 and 5
    or ManagerRating not between 1 and 5;


-- Extracting duplicates
Select EmployeeID, ReviewDate, Count(*)
From PerformanceRating$
Group By EmployeeID, ReviewDate
Having Count(*) > 1;


-- Delete duplicates (AI)
WITH RankedDuplicates AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY EmployeeID, ReviewDate ORDER BY PerformanceID) AS rn
    FROM PerformanceRating$
)
DELETE FROM RankedDuplicates
WHERE rn > 1;

--ANALYSIS

Select* from Employee$;

-- Add Tenure Category column
Alter Table Employee$
Add TenureCategory Varchar(50);

Update Employee$
Set TenureCategory = 
Case 
  When YearsAtCompany <= 2 Then 'New'
  When YearsAtCompany <= 7 Then 'Mid'
  Else 'Senior'
End;
 
--Add Age Band column
Alter Table Employee$
Add AgeBand Varchar(50);

Update Employee$
Set AgeBand =
Case
    When Age between 18 and 25 Then '18-25'
    When Age between 26 and 35 Then '26-35'
    When Age between 36 and 45 Then '36-45'
    When Age between 46 and 60 Then '46-60'
    Else 'Above 60'
End;

-- Add Total Experience column
Alter Table Employee$
Add TotalExperience INT;

Update Employee$
Set TotalExperience = YearsAtCompany + YearsSinceLastPromotion;

-- Add Distance Category column
Alter Table Employee$
Add DistanceCategory Varchar(50);

Update Employee$
Set DistanceCategory = Case
    When [DistanceFromHome (KM)] <= 5 Then 'Near'
    When [DistanceFromHome (KM)] between 6 and 20 Then 'Medium'
    Else 'Far'
End;

--Add Salary Level column 
Alter Table Employee$
Add SalaryLevel Varchar(50);

Update Employee$
Set SalaryLevel = Case
    When Salary < 50000 Then 'Low'
    When Salary between 50000 and 100000 Then 'Medium'
    Else 'High'
End;


Select* from PerformanceRating$;

-- Add Overall Satisfaction Score column
Alter Table PerformanceRating$
Add OverallSatisfactionScore INT;

Update PerformanceRating$
Set OverallSatisfactionScore = 
    IsNull(EnvironmentSatisfaction, 0) +
    IsNull(JobSatisfaction, 0) +
    IsNull(RelationshipSatisfaction, 0) +
    IsNull(WorkLifeBalance, 0);


--Add Performance Year column
Alter Table PerformanceRating$
Add PerformanceYear INT;

Update PerformanceRating$
Set PerformanceYear = Year(ReviewDate);


--Add Performance Month column
Alter Table PerformanceRating$
Add PerformanceMonth INT;

Update PerformanceRating$
Set PerformanceMonth = Month(ReviewDate);


-- Add Self VS Manager Gap column
Alter Table PerformanceRating$
Add SelfVsManagerGap INT;

Update PerformanceRating$
Set SelfVsManagerGap = COALESCE(SelfRating, 0) - COALESCE(ManagerRating, 0);

