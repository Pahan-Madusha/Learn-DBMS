/***************************************************************/
/*				(1)			       */
/***************************************************************/

CREATE DATABASE Company;

USE Company;

CREATE TABLE employees (
emp_no INT PRIMARY KEY,
birth_date DATE,
first_name VARCHAR(14),
last_name VARCHAR(16),
sex ENUM('M','F'),
hire_date DATE
);

CREATE TABLE departments (
dept_no CHAR(4) PRIMARY KEY,
dept_name VARCHAR(40)
); 	 

CREATE TABLE dept_manager (
dept_no CHAR(4),
emp_no INT,
from_date DATE,
to_date DATE,
PRIMARY KEY(dept_no, emp_no)
);

CREATE TABLE dept_emp (
emp_no INT,
dept_no CHAR(4),
from_date DATE,
to_date DATE,
PRIMARY KEY(emp_no, dept_no)
);

CREATE TABLE titles (
emp_no INT,
title VARCHAR(50),
from_date DATE,
to_date DATE,
PRIMARY KEY(emp_no, title)
);

CREATE TABLE salaries (
emp_no INT,
salary INT,
from_date DATE,
to_date DATE,
PRIMARY KEY(emp_no, from_date, to_date)
);

source /home/pahan/DB/Lab1/load_departments.sql
source /home/pahan/DB/Lab1/load_dept_emp.sql
source /home/pahan/DB/Lab1/load_dept_manager.sql
source /home/pahan/DB/Lab1/load_employees.sql
source /home/pahan/DB/Lab1/load_salaries1.sql
source /home/pahan/DB/Lab1/load_salaries2.sql
source /home/pahan/DB/Lab1/load_salaries3.sql
source /home/pahan/DB/Lab1/load_titles.sql

ALTER TABLE dept_manager
ADD CONSTRAINT fk0
FOREIGN KEY (emp_no)
REFERENCES employees(emp_no)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE dept_manager
ADD CONSTRAINT fk1
FOREIGN KEY (dept_no)
REFERENCES departments(dept_no)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE dept_emp
ADD CONSTRAINT fk2
FOREIGN KEY (dept_no)
REFERENCES departments(dept_no)
ON DELETE CASCADE ON UPDATE CASCADE;

SELECT DISTINCT last_name FROM employees
ORDER BY last_name
LIMIT 10;

ALTER TABLE dept_emp
ADD CONSTRAINT fk3
FOREIGN KEY (emp_no)
REFERENCES employees(emp_no)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE salaries
ADD CONSTRAINT fk4
FOREIGN KEY (emp_no)
REFERENCES employees(emp_no)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE titles
ADD CONSTRAINT fk5
FOREIGN KEY (emp_no)
REFERENCES employees(emp_no)
ON DELETE CASCADE ON UPDATE CASCADE;

/***************************************************************/
/*				(2)			       */
/***************************************************************/

SELECT DISTINCT last_name FROM employees 
ORDER BY last_name
LIMIT 10;

/***************************************************************/
/*				(3)			       */
/***************************************************************/

SELECT departments.dept_name, dept_emp.dept_no, COUNT(*) FROM departments, dept_emp WHERE 
emp_no IN (SELECT emp_no FROM titles WHERE title = 'Engineer') && dept_emp.dept_no = departments.dept_no
GROUP BY dept_no;

/***************************************************************/
/*				(4)			       */
/***************************************************************/

SELECT * FROM employees WHERE emp_no IN 
(SELECT dept_manager.emp_no FROM dept_manager, titles WHERE 
dept_manager.emp_no = titles.emp_no &&
title = 'Senior Engineer') &&
sex = 'F';

/***************************************************************/
/*				(5)			       */
/***************************************************************/

SELECT salaries.emp_no, dept_name, title, salary FROM salaries, departments, dept_emp, titles WHERE 
salary > 115000 && 
salaries.emp_no = dept_emp.emp_no &&
dept_emp.dept_no = departments.dept_no &&
titles.emp_no = salaries.emp_no;

SELECT dept_name, COUNT(salaries.emp_no) FROM salaries, departments, dept_emp, titles WHERE 
salary > 115000 && 
salaries.emp_no = dept_emp.emp_no &&
dept_emp.dept_no = departments.dept_no &&
titles.emp_no = salaries.emp_no
GROUP BY dept_emp.dept_no;

/***************************************************************/
/*				(6)			       */
/***************************************************************/

SELECT first_name, 
(DATEDIFF(CURDATE(), birth_date)/365.25) AS age,
(DATEDIFF(CURDATE(), hire_date)/365.25) AS service
FROM employees WHERE
DATEDIFF(CURDATE(), birth_date)/365.25 > 50 &&
DATEDIFF(CURDATE(), hire_date)/365.25 > 10;

/***************************************************************/
/*				(7)			       */
/***************************************************************/

SELECT first_name, last_name FROM employees WHERE emp_no NOT IN
(SELECT emp_no FROM dept_emp WHERE dept_no IN
(SELECT dept_no FROM departments WHERE
dept_name = 'Human Resources'));

 
/***************************************************************/
/*				(8)			       */
/***************************************************************/

SELECT first_name FROM employees WHERE emp_no IN
(
SELECT emp_no FROM salaries WHERE salary > (SELECT MAX(salary) FROM salaries WHERE emp_no IN
(SELECT emp_no FROM dept_emp WHERE 
dept_no IN (SELECT dept_no FROM departments WHERE dept_name = 'Finance')))
);


/***************************************************************/
/*				(9)			       */
/***************************************************************/

SELECT first_name FROM employees WHERE emp_no IN
(SELECT emp_no FROM salaries WHERE salary > (SELECT AVG(salary) FROM salaries));

/***************************************************************/
/*				(10)			       */
/***************************************************************/

SELECT (SELECT AVG(salary) FROM salaries) - AVG(salary) FROM salaries WHERE emp_no IN (SELECT emp_no FROM titles WHERE title = 'Senior Engineer');

/***************************************************************/
/*				(11)			       */
/***************************************************************/

/*VIEW*/
CREATE VIEW current_dept_emp(emp_no, from_date, to_date) AS
SELECT emp_no, from_date, to_date
FROM dept_emp
WHERE to_date > CURDATE();

/***DISPLAYING CURRENT DEPARTMENT OF EACH EMPLOYEE USING THE VIEW***/
SELECT emp_no, dept_name FROM dept_emp, departments WHERE
emp_no IN (SELECT emp_no FROM current_dept_emp) &&
dept_emp.dept_no = departments.dept_no;

/***************************************************************/
/*				(12)			       */
/***************************************************************/

SELECT emp_no, dept_name FROM dept_emp, departments WHERE
to_date > CURDATE() &&
dept_emp.dept_no = departments.dept_no;

/***************************************************************/
/*				(13)			       */
/***************************************************************/

/*table to log updates*/
CREATE TABLE salary_log(
emp_no INT PRIMARY KEY,
old_salary INT,
new_salary INT,
message VARCHAR(255)
);

/*trigger*/

DELIMITER //
CREATE TRIGGER salary_update AFTER UPDATE ON salaries
FOR EACH ROW
BEGIN
	INSERT INTO salary_log VALUES (salaries.emp_no, OLD.salary, NEW.salary);
END
//
DELIMITER ;

/*print updates*/
SELECT * FROM salary_log;

/***************************************************************/
/*				(14)			       */
/***************************************************************/

DELIMITER $$

CREATE TRIGGER salary_treshold
BEFORE UPDATE ON salaries
FOR EACH ROW BEGIN

DECLARE msg VARCHAR(35);

IF (NEW.salary > OLD.salary * (1.1)) THEN
	SET msg='Salary increment is more than 10%';
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
END IF;

END $$

DELIMITER ;



