# Salaries Differences
# Write a query that calculates the difference between the highest salaries found in the marketing and engineering departments. Output just the absolute difference in salaries.
# DataFrames: db_employee, db_dept
# Expected Output Type: pandas.DataFrame
# - JOIN the department table with employee table to get a list of employees, salaries, and department
# - GROUP BY max salary by department in two different data frames
# - Extract difference of highest salaries between two departments in a different data frame

# Import your libraries
import pandas as pd

# Start writing code
emp_dept = pd.merge(db_employee, db_dept,left_on='department_id', right_on='id', how='inner')

## 1st approach 
print(abs(emp_dept.loc[emp_dept["department"] == "marketing","salary"].max()- 
 emp_dept.loc[emp_dept["department"] == "engineering","salary"].max()))

## 2nd approach
df = emp_dept.groupby('department')[['department','salary']].max()

print(df.loc[df['department'] == "marketing" ,'salary'].values - 
 df.loc[df['department'] == "engineering" ,'salary'].values) 


# Finding Updated Records
# We have a table with employees and their salaries, however, some of the records are old 
# and contain outdated salary information. Find the current salary of each employee assuming 
# that salaries increase each year. Output their id, first name, last name, department ID, 
# and current salary. Order your list by employee ID in ascending order.

ms_employee_salary.groupby('id')[ms_employee_salary.columns].max()





