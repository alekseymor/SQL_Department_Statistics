WITH DeptStats AS (
	SELECT Department,
			STDDEV(Salary) AS Standard_Deviation,
			AVG(Salary) AS Average
	FROM Employee_Salaries
    WHERE Salary >= 10000
    GROUP BY Department
),
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
	   ROUND(dt.Standard_Deviation,2) AS Standard_Deviation,
       ROUND(dt.Average,2) AS Average,
       ROUND((dt.Standard_Deviation / dt.Average),2) AS Coefficient_of_Variation,
       SUM(CASE WHEN (do.zscore > 1.96 OR do.zscore < -1.96) THEN 1 ELSE 0 END) AS Outlier_Count
FROM DeptStats dt
LEFT JOIN DeptOutliers do ON dt.Department = do.Department
GROUP BY dt.Department, dt.Standard_Deviation, dt.Average, dt.Standard_Deviation / dt.Average
ORDER BY dt.Department;