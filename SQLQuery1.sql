select * from projectsql.dbo.data1

select * from projectsql.dbo.data2

--number of rows in our data set

select count(*) from projectsql..data1
select count(*) from projectsql..data2

--data set for jharkhand and bihar

select * from projectsql..data1 where state in ('Jharkhand','Bihar')

--population of India
select sum(population) as population from projectsql..data2

--average growth of India?

select avg(growth)*100 avg_growth from projectsql..Data1;


--avg growth by states

select state,avg(growth)*100 avg_growth from projectsql..Data1 group by state;

---avg sex ratio
select round(avg(sex_ratio),0) sex_ratio  from projectsql..Data1;

--avg sex ratio by states

select state,round(avg(sex_ratio),0) avg_sex_ratio from projectsql..Data1 group by State order by avg_sex_ratio desc ;

--avg literacy rate

 select state,round(avg(literacy),0) avg_literacy_ratio from projectsql..Data1
 group by State having round(avg(literacy),0)>80 order by avg_literacy_ratio desc  ; ---having is giving condition so it must be before order by 

 -- top 3 state showing highest growth ratio
 select top 3 state,avg(growth)*100 avg_growth from projectsql..Data1 group by state order by avg_growth desc;

 ---bottom 3 statr showing lowest growth_ratio
 select top 3 state,avg(growth)*100 avg_growth from projectsql..Data1 group by state order by avg_growth asc;

 --top and bottom 3 states in literacy state
 drop table if exists #topstates ----it will drop the table if exist earlier
 create table #topstates(
 state nvarchar(255),
 topstates float
 )

 insert into #topstates
 select state,round(avg(literacy),0) avg_literacy_ratio from projectsql..Data1
 group by state order by avg_literacy_ratio desc;



 drop table if exists #bottomstates ----it will drop the table if exist earlier
 create table #bottomstates(
 state nvarchar(255),
 bottomstates float
 )

 insert into #bottomstates
 select state,round(avg(literacy),0) avg_literacy_ratio from projectsql..Data1
 group by state order by avg_literacy_ratio asc;

 select top 3 * from #bottomstates order by #bottomstates.bottomstates asc;

--union operator for join condition
select * from(select top 3 * from #topstates order by #topstates.topstates desc) a

union

select * from(
select top 3 * from #bottomstates order by #bottomstates.bottomstates asc) b;

--states starting with letter a or b

select distinct state from projectsql..data1 where lower(state) like 'a%'or lower(state) like 'b%';
--start with a and end with d
select distinct state from projectsql..data1 where lower(state) like 'a%'and lower(state) like '%d';

-- joining both table

select a.district ,a.state ,a.sex_ratio,b.population from projectsql..data1 a inner join projectsql..data2 b on a.district=b.district

--female/male=sex ratio
--female+male=population
--female=population-males
--(population-males)=(sex_ratio)*males
--population=males(sex_ratio+1)
--males=population/(sex_ratio+1)
--females=population - population/(sex_ratio+1)
--=population(1-1/(sex_ratio+1))=(population*(sex_ratio))/(sex_ratio)+1)
select c.district,c.state,round(c.population/(c.sex_ratio+1),0) males,(c.population*c.sex_ratio)/(c.sex_ratio+1),0) females from
(select a.district ,a.state ,a.sex_ratio/1000,b.population from projectsql..data1 a inner join projectsql..data2 b on a.district=b.district) c




 