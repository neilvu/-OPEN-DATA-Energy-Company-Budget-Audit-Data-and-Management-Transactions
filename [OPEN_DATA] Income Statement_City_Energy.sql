-- [OPEN DATA] City Energy Company Budget Audit Data and Management Transactions -- 

-- TOPIC D: Income Statement [Basic Accounting Query] --

##### USE Dataset ####
USE Austin_Budget_Expenditures;
#########################


#### Review the following related acccounting links to understand what an income statement is as well as 
#### examples before programming this for audit analysis.



############################ ANALYSIS 1: Analyzing Income Statements (Accounting) ################################

### HW FOR THIS WEEK: REVIEW ACCOUTNING SKILLS FROM ONLINE SOURCES AND SEE HOW YOU UNDERSTAND THE FORMULAS, AND 
### BALANCE SHEETS BEFORE GOING BACK TO THIS CODE TO FIX IT.

-- SECTION 1). By Overall Company 

-- A). Does the company make a profit (net income) or encounter a revenue deficit (excessive spending)?**
-- ** By all revenue and expense combined on all sub-departments in a company.

-- NOTE: REPORTED BY $$ IN MILLIONS 


-- Subtract from the Net Income Equation
WITH income_statement_overall AS (
	SELECT t.company_name AS "Company Name",
		   t.FY AS "FY",
		   t.FQ AS "Quarter",
		   -- Total Revenue
		   CONCAT("$", ROUND(t.Revenue), ".00")AS "Total Revenue",
		   -- Total Expentitudes (Expense)
		   CONCAT("$", ROUND(t.Expense), ".00") AS "Total Expense", 
		   -- Subtract from the following to determine net profit or income deflict 
		   -- NOTE: Determines if they have enough money to be spend on following resources used 
		   CONCAT("$", ROUND(t.Revenue - t.Expense), ".00") AS "Income Statement",
		   -- Check Net Income or Income Defict by making boolean statemnt
           IF ((t.Revenue - t.Expense) > 0, "Profit", "Defict") AS "Profit or Loss"
	-- Add the following parts htere
	FROM (SELECT Department_Name AS company_name,
				 Fiscal_Year AS FY,
				 Fiscal_Quarter AS FQ,
				 -- Add the total revenue and expense combined (for all sub-departments)
				 SUM(Budget) AS Revenue,
				 SUM(Expenditutes) AS Expense
		   -- CONNECT THE DOTS
		   FROM Budget_Timeline BT
				JOIN Accounting_Transaction_Table ATT
					USING(trans_id)
				JOIN Transaction_Description 
					USING(trans_descrp_id)
				JOIN Expense_Type 
					USING(expense_id)
				JOIN Department_Name 
					USING(dept_id)
				JOIN Fiscal_Year
					USING(fy_id)
				JOIN Fiscal_Quarter
					USING(quarter_id)
			WHERE Fiscal_Year = '2026' AND Fiscal_Quarter = '2' AND Department_Name = 'Austin Energy' AND Budget != 0 AND Expenditutes != 0)t
	-- Order the following
	ORDER BY FY ASC, FQ ASC)
    
SELECT *
FROM income_statement_overall;





-- Description: GIVE YOUR STATEMENTS BASED ON THE NET INCOME EQUATION.











-- SECTION 2: By Each Department

WITH income_statement_department AS (
	SELECT t.company_name AS "Company Name",
		   t.FY AS "FY",
		   t.FQ AS "Quarter",
           t.dept AS "By Department", 
		   -- Total Revenue
		   CONCAT("$", ROUND(t.Revenue), ".00")AS "Total Revenue",
		   -- Total Expentitudes (Expense)
		   CONCAT("$", ROUND(t.Expense), ".00") AS "Total Expense", 
		   -- Subtract from the following to determine net profit or income deflict 
		   -- NOTE: Determines if they have enough money to be spend on following resources used 
		   CONCAT("$", ROUND(t.Revenue - t.Expense), ".00") AS "Income Statement",
		   -- Check Net Income or Income Defict by making boolean statemnt
           IF ((t.Revenue - t.Expense) > 0, "Profit", "Defict") AS "Profit or Loss"
	-- Add the following parts htere
	FROM (SELECT Department_Name AS company_name,
				 Fiscal_Year AS FY,
				 Fiscal_Quarter AS FQ,
                 Program_Name AS dept,
				 -- Add the total revenue and expense combined (for all sub-departments)
				 SUM(Budget) AS Revenue,
				 SUM(Expenditutes) AS Expense
		   -- CONNECT THE DOTS
		   FROM Budget_Timeline BT
				JOIN Accounting_Transaction_Table ATT
					USING(trans_id)
				JOIN Transaction_Description 
					USING(trans_descrp_id)
				JOIN Expense_Type 
					USING(expense_id)
				JOIN Program_Name
					USING(prog_id)
				JOIN Department_Name 
					USING(dept_id)
				JOIN Fiscal_Year
					USING(fy_id)
				JOIN Fiscal_Quarter
					USING(quarter_id)
			GROUP BY Fiscal_Year, Fiscal_Quarter, Department_Name, Program_Name
            -- Since Amount 0 was included in the query, do not exclude it.
			HAVING Fiscal_Year = '2026' AND Fiscal_Quarter = '2' AND Department_Name = 'Austin Energy')t
	-- Order the following
	ORDER BY FY ASC, FQ ASC)
    
SELECT *
FROM income_statement_department;

-- Description 





-- SECTION 3: By Each Sub-Department Name leading to Specific Company-Related Activities: 

WITH income_statement_activity AS (
	SELECT t.company_name AS "Company Name",
		   t.FY AS "FY",
		   t.FQ AS "Quarter",
           t.activity AS "By Sub-Department", 
		   -- Total Revenue
		   CONCAT("$", ROUND(t.Revenue), ".00")AS "Total Revenue",
		   -- Total Expentitudes (Expense)
		   CONCAT("$", ROUND(t.Expense), ".00") AS "Total Expense", 
		   -- Subtract from the following to determine net profit or income deflict 
		   -- NOTE: Determines if they have enough money to be spend on following resources used 
		   CONCAT("$", ROUND(t.Revenue - t.Expense), ".00") AS "Income Statement",
           -- Check Net Income or Income Defict by making boolean statemnt
           IF ((t.Revenue - t.Expense) > 0, "Profit", "Defict") AS "Profit or Loss"
	-- Add the following parts htere
	FROM (SELECT Department_Name AS company_name,
				 Fiscal_Year AS FY,
				 Fiscal_Quarter AS FQ,
                 Activity_Name AS activity,
				 -- Add the total revenue and expense combined (for all sub-departments)
				 SUM(Budget) AS Revenue,
				 SUM(Expenditutes) AS Expense
		   -- CONNECT THE DOTS
		   FROM Budget_Timeline BT
				JOIN Accounting_Transaction_Table ATT
					USING(trans_id)
				JOIN Transaction_Description 
					USING(trans_descrp_id)
				JOIN Expense_Type 
					USING(expense_id)
				JOIN List_of_Program_Activity
					USING(activity_id)
				JOIN Department_Name 
					USING(dept_id)
				JOIN Fiscal_Year
					USING(fy_id)
				JOIN Fiscal_Quarter
					USING(quarter_id)
			GROUP BY Fiscal_Year, Fiscal_Quarter, Department_Name, Activity_Name
            -- Since Amount 0 was included in the query, do not exclude it.
			HAVING Fiscal_Year = '2026' AND Fiscal_Quarter = '2' AND Department_Name = 'Austin Energy')t
	-- Order the following
	ORDER BY FY ASC, FQ ASC)
    
SELECT *
FROM income_statement_activity;




-- Description: 





### The next part gives a broader view in terms of the spending behaviors the company uses that can be helpful
### for audit tips.

-- SECTION 4: By Each Unit Name

WITH income_statement_company_unit AS (
	SELECT t.company_name AS "Company Name",
		   t.FY AS "FY",
		   t.FQ AS "Quarter",
           t.unit AS "By Each Company Unit Role", 
		   -- Total Revenue
		   CONCAT("$", ROUND(t.Revenue), ".00")AS "Total Revenue",
		   -- Total Expentitudes (Expense)
		   CONCAT("$", ROUND(t.Expense), ".00") AS "Total Expense", 
		   -- Subtract from the following to determine net profit or income deflict 
		   -- NOTE: Determines if they have enough money to be spend on following resources used 
		   CONCAT("$", ROUND(t.Revenue - t.Expense), ".00") AS "Income Statement",
           -- Check Net Income or Income Defict by making boolean statemnt
           IF ((t.Revenue - t.Expense) > 0, "Profit", "Defict") AS "Profit or Loss"
	-- Add the following parts htere
	FROM (SELECT Department_Name AS company_name,
				 Fiscal_Year AS FY,
				 Fiscal_Quarter AS FQ,
                 Unit_Name AS unit,
				 -- Add the total revenue and expense combined (for all sub-departments)
				 SUM(Budget) AS Revenue,
				 SUM(Expenditutes) AS Expense
                 -- Make the Booleans to check net income or deflict 
		   -- CONNECT THE DOTS
		   FROM Budget_Timeline BT
				JOIN Accounting_Transaction_Table ATT
					USING(trans_id)
				JOIN Transaction_Description 
					USING(trans_descrp_id)
				JOIN Expense_Type 
					USING(expense_id)
				JOIN Transaction_Unit_Type
					USING(unit_id)
				JOIN Department_Name 
					USING(dept_id)
				JOIN Fiscal_Year
					USING(fy_id)
				JOIN Fiscal_Quarter
					USING(quarter_id)
			GROUP BY Fiscal_Year, Fiscal_Quarter, Department_Name, Unit_Name
            -- Since Amount 0 was included in the query, do not exclude it.
			HAVING Fiscal_Year = '2026' AND Fiscal_Quarter = '2' AND Department_Name = 'Austin Energy')t
	-- Order the following
	ORDER BY FY ASC, FQ ASC)
    
SELECT *
FROM income_statement_company_unit;


-- Description: