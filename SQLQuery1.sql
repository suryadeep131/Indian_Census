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

select avg(growth)*100 as avg_growth from projectsql..Data1;


--avg growth by states

select state,avg(growth)*100 as avg_growth from projectsql..Data1 group by state order by avg_growth asc;

---avg sex ratio
select round(avg(sex_ratio),0) as sex_ratio  from projectsql..Data1;

--avg sex ratio by states

select state,round(avg(sex_ratio),0) as avg_sex_ratio from projectsql..Data1 group by State order by avg_sex_ratio desc ;

--avg literacy rate

 select state,round(avg(literacy),0) avg_literacy_ratio from projectsql..Data1
 group by State having round(avg(literacy),0)>80 order by avg_literacy_ratio desc  ; ---having is giving condition so it must be before order by 

 -- top 3 state showing highest growth ratio
 select top 3 state,avg(growth)*100 avg_growth from projectsql..Data1 group by state order by avg_growth desc;

 ---bottom 3 statr showing lowest growth_ratio
 select top 3 state,avg(growth)*100 avg_growth from projectsql..Data1 group by state order by avg_growth asc;

 --top and bottom 3 states in literacy state
 drop table if exists #topstates ----it will drop the table if exist earlier
 
 ---then this
 create table #topstates(
 state varchar(255),
 topstates float
 )


 --then this 
 insert into #topstates
 select state,round(avg(literacy),0) avg_literacy_ratio from projectsql..Data1
 group by state order by avg_literacy_ratio desc;
  ---then 
select top 3 * from #topstates order by #topstates.topstates desc;

---Bottom states
 drop table if exists #bottomstates ----it will drop the table if exist earlier
 create table #bottomstates(
 state varchar(255),
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
select distinct state from projectsql..data1 where lower(state) like 'a%'and lower(state) like '%s';

-- joining both table

select a.district ,a.state ,a.sex_ratio,b.population from projectsql..data1 as a inner join projectsql..data2 as b on a.district=b.district

--female/male=sex ratio
--female+male=population
--female=population-males
--(population-males)=(sex_ratio)*males
--population=males(sex_ratio+1)
--males=population/(sex_ratio+1)
--females=population - population/(sex_ratio+1)
--=population(1-1/(sex_ratio+1))=(population*(sex_ratio))/(sex_ratio)+1)

select d.state,sum(d.males) as total_males,sum(d.females) as total_females from
(select c.district,c.state state,round(c.population/(c.sex_ratio+1),0) as males, round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) as females from
(select a.district,a.state,a.sex_ratio/1000 sex_ratio,b.population from projectsql..data1 a inner join projectsql..data2 b on a.district=b.district )as  c) as d
group by d.state ;


-- total literacy rate by population


select c.state,sum(literate_people) as total_literate_pop,sum(illiterate_people) as total_Iliterate_pop from 
(select d.district,d.state,round(d.literacy_ratio*d.population,0) as literate_people,
round((1-d.literacy_ratio)* d.population,0) as illiterate_people from
(select a.district,a.state,a.literacy/100 as literacy_ratio,b.population from projectsql..data1 as a 
inner join projectsql..data2 b on a.district=b.district) as d) as c
group by c.state order by total_Iliterate_pop asc



-- population in previous census
--previous_census+growth*previous_census=population
--previous_census(1+growth)=population
--previous_census=population/(1+growth)

select sum(m.previous_census_population) as previous_census_population,sum(m.current_census_population)  as current_census_population from(
select e.state,sum(e.previous_census_population) as  previous_census_population,sum(e.current_census_population) as current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) as previous_census_population,d.population as  current_census_population from
(select a.district,a.state,a.growth as growth,b.population from projectsql..data1 as a inner join projectsql..data2 as b on a.district=b.district) as d)as  e
group by e.state) as m



 -- population vs area
 ---we used key 1 to join both the table  of total population and total area

select (g.previous_census_population/g.total_area)  as previous_census_population_vs_area, (g.current_census_population/g.total_area) as 
current_census_population_vs_area from
(select q.*,r.total_area from

(select '1' as keyy,n.* from
(select sum(m.previous_census_population) as previous_census_population,sum(m.current_census_population)  as current_census_population from(
select e.state,sum(e.previous_census_population) as  previous_census_population,sum(e.current_census_population) as current_census_population from
(select d.district,d.state,round(d.population/(1+d.growth),0) as previous_census_population,d.population as  current_census_population from
(select a.district,a.state,a.growth as growth,b.population from projectsql..data1 as a inner join projectsql..data2 as b on a.district=b.district) as d)as  e
group by e.state) as m) as n)as  q inner join (

select '1' as keyy,z.* from (
select sum(area_km2) total_area from projectsql..data2)as z)as  r on q.keyy=r.keyy) as g


--window function--ranking function

--output top 3 districts from each state with highest literacy rate


select a.* from
(select district,state,literacy,rank() over(partition by state order by literacy desc) as rnk from projectsql..data1) as a

where a.rnk in (1,2,3) order by state

