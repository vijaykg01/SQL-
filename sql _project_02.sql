-- Create Database
CREATE DATABASE sql_project_02;

-- Select Database
USE sql_project_02;


-- 1. Books Table
CREATE TABLE books (
    isbn VARCHAR(20) PRIMARY KEY,
    book_title VARCHAR(150) NOT NULL,
    category VARCHAR(50),
    rental_price DECIMAL(10,2),
    status VARCHAR(20),
    author VARCHAR(100),
    publisher VARCHAR(100)
);


-- 2. Branch Table
CREATE TABLE branch (
    branch_id VARCHAR(100) PRIMARY KEY,
    manager_id VARCHAR(50),
    branch_address VARCHAR(200),
    contact_no VARCHAR(20)
);


-- 3. Employees Table
CREATE TABLE employees (
    emp_id VARCHAR(50) PRIMARY KEY,
    emp_name VARCHAR(100) NOT NULL,
    position VARCHAR(50),
    salary DECIMAL(10,2),
    branch_id VARCHAR(50),
    
    FOREIGN KEY (branch_id) REFERENCES branch(branch_id)
);


-- 4. Issued Books Table
CREATE TABLE issued_books (
    issued_id VARCHAR(100) PRIMARY KEY,
    issued_member_id VARCHAR(100),
    issued_book_name VARCHAR(150),
    issued_date DATE,
    issued_book_isbn VARCHAR(20),
    issued_emp_id VARCHAR(100),

    FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn),
    FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id)
);


-- 5. Members Table
CREATE TABLE members (
    member_id VARCHAR(100) PRIMARY KEY,
    member_name VARCHAR(100) NOT NULL,
    member_address VARCHAR(200),
    reg_date DATE
);


-- 6. Returned Books Table
CREATE TABLE returned_books (
    return_id VARCHAR(100) PRIMARY KEY,
    issued_id VARCHAR(100),
    return_book_name VARCHAR(150),
    return_date DATE,
    return_book_isbn VARCHAR(20),

    FOREIGN KEY (issued_id) REFERENCES issued_books(issued_id),
    FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);
ALTER TABLE issued_books
ADD CONSTRAINT fk_issued_member
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);

SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_books;
SELECT * FROM members;
SELECT * FROM returned_books;

-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
values('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

SELECT * FROM books;

-- Task 2: Update an Existing Member's Address

UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';

SELECT * FROM members;

-- Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

DELETE FROM issued_books
WHERE   issued_id =   'IS121';


-- Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issued_books
WHERE issued_emp_id = 'E101';


-- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT
    issued_emp_id,
    COUNT(*)
FROM issued_books
GROUP BY 1
HAVING COUNT(*) > 1;

-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

CREATE TABLE book_issued_cnt AS
SELECT b.isbn, b.book_title, COUNT(ist.issued_id) AS issue_count
FROM issued_books as ist
JOIN books as b
ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;


-- Task 7. Retrieve All Books in a Specific "Classic" Category:

SELECT * FROM books
WHERE category = 'Classic';


-- Task 8: Find Total Rental Income by Category:

SELECT 
    b.category,
    SUM(b.rental_price),
    COUNT(*)
FROM 
issued_books as ist
JOIN
books as b
ON b.isbn = ist.issued_book_isbn
GROUP BY 1;


-- Task 9: List Members Who Registered in the Last 180 Days:

SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL 180 day;


-- Task 10: List Employees with Their Branch Manager's Name and their branch details:

SELECT 
    e1.emp_id,
    e1.emp_name,
    e1.position,
    e1.salary,
    b.*,
    e2.emp_name as manager
FROM employees as e1
JOIN branch as b
ON e1.branch_id = b.branch_id    
JOIN employees as e2
ON e2.emp_id = b.manager_id;


-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:

CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price > 7.00;

select * from expensive_books;

-- Task 12: Retrieve the List of Books Not Yet Returned

SELECT * 
FROM issued_books as ist
LEFT JOIN returned_books as rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;


SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_books;
SELECT * FROM members;
SELECT * FROM returned_books;


/* Task 13: Identify Members with Overdue Books
 Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.
*/

SELECT 
	mb.member_id, 
    mb.member_name, 
    b.book_title, 
    ib.issued_date,
    datediff("2024-10-01", ib.issued_date) - 30 as over_dues
FROM issued_books ib
JOIN members mb
ON ib.issued_member_id = mb.member_id
JOIN books b
ON ib.issued_book_isbn = b.isbn
left join returned_books  rb
on ib.issued_id = rb.issued_id
WHERE rb.return_date IS NULL
AND  datediff("2024-10-01", ib.issued_date) > 30
ORDER BY 1 ;


/* Task 14: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, 
the number of books returned, and the total revenue generated from book rentals.
*/


CREATE TABLE branch_reports
AS
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) as number_book_issued,
    COUNT(rs.return_id) as number_of_book_return,
    SUM(bk.rental_price) as total_revenue
FROM issued_books as ist
JOIN employees as e
ON e.emp_id = ist.issued_emp_id
JOIN branch as b
ON e.branch_id = b.branch_id
LEFT JOIN returned_books as rs
ON rs.issued_id = ist.issued_id
JOIN books as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2;

SELECT * FROM branch_reports;


/* Task 15: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.
*/

SELECT 
    e.emp_name,
    b.*,
    COUNT(ist.issued_id) as no_book_issued
FROM issued_books as ist
JOIN employees as e
ON e.emp_id = ist.issued_emp_id
JOIN branch as b
ON e.branch_id = b.branch_id
GROUP BY 1, 2
ORDER BY no_book_issued DESC
limit 3;




