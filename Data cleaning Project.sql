-- Data cleaning 

Select *
from layoffs
;

-- 1. Remove Duplicates
-- 2. Standardize the data
-- 3. Nulls and Blank values 
-- 4. Remove any columns 

Create table layoffs_staging
like layoffs;

select *
from layoffs_staging2;

insert into layoffs_staging
select *
from layoffs
;

-- Starting by creating ids for the data 

select *,
Row_number() over( 
partition by  company,location,industry,total_laid_off,perecentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from layoffs_staging
;

with duplicate_cte as 
(
select *,
Row_number() over( 
partition by  company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from layoffs_staging
)
Select *
from duplicate_cte
where row_num > 1
;

-- creating a new table again from layoffs with row_num so that we can delete the duplicates 

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select *
from layoffs_staging2;

insert into layoffs_staging2
select *,
row_number() over(
partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from layoffs_staging
;

Delete
from layoffs_staging2
where row_num > 1;

-- Standardizing Data

select company,trim(company)
from layoffs_staging2
;

update layoffs_staging2
set  company = trim(company)
;

select distinct industry
from layoffs_staging2
order by 1;


select *
from layoffs_staging2
where industry like 'crypto%'
;

update layoffs_staging2
set industry = 'Crypto'
where industry like 'crypto%'
;

select distinct country, Trim( trailing '.' from country)
from layoffs_staging2
order by 1;

update layoffs_staging2
set country = Trim( trailing '.' from country)
like 'United States%';

select `date`,
str_to_date(`date`,'%m/%d/%Y')
from layoffs_staging2
;

update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y')
;

alter table layoffs_staging2
modify column `date` Date 
;

-- Null values and Blank values 


select *
from layoffs_staging2
where industry is null 
or industry = '' ;

select *
from layoffs_staging2
where company = 'Airbnb'
;

select *
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company = t2.company 
	and t1.location =t2.location
where (t1.industry is null or t1.industry = '') 
and t2.industry is not null
;

update layoffs_staging2
set industry = null
where industry = '';

update layoffs_staging2 t1 
join layoffs_staging2 t2
	on t1.company = t2.company 
set t1.industry = t2.industry 
where (t1.industry is null or t1.industry = '') 
and t2.industry is not null
;

-- Removing columns 

select *
from layoffs_staging2
where total_laid_off is Null 
and percentage_laid_off is null;


Delete 
from layoffs_staging2
where total_laid_off is Null 
and percentage_laid_off is null;

Alter table layoffs_staging2
drop column row_num;

select *
from layoffs_staging2
;







