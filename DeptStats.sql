-- Group by department and obtain average salary and standard deviation for each department
WITH DeptStats AS (
	SELECT Department,
			STDDEV(Salary) AS Standard_Deviation,
			AVG(Salary) AS Average,
            COUNT(*) AS Department_Count
	FROM Employee_Salaries
    WHERE Salary >= 10000
    GROUP BY Department
),
-- Identify outliers
DeptOutliers AS (
	SELECT emp.Department,
		   emp.Salary,
           dt.Standard_Deviation,
           dt.Average,
           (emp.Salary - dt.Average) / dt.Standard_Deviation as ZScore
	FROM Employee_Salaries emp
    JOIN DeptStats dt ON emp.Department = dt.Department
    WHERE emp.Salary >= 10000
)

SELECT dt.Department,
	   ROUND(dt.Average,2) AS Average_Salary,
       ROUND(dt.Standard_Deviation,2) AS Standard_Deviation,
       ROUND((dt.Standard_Deviation / dt.Average),2) AS Coefficient_of_Variation,
       dt.Department_Count,
       SUM(CASE WHEN (do.zscore > 1.96 OR do.ZScore < -1.96) THEN 1 ELSE 0 END) AS Outlier_Count
FROM DeptStats dt
LEFT JOIN DeptOutliers do ON dt.Department = do.Department
GROUP BY dt.Department, dt.Standard_Deviation, dt.Average, dt.Standard_Deviation / dt.Average
ORDER BY Outlier_Count DESC;