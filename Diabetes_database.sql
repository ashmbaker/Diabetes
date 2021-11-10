CREATE DATABASE reg;

CREATE TABLE reg.Patients
(Patient_ID INT PRIMARY KEY NOT NULL UNIQUE AUTO_INCREMENT, 
Last_name VARCHAR(50),
First_name VARCHAR(50),
DOB DATE,
Sex VARCHAR(50), 
Provider VARCHAR(50), 
Date_Diagnosis DATE);

LOAD DATA INFILE 'E:\HIN660_SQL\Diabetes3.csv'
into table reg.Patients
fields terminated by ','
enclosed by '"'
lines terminated by '/n'
ignore 1 rows;

CREATE TABLE reg.Glycemic
(Patient_ID INT not null REFERENCES patients (patient_id), 
A1c decimal (3,2) unique, 
Date_A1c date);

LOAD DATA LOCAL INFILE 'E:\HIN660_SQL\Glycemic3.csv'
into table reg.Glycemic
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

create table reg.Coronary
(Patient_ID int not null REFERENCES patients (patient_id), 
Systolic_BP int, 
Diastolic_BP int, 
Date_BP date, 
LDL decimal (3,2), 
Date_LDL date, 
Smoking_Status VARCHAR (50));

LOAD DATA LOCAL INFILE 'E:\HIN660_SQL\Coronary3.csv'
into table reg.Coronary
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

create table reg.Microvascular
(Patient_ID int not null REFERENCES patients (patient_id), 
alb_cr decimal (3,2), 
Date_alb_cr date, 
cr_clearance decimal (3,2), 
Date_cr_clearance date, 
DRE date);

LOAD DATA LOCAL INFILE 'E:\HIN660_SQL\Microvascular3.csv'
into table reg.Microvascular
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

Update reg.coronary
    SET Date_LDL = str_to_date(Date_LDL, '%Y-%m-%d'); 

SELECT DOB, alb_cr, LDL, A1c
  FROM reg.patients p, reg.microvascular m, reg.coronary c, reg.glycemic g
  WHERE p.patient_id = m.Patient_ID
      AND m.patient_id = c.Patient_ID
      AND c.patient_id = g.Patient_ID
      AND p.DOB = '1956-12-01'
      AND p.Patient_ID = '1'
      Group by p.patient_id ;
      
SELECT DOB, alb_cr, Date_alb_cr, LDL, Date_ldl, A1c, Date_A1c
      FROM reg.patients p, reg.microvascular m, reg.coronary c, reg.glycemic g
  WHERE p.patient_id = m.Patient_ID
      AND m.patient_id = c.Patient_ID
      AND c.patient_id = g.Patient_ID
      AND p.DOB = '1956-12-01'
      AND p.Patient_ID = '1'
      AND m.date_alb_cr = g.Date_A1c
      AND g.Date_A1c = c.Date_LDL
      group by date_alb_cr;
      
SELECT p.patient_id, DOB, Date_Diagnosis, A1c, max(Date_A1c) As recent_A1c
     FROM reg.patients p join reg.glycemic g
     on p.patient_id = g.patient_id
     group by patient_id;
     
SELECT p.patient_id, DOB, Date_Diagnosis, A1c, max(Date_A1c) As recent_A1c
     FROM reg.patients p join reg.glycemic g
     on p.patient_id = g.patient_id
     Where DOB = '1963-10-15'
     AND p.patient_ID = '16';     
     
      
Create View reg.A1C AS
    SELECT patients.Patient_id, Last_name, First_name, A1c, Date_A1c
       From reg.patients Join reg.glycemic ON reg.patients.patient_id = reg.glycemic.Patient_ID
       WHERE A1c > 6.5;

Create View reg.A1c_Sex AS
   SELECT patients.Patient_id, Last_name, First_name, sex, A1c, Date_A1c
     from reg.patients Join reg.glycemic ON reg.patients.patient_id = reg.glycemic.Patient_ID;

Create View reg.A1c_Sex_2 AS
     select sex, Round(AVG(A1c), 1)
     from reg.patients Join reg.glycemic ON reg.patients.patient_id = reg.glycemic.Patient_ID
     Group by sex;

Select * 
From reg.a1c;
Select * 
From reg.A1c_Sex;    
Select *
From reg.A1c_sex_2;

create user root_registry@localhost identified by 'diabetes';
create user 'maintenance' identified by 'diabetes';
create user 'modifier' identified by 'diabetes';
create user 'viewer' identified by 'diabetes';

grant all on reg.* to maintenance;
grant all on reg.* to root_registry@localhost with grant option;
grant select, insert, update on reg.* to modifier;

create role view_access;
grant select  
  on reg.a1c
  to view_access;
  grant select 
  on reg.a1c_sex
  to view_access;
  grant select
  on reg.a1c_sex_2
  to view_access;
  
grant view_access to viewer;


