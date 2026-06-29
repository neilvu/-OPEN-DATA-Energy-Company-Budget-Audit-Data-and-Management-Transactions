-- [OPEN DATA] City Energy Company Budget Audit Data and Management Transactions -- 

-- TOPIC D: Income Statement [Basic Accounting Query] --

##### USE Dataset ####
USE Austin_Budget_Expenditures;
#########################

-- Important Note before the code -- 

#### ** NOTE: The following materials and files imported to this Github page are only intended for educational purposes from the open data 
#### that can be queried for related data analytics career. These datas are subjected to change that are not reflected from the actual dataset.
#### Use of any files or code for any other means (such as solication) is strictly prohibited. **


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
           IF ((t.Revenue - t.Expense) > 0, "Profit", "Deficit") AS "Profit or Loss"
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

-- During FY2016 on the 2nd Quarter (near the midterm), the energy company gained between $2-3 million in their 
-- income from their initial funding as well as their expense that were either already spent OR in the process of 
-- being spent. Given their current income as a net profit, it is still likely that they will need to consider with 
-- short and long term operations in terms how money is being used alongside with various resources in the next fiscal 
-- quarter that are depedning on resource usage that can impact their expesnses.






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
           IF ((t.Revenue - t.Expense) > 0, "Profit", "Deficit") AS "Profit or Loss"
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

-- Description: Out of the following main departments in this energy company, we figured that there were three departments 
-- that are currently being in deficit (despite needing more information to understand the hoslitic picture of the budget
-- status in many different roles and operations). 

-- Some causes of the usage of the expense that lead to possible net loss (need more info).

-- A). Exhausation of Resources (typcially those that are in demand roles for the 'backbone' of the comapny
  -- 1). Maintenance (for customer demand)
  -- 2). Labor (needed for various company operations).
  
-- ADD MORE DETAILS SOON







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
           IF ((t.Revenue - t.Expense) > 0, "Profit", "Deficit") AS "Profit or Loss"
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




-- Description: Similarity in the last part, however, the following sub-departments below from those who are marked
-- as "profit", were tose who had the following possible causes that can impact company opeations based on the funding.

-- Usage of Resources: Specific sub-departments who are in "high-demands" (e.g "Billing and Revenue Management") 
-- are the ones who exhaust their budget the most due to its increase activity demans that requires constant 
-- opeations that means more transactions in regards to labor and other associated costs. 

-- However, these specific resources allocated can be distributed varied due to the need that the coampny demeed 
-- necessary to get or receive specific goods or services, in which whether its value of operations and effectiveness
-- depends on the timing and reosurces that they can take action on that lead to the following budget transactions .





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
           IF ((t.Revenue - t.Expense) > 0, "Profit", "Deficit") AS "Profit or Loss"
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


-- Description: At this spreadsheet, we can see a broader view in terms of not only how the company had spent, 
-- but also a bigger picture baed on the specific operations that the company had encountered on its goods and 
-- services. While some company units had net profits and others went on net deficit, all income statements had
-- exhausted funds leading to their available income being less than <$200,000 million. 

-- The following reasons may possiblity lie on the following statements.

-- 1). Common Transactions: Company Units who had their most common transactiosn were usually the ones that 
-- may had spent the most, leading to possible exhasaution of funds, and that their amoung of available funds 
-- left (or net income) reflects how much money (in millions) do they have left to continue their operations.
-- Each operation that are effecitive or not depends on the amount being spent that means with the business 
-- environment that reflects their service operations requiring needing resources, including funds that can keep it 
-- running.

-- 2). Demand of Resources: As mentioned in regards to money and resources, the demand is growing for external users (e.g
-- customers, businesses and government), that requires continuing providing adqetate services that can reflect how 
-- the company is operating at a bigger fiscal and operation scale. As demand grow, so does the usage of equirpment and 
-- relevant resourcss that must be either maintained or if they are being run out (depreciated) on new resources or 
-- services are being needing more, requires money needing to keep continuting with these assets or resources.

-- More analysis needed to be considered later on.




### The most important part in the last section gives a broader view in terms of the spending behaviors the company uses that 
### can be helpful for audit analysis and tips.

-- SECTION 5: By Each Expense Name and Type

WITH income_statement_expense_type AS (
	SELECT t.company_name AS "Company Name",
		   t.FY AS "FY",
		   t.FQ AS "Quarter",
           t.exp_name AS "By Each Company Unit Role", 
		   -- Total Revenue
		   CONCAT("$", ROUND(t.Revenue), ".00")AS "Total Revenue",
		   -- Total Expentitudes (Expense)
		   CONCAT("$", ROUND(t.Expense), ".00") AS "Total Expense", 
		   -- Subtract from the following to determine net profit or income deflict 
		   -- NOTE: Determines if they have enough money to be spend on following resources used 
		   CONCAT("$", ROUND(t.Revenue - t.Expense), ".00") AS "Income Statement",
           -- Check Net Income or Income Defict by making boolean statemnt
           IF ((t.Revenue - t.Expense) > 0, "Profit", "Deficit") AS "Profit or Loss"
	-- Add the following parts htere
	FROM (SELECT Department_Name AS company_name,
				 Fiscal_Year AS FY,
				 Fiscal_Quarter AS FQ,
                 Expense_Name AS exp_name,
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
				JOIN Department_Name 
					USING(dept_id)
				JOIN Fiscal_Year
					USING(fy_id)
				JOIN Fiscal_Quarter
					USING(quarter_id)
			GROUP BY Fiscal_Year, Fiscal_Quarter, Department_Name, Expense_Name
            -- Since Amount 0 was included in the query, do not exclude it.
			HAVING Fiscal_Year = '2026' AND Fiscal_Quarter = '2' AND Department_Name = 'Austin Energy')t
	-- Omit the total income statement as 0.00, would default to "Default" otherwise by mistake.
    WHERE (Revenue - Expense) != 0
	-- Order the following
	ORDER BY FY ASC, FQ ASC)
    
SELECT *
FROM income_statement_expense_type;



-- Description: The table below shows a clear and broader of the first couple of sample sets that pictures how the 
-- company had actually paid its transactions through these list below. By showing a list of expense transaction, we can
-- get a sense of the picture based how the company provides its quality of services and resources through its business
-- operations, which manages various assets that leads whether these transactions would result in making a profit 
-- or a loss that could affect the company's operating process. 



-- A). Net Profit Explaination

-- In order for the company to provide its efficient services, the company needs to priotize which specific resources can 
-- impact their services and resources. The following list can be categorized as which ones are needed to be 
-- most to least priotized. This would provide a better organization that the company can address key business and management 
-- components of the energy company to its providers and customers.


-- Top List of Expense Priotiztion that lead to Net Profit

-- 1). Regular wages - full-time
-- 2). Maintenance-computer software
-- 3). Maintenance-gas turbines


--  B). Income Deficit

-- Another thing to note is that there are several expense types that lead to deficit, which can affect how the company can
-- provide not only to its services and resources to various consitutents, but also to employees who are in the backbone of 
-- the energy operations. It is imporant to consider how the company should manage its funds so that these resources can be
-- level appropriately thorugh its funding appropriations both the company and the city government who provides these funds 
-- for them. 

-- List of Expense that lead to Deficit

-- 1). Personnel savings (Employees)
-- 2). Holiday pay
-- 3). Terminal pay

-- These rows would be expanded to see a broader view of the company expenses as from the open data that can be yield to specifc
-- possible reasons later on in this chapter.


