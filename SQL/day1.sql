CREATE TABLE employees (
    id INT,
    name VARCHAR(50),
    department VARCHAR(50),
    salary INT,
    age INT,
    city VARCHAR(50)
);
INSERT INTO employees VALUES
(1, 'Aman', 'IT', 60000, 25, 'Delhi'),
(2, 'Simran', 'HR', 50000, 30, 'Chandigarh'),
(3, 'Ravi', 'IT', 70000, 28, 'Delhi'),
(4, 'Neha', 'Finance', 65000, 35, 'Mumbai'),
(5, 'Arjun', 'IT', 55000, 26, 'Delhi'),
(6, 'Priya', 'HR', 52000, 27, 'Mumbai'),
(7, 'Karan', 'Finance', 72000, 40, 'Delhi'),
(8, 'Meena', 'IT', 48000, 24, 'Chandigarh');

select * from employees 
where salary between 60000 and 80000 
order by salary desc

select * from employees
where name like 'A%'

select * from employees 
order by salary desc
limit 3

select count(*) from employees;

select count(*) from employees
group by department;

select round(avg(salary), 2) from employees
group by department;

select max(salary) from employees
group by department;

select department from (select department, avg(salary) as average_salary from employees
group by department)
where average_salary > 60000;

select avg(salary), department from employees 
group by department 
having avg(salary) > 60000

select * from (select city, count(*) as countedEmployees from employees
group by city)
where countedEmployees > 2;

select department, avg(salary) as average from employees
group by department
order by average desc
limit 1;

select department, avg(salary), count(*) from employees
group by department
having avg(salary)>55000 and count(*) > 2

CREATE TABLE departments (
    dept_name VARCHAR(50),
    manager VARCHAR(50)
);

INSERT INTO departments VALUES
('IT', 'Raj'),
('HR', 'Anita'),
('Finance', 'Vikas'),
('Marketing', 'Suresh');

select * from departments;
select * from employees

select e.name, d.manager 
from employees as e inner join departments as d
on e.department = d.dept_name

select * from employees left join departments
on employees.department = departments.dept_name

select d.manager, count(*) as emp_count from employees e join departments d
on e.department = d.dept_name
group by d.manager

select e.*, d.manager
from employees e
left join departments d
on e.department = d.dept_name
where d.manager is null;

select d.manager, count(*) as emp_count from employees e full join departments d
on d.dept_name = e.department
group by d.manager
order by emp_count desc
limit 1

select e.city, count(*) as eCount  from employees e join departments d 
on d.dept_name = e.department
group by e.city

select d.manager, count(*) as eCount  from employees e join departments d 
on d.dept_name = e.department
group by d.manager
having count(*) > 2

select d.dept_name  from employees e right join departments d 
on d.dept_name = e.department
where e.name is null 

CREATE TABLE projects (
    project_id INT,
    employee_id INT,
    project_name VARCHAR(50)
);

INSERT INTO projects VALUES
(1, 1, 'AI'),
(2, 1, 'ML'),
(3, 3, 'Web'),
(4, 4, 'Finance App'),
(5, 7, 'Audit'),
(6, 7, 'Risk'),
(7, 7, 'Tax');

select * from projects

select e.name, count(*) from employees e join projects p
on p.employee_id = e.id
group by e.name
having count(*) > 1

select e.name, count(*) from employees e join projects p
on p.employee_id = e.id
group by e.name
-- see the difference between above one and the below one.. (above is not considering the 0) below not count null it only counts non null
-- count(*)           -- counts rows
-- count(column_name) -- counts non-null values
select e.name, count(p.project_id) as project_count
from employees e
left join projects p on p.employee_id = e.id
group by e.name;

select e.*, p.*
from employees e
left join projects p on p.employee_id = e.id
where p.project_id is null;

select e.name, count(*) from employees e join projects p
on p.employee_id = e.id
group by e.name
order by count(*) desc
limit 1

select d.dept_name, count(*) from employees e join projects p
on p.employee_id = e.id 
join departments d
on d.dept_name = e.department
group by d.dept_name
having count(*) >= 2



select *, rank() over(order by salary desc rows between UNBOUNDED PRECEDING and UNBOUNDED following ) from employees

select *, rank() over(partition by department order by salary desc rows between UNBOUNDED PRECEDING and UNBOUNDED following ) from employees


-- rank() function automatically consider this so you don't have to write it 
-- rows between unbounded preceding and unbounded following
select * from (select *, rank() over(partition by department 
order by salary desc )
as ranks
from employees) 
where ranks = 1

select * from (select *, avg(salary) over(partition by department 
order by salary desc
rows between unbounded preceding and unbounded following)
as averageSalary
from employees) 
where salary > averageSalary

-- 🔥 SQL Logical Execution Order (the one you should remember)
-- 1. FROM
-- 2. JOIN
-- 3. WHERE
-- 4. GROUP BY
-- 5. HAVING
-- 6. WINDOW FUNCTIONS (OVER)
-- 7. SELECT
-- 8. DISTINCT
-- 9. ORDER BY
-- 10. LIMIT / OFFSET

select * from (select *, rank() over(partition by department order by salary desc) as ranks
from employees)
where ranks = 2

select * from (select *, rank() over( partition by department order by salary desc) as Ranks from employees) 
where Ranks = 1 or Ranks = 2

select * from employees join departments on employees.department = departments.dept_name
join projects on projects.employee_id = employees.id

select name, salary, department, 
salary - avg(salary) over(partition by department) as EmpDiffFromAvg,
avg(salary) over(partition by department) as AverageSalary 
from employees

select *, lag(salary) over(partition by department order by salary) as PreviousEmployee_Salary from employees


-- for getting the employees with the exact same salary in there department
select *
from (
    select *, count(*) over(partition by  salary) as cnt
    from employees
) t
where cnt > 1;

select * from (
select name, department, salary,  avg(salary) over()  as companiesAverage
from employees
) t where salary > companiesAverage


select * from (select name,  department, count(*) over(partition by department) as e_counter from employees)
where e_counter < 2

select *
from (
    select *,
           ntile(10) over(
               partition by department
               order by salary desc
           ) as bucket
    from employees
) t
where bucket <= 3;

-- OR

select *
from (
    select *,
           row_number() over(
               partition by department
               order by salary desc
           ) as rn,
           count(*) over(partition by department) as total
    from employees
) t
where rn <= total * 0.3;


select * from (select department, var_samp(salary) over(partition by department ) as variance from employees
)order by variance desc
limit 1
-- or
select department, var_samp(salary) as variance
from employees
group by department
order by variance desc
limit 1;


select 
    salary, department, name,
    lead(salary) over(
        partition by department 
        order by salary
    ) as next_higher_salary
from employees;

select department, PERCENTILE_CONT(0.50) within group(order by salary) as median
from employees
group by department


select * from 
(
select *, lag(salary) over(partition by department order by salary desc) as lastOne,
lag(salary, 2) over(partition by department order by salary desc) as lastTwo
from employees
)
where salary > lastOne and salary > lastTwo


select * from (
select *, sum(salary) over(partition by department order by salary) as runningSum ,
((sum(salary) over(partition by department order by salary)) - salary) as salary_difference
from employees
) 
where salary_difference >= 0



select department
from (
    select *,
           case 
               when salary > lag(salary) over(partition by department order by salary)
               then 1 else 0 
           end as is_increasing
    from employees
) t
group by department
having min(is_increasing) = 1;

select * from (
select *, avg(salary) over(partition by department) as average_dept, 
avg(salary) over() as company_average
from employees
)
where salary > company_average and salary > average_dept




select *
from (
    select *,
           max(salary) over(
               partition by department 
               order by salary 
               rows between unbounded preceding and 1 preceding
           ) as prev_max
    from employees
) t
where salary > prev_max or prev_max is null;


-- streak length
select department, grp, count(*) as streak_length
from (
    select *,
           sum(is_break) over(partition by department order by salary) as grp
    from (
        select *,
               case 
                   when salary > lag(salary) over(partition by department order by salary)
                   then 0 else 1 
               end as is_break
        from employees
    ) t1
) t2
group by department, grp;




-- longest streak
select department, max(streak_length) as longest_streak
from (
    select department, grp, count(*) as streak_length
    from (
        select *,
               sum(is_break) over(partition by department order by salary) as grp
        from (
            select *,
                   case 
                       when salary > lag(salary) over(partition by department order by salary)
                       then 0 else 1 
                   end as is_break
            from employees
        ) t1
    ) t2
    group by department, grp
) t3
group by department;

-- ORDER TO remeber
-- FROM
-- JOIN
-- WHERE
-- GROUP BY
-- HAVING
-- WINDOW FUNCTIONS (OVER)
-- SELECT
-- DISTINCT
-- ORDER BY
-- LIMIT

select * from employees  where exists ( select 1 from projects p where p.employee_id = employees.id)

SELECT name
FROM employees
WHERE id IN (
    SELECT employee_id
    FROM projects
);

select e.name, p.* from employees e left join projects p 
on e.id = p.employee_id
where p.employee_id is null

select * from employees e 
where exists (
select 1 
from projects p
where p.employee_id = e.id
)

select e.name, e2.name, e.department from employees e join employees e2
on e.department = e2.department and e.id < e2.id

select e.name, e2.name, e.salary, e2.salary, e.department, e2.department from employees e join employees e2
on e.department = e2.department and e.id < e2.id
where e.salary > e2.salary
-- or
select distinct e.name
from employees e
join employees e2
on e.department = e2.department
where e.salary > e2.salary;

select count(*), d.manager from departments d join employees e
on d.dept_name = e.department
join projects p 
on p.employee_id = e.id
group by manager

select d.manager, count(*) as emp_count
from departments d
join employees e on d.dept_name = e.department
group by d.manager;

select d.manager, count(distinct e.id) as emp_count
from departments d
join employees e on d.dept_name = e.department
group by d.manager;


select * from departments
select p.manager, avg(e.salary) from employees e join departments p
on e.department = p.dept_name
group by manager




select p.manager, max(e.salary) from employees e join departments p
on e.department = p.dept_name
group by manager
order by max(e.salary) desc
limit 1

-- if you want the employee name as well here so we have to use the subquery
select p.manager, e.name, e.salary
from employees e
join departments p
  on e.department = p.dept_name
join (
    select p.manager, max(e.salary) as max_salary
    from employees e
    join departments p
      on e.department = p.dept_name
    group by p.manager
) t
on p.manager = t.manager 
and e.salary = t.max_salary
order by e.salary desc
limit 1;


select p.manager
from employees e
join departments p on e.department = p.dept_name
left join projects pr on pr.employee_id = e.id
group by p.manager
having count(distinct e.id) = count(distinct pr.employee_id);













