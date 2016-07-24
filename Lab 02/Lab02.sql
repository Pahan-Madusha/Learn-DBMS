/***************************************************************/
/*						(1)    								   */
/***************************************************************/

/*Select with no index*/
/*
mysql> EXPLAIN SELECT first_name FROM employees  ORDER BY first_name;
+----+-------------+-----------+------+---------------+------+---------+------+--------+----------------+
| id | select_type | table     | type | possible_keys | key  | key_len | ref  | rows   | Extra          |
+----+-------------+-----------+------+---------------+------+---------+------+--------+----------------+
|  1 | SIMPLE      | employees | ALL  | NULL          | NULL | NULL    | NULL | 300008 | Using filesort |
+----+-------------+-----------+------+---------------+------+---------+------+--------+----------------+
1 row in set (0.00 sec)
*/

SELECT first_name FROM employees 
ORDER BY first_name;

/*****  Time *****/
/*
	300024 rows in set (0.28 sec)
*/


/***************************************************************/
/*						(2)	     							   */
/***************************************************************/

/*creating index*/
CREATE INDEX fname_index ON employees(first_name);

/*Select with index*/
/*
mysql> EXPLAIN SELECT first_name FROM employees  ORDER BY first_name;
+----+-------------+-----------+-------+---------------+-------------+---------+------+--------+-------------+
| id | select_type | table     | type  | possible_keys | key         | key_len | ref  | rows   | Extra       |
+----+-------------+-----------+-------+---------------+-------------+---------+------+--------+-------------+
|  1 | SIMPLE      | employees | index | NULL          | fname_index | 17      | NULL | 300008 | Using index |
+----+-------------+-----------+-------+---------------+-------------+---------+------+--------+-------------+
1 row in set (0.00 sec)
*/

SELECT first_name FROM employees 
ORDER BY first_name;


/*****  Time *****/
/*
	300024 rows in set (0.15 sec)
*/


/*
	Performance improved
*/


/***************************************************************/
/*							(3)							       */
/***************************************************************/

/*
BTREE indexing technique is used
*/


/***************************************************************/
/*							(4)			   					   */
/***************************************************************/

/*Select without index*/
/*
mysql> EXPLAIN SELECT emp_no, first_name, last_name FROM employees ORDER BY first_name;
+----+-------------+-----------+-------+---------------+-------------+---------+------+--------+-----------------------------+
| id | select_type | table     | type  | possible_keys | key         | key_len | ref  | rows   | Extra                       |
+----+-------------+-----------+-------+---------------+-------------+---------+------+--------+-----------------------------+
|  1 | SIMPLE      | employees | index | NULL          | NULL        | 40      | NULL | 300008 | Using index; Using filesort |
+----+-------------+-----------+-------+---------------+-------------+---------+------+--------+-----------------------------+
1 row in set (0.01 sec)

*/

SELECT emp_no, first_name, last_name FROM employees 
ORDER BY emp_no, first_name, last_name;

/*****  Time *****/
/*
	300024 rows in set (0.34 sec)
*/


/*creating index*/
CREATE UNIQUE INDEX UniqueIndex
ON employees (emp_no,first_name,last_name);

/*Select with index*/
/*
mysql> explain SELECT emp_no, first_name, last_name FROM employees ORDER BY first_name;
+----+-------------+-----------+-------+---------------+-------------+---------+------+--------+-----------------------------+
| id | select_type | table     | type  | possible_keys | key         | key_len | ref  | rows   | Extra                       |
+----+-------------+-----------+-------+---------------+-------------+---------+------+--------+-----------------------------+
|  1 | SIMPLE      | employees | index | NULL          | UniqueIndex | 40      | NULL | 300008 | Using index; Using filesort |
+----+-------------+-----------+-------+---------------+-------------+---------+------+--------+-----------------------------+
1 row in set (0.01 sec)
*/

SELECT * FROM employees 
ORDER BY emp_no, first_name, last_name;

/*****  Time *****/
/*
	300024 rows in set (0.24 sec)
*/

/*
Performance is improved
*/


/***************************************************************/
/*								(5)						       */
/***************************************************************/

/*
(i)
*/

/*
    from_date should be selected as the attribute for the simple index.  
    Because, all the select statements use from_date to filter data. 
    dept_no should not be used, because there are only 8 departments and
    it will not improve performance much.
*/  

CREATE INDEX FromDateIndex ON dept_manager (from_date);

/*
(ii)
*/

EXPLAIN SELECT DISTINCT emp_no FROM dept_manager WHERE from_date>='1985-01-01' AND dept_no >= 'd005';
/*
+----+-------------+--------------+-------+-----------------------+---------+---------+------+------+------------------------------+
| id | select_type | table        | type  | possible_keys         | key     | key_len | ref  | rows | Extra                        |
+----+-------------+--------------+-------+-----------------------+---------+---------+------+------+------------------------------+
|  1 | SIMPLE      | dept_manager | range | PRIMARY,FromDateIndex | PRIMARY | 4       | NULL |   14 | Using where; Using temporary |
+----+-------------+--------------+-------+-----------------------+---------+---------+------+------+------------------------------+
1 row in set (0.00 sec)
*/

EXPLAIN SELECT DISTINCT emp_no FROM dept_manager WHERE from_date>='1996-01-03' AND dept_no >= 'd005';

/*
mysql> EXPLAIN SELECT DISTINCT emp_no FROM dept_manager WHERE from_date>='1996-01-03' AND dept_no >= 'd005';
+----+-------------+--------------+-------+-----------------------+---------------+---------+------+------+-------------------------------------------+
| id | select_type | table        | type  | possible_keys         | key           | key_len | ref  | rows | Extra                                     |
+----+-------------+--------------+-------+-----------------------+---------------+---------+------+------+-------------------------------------------+
|  1 | SIMPLE      | dept_manager | range | PRIMARY,FromDateIndex | FromDateIndex | 4       | NULL |    2 | Using where; Using index; Using temporary |
+----+-------------+--------------+-------+-----------------------+---------------+---------+------+------+-------------------------------------------+
1 row in set (0.00 sec)
*/

EXPLAIN SELECT DISTINCT emp_no FROM dept_manager WHERE from_date>='1985-01-01' AND dept_no <= 'd009';

/*
mysql> EXPLAIN SELECT DISTINCT emp_no FROM dept_manager WHERE from_date>='1985-01-01' AND dept_no <= 'd009';
+----+-------------+--------------+-------+-----------------------+------+---------+------+------+-------------+
| id | select_type | table        | type  | possible_keys         | key  | key_len | ref  | rows | Extra       |
+----+-------------+--------------+-------+-----------------------+------+---------+------+------+-------------+
|  1 | SIMPLE      | dept_manager | index | PRIMARY,FromDateIndex | fk   | 4       | NULL |   24 | Using where |
+----+-------------+--------------+-------+-----------------------+------+---------+------+------+-------------+
1 row in set (0.00 sec)
*/

/*
   The index that we created is in the possible key list for all 3 select queries.   
*/


/***************************************************************/
/*								(6)			      			   */
/***************************************************************/

/*
	(2) The family names were ordered by last_name in this query.
		Therefore index should be created
		for last_name on employees relation

	(3) Engineers' emp_no must be selected from titles relation.
		Therefore index shoould be created
		for title on titles relation

	(4) We have to select employees who were Senior Engineeers and 
		now managers. Since both conditions involve title,
		Indexing should be done 
		for title on titles relation

	(5) Since major filtering is done considering salary,
		Indexing should be done 
		for salary on salaries relation

	(6) We have to filter people who were hired earliest
		Therefore index should be created 
		for hire_date on employees relation

	(7) Since we have omit the employee from particular department
		Indexing should be done 
		for dept_no on dept_emp relation 

	(8) Both nested queries for this select involve salary,
		Therefore index should be created
		for salary in salaries relation

	(9) All queries for this select involve salary,
		Therefore index should be created
		for salary in salaries relation

	(10) We have to find the salaries of Senior Engineers 
		 seperately. Taking average doesn't need any soring.
		 Therefore we have create an index 
		 for title in titles relation.

*/

/***************************************************************/
/*								(7)			      			   */
/***************************************************************/

/*
   When most queries are updates/deletes/inserts, the query execution time with an index 
   will most probably be higher than when it has no index.
   Because some updates/deletes/inserts may force a page split or key values change. 
   This may cause the index to be reorganized, impacting other indexes and operations and 
   resulting in slower performance than with no index.
*/

