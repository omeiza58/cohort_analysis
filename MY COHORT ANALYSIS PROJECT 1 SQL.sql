

-- TOTAL NUMBER OF RECORDS = 541909
-- 2525 records have unit price = 0
-- 135080 RECORDS HAVE NO CUSTOMER ID


SELECT * FROM online_retail
WHERE customerID is  NULL


--TOTAL RECORDS IS 541909
--TOTAL RECORDS WITH CustomerID is 406829
--TOTAL RECORDS WITHOUT CustomerID IS 135080


-- CLEANING DATA
-- WE WOULD REMOVE THE MISSING VALUES FROM THE CustomerID column,
WITH online_retails AS 
(
SELECT * FROM online_retail
WHERE CustomerID IS NOT NULL
)
,quantity_unit_price AS
(

SELECT * FROM online_retails
WHERE Quantity> 0 AND UnitPrice> 0
),
duplicate_check AS
(
-- DUPLICATE CHECK
SELECT *, ROW_NUMBER() OVER (partition by InvoiceNo, StockCode, Quantity ORDER BY InvoiceDate) dup_flag
FROM quantity_unit_price
)
select * 
into #online_retail_TT-- THIS WILL PASS THE CTE INTO TEMP TABLE SO I CAN EASILY CALL THE TEMP TABLE INSTEAD OF USING CTE
FROM duplicate_check
WHERE dup_flag =1 -- THIS TELLS ME THE DATA WITHOUT DUPLICATES
-- WHERE dup_flag >1 -- THIS TELLS ME THE DATA WITH DUPLICATES


-- CALLLING ON MY TEMPTABLE(CLEAN DATA)
SELECT * FROM #online_retail_TT

-- BEGIN COHORT ANALYSIS
SELECT * FROM #online_retail_TT

-- TO CREATE A COHORT ANALYSIS I NEED...
-- A UNIQUE IDENTIFIER (CUSTOMERID)
-- INITIAL START DATE (FIRST INVOICE DATE)
-- REVENUE DATA

SELECT CustomerID,
min(InvoiceDate) AS first_purchase_date,
DATEFROMPARTS(year(min(InvoiceDate)), month(min(InvoiceDate)), 1) cohort_date
into Cohort
FROM #online_retail_TT
GROUP BY CustomerID

SELECT * 
FROM Cohort

-- CREATE CUSTOMER INDEX, THE NUMBER OF MONTHS PASSED SINCE THE CUSTOMER FIRST PURCHASE
-- COHORT INDEX SIMPLY REPRESENTS THE STAAGE OF THE CUSTOMER DURING THIS PROCESS
SELECT 
mmm.*,
cohort_index= year_diff *12 + month_diff +1
INTO cohort_retention
FROM 
(
	SELECT 
	mm.*,
	year_diff = invoice_year - cohort_year,
	month_diff = invoice_month - cohort_month
	FROM
	(
		SELECT 
		m.*,
		c. cohort_date,
		year(m.InvoiceDate) invoice_year,
		month(m.InvoiceDate) invoice_month,
		year(c.cohort_date) cohort_year,
		month(c.cohort_date) cohort_month
		FROM  #online_retail_TT m
		LEFT JOIN Cohort c
			ON m.CustomerID = c.CustomerID
	)mm
)mmm

--WHERE CustomerID = 12583 

--DELETE cohort_retention



SELECT *
FROM cohort_retention

--PIVOT DATA TO SEE COHORT TABLE
SELECT *
INTO cohort_pivot
FROM( 

SELECT DISTINCT 
CustomerID,
cohort_date, 
cohort_index
FROM cohort_retention
)TBL
PIVOT(
	COUNT(CustomerID)
	FOR cohort_index IN(
	[1],
	[2],
	[3],
	[4],
	[5],
	[6],
	[7],
	[8],
	[9],
	[10],
	[11],
	[12],
	[13])

	) AS PIVOT_TABLE
	ORDER BY cohort_date

-- THIS IS THE COHORT ANALYSIS CODE SHWING US THE NUMBER OF CUSOMERS THAT MADE A PURCHASE IN THE FIRST MONTH
-- AND THE NUMBER THAT CAME BACK IN THE FOLLOWIN MONTH AND SO ON
	SELECT *-- 1.0 * [1]/[1] *100, 1.0*[2]/[1] *100
	FROM cohort_pivot
	ORDER BY cohort_date

-- THIS ENABLES US TO SEE THE RETENTION OF CUSTOMERS MONTHLY BY THEIR PERCENTAGE IN THE COHORT ANALYSIS
	SELECT cohort_date,
	(1.0*[1]/[1]  * 100) AS [1],
	(1.0*[2]/[1]  * 100) AS [2],
	(1.0*[3]/[1]  * 100) AS [3],
	(1.0*[4]/[1]  * 100) AS [4],
	(1.0*[5]/[1]  * 100) AS [5],
	(1.0*[6]/[1]  * 100) AS [6],
	(1.0*[7]/[1]  * 100) AS [7],
	(1.0*[8]/[1]  * 100) AS [8],
	(1.0*[9]/[1]  * 100) AS [9],
	(1.0*[10]/[1]  * 100) AS [10],
	(1.0*[11]/[1]  * 100) AS [11],
	(1.0*[12]/[1]  * 100) AS [12],
	(1.0*[13]/[1]  * 100) AS [13]
	FROM cohort_pivot
	ORDER BY cohort_date




--TO KNOW HOW MANY DISTINCT COHORT INDEXES WE HAVE IN THE HOHORT RETENTION TABLE
	SELECT DISTINCT
	cohort_index
	FROM cohort_retention














