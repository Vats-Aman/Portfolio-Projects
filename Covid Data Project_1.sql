Select * 
from Project..CovidDeaths
where continent is not null
order by 3,4

--Select * 
--from Project..CovidVaccinations
--order by 3,4

-- Select Data that we will be using 

Select location, date, total_cases, new_cases, total_deaths, population 
from Project..CovidDeaths
order by 1,2

-- Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths / total_cases)*100
as 'Death Percentage' from Project..CovidDeaths
where location = 'India'
and continent is not null
order by 1,2

-- Total Cases vs Population 

Select location, date, population, total_cases , (total_cases/population)*100
as 'Infection Percentage' from Project..CovidDeaths
where location = 'India'
order by 1,2

-- Countries with highest infection rate compared to population
Select location, population, max(total_cases)as Highest_infection_count, Max((total_cases/population))*100
as Infection_Percentage from Project..CovidDeaths
group by location, population
order by 'Infection_Percentage' desc

-- Highest no. of death count 
-- The data type of total_deaths is Varchar to apply max function we change it to int using cast function
select location, max(cast(total_deaths as int))
as 'Highest Deaths' from project..CovidDeaths
where continent is not null
group by location
order by 'Highest Deaths' desc

-- Check things by Continent 
select continent, max(cast(total_deaths as int))
as 'Highest Deaths' from project..CovidDeaths
where continent is not null
group by continent
order by 'Highest Deaths' desc

-- Global cases and deaths as per dates
select date, sum(new_cases) as 'Total Cases', sum(cast(new_deaths as int))as 'Total Deaths', sum(cast(new_deaths as int))/sum( new_cases)*100 as 'Death Percentage'
from project..CovidDeaths
where continent is not null
group by date 
order by 1,2

-- Total

select sum(new_cases) as 'Total Cases', sum(cast(new_deaths as int))as 'Total Deaths', sum(cast(new_deaths as int))/sum( new_cases)*100 as 'Death Percentage'
from project..CovidDeaths
where continent is not null
order by 1,2

-- Tables to join 
select * from Project..CovidDeaths dth
join Project..CovidVaccinations as vac
	on dth.location = vac.location
	and dth.date = vac.date

-- Total population vs vaccination 

select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) over (partition by dth.location order by dth.location, dth.date) as Rolling_People_Vaccinated
from project..CovidDeaths dth join project..CovidVaccinations vac 
	on dth.location = vac.location 
	and dth.date = vac.date
where dth.continent is not null
order by 2,3

-- USE CTE as we created a new column for people who got vaccinated, to check it with population we will use that column

with PopvsVac(continent, location, date, population, new_vaccinations, Rolling_People_Vaccinations)
as 
(
select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) over (partition by dth.location order by dth.location, dth.date) as Rolling_People_Vaccinated
from project..CovidDeaths dth join project..CovidVaccinations vac 
	on dth.location = vac.location 
	and dth.date = vac.date
where dth.continent is not null
--order by 2,3
)
select *,(Rolling_People_Vaccinations/population)*100
from PopvsVac 

--Drop table if exists PercentPeopleVaccinated

-- Let's Create a temp table to check what percentage of people got vaccinated 
create table PercentPeopleVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric, 
new_vaccination numeric, 
Rolling_People_Vaccinated numeric)

insert into PercentPeopleVaccinated
select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) over (partition by dth.location order by dth.location, dth.date) as Rolling_People_Vaccinated
from project..CovidDeaths dth join project..CovidVaccinations vac 
	on dth.location = vac.location 
	and dth.date = vac.date
where dth.continent is not null

select *, (Rolling_People_Vaccinated/population)*100
from PercentPeopleVaccinated


-- Create a view to visualize the data 

create view PercentPeopleVaccinated_1 as 
select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, 
sum(convert(bigint, vac.new_vaccinations)) over (partition by dth.location order by dth.location, dth.date) as Rolling_People_Vaccinated
from project..CovidDeaths dth join project..CovidVaccinations vac 
	on dth.location = vac.location 
	and dth.date = vac.date
where dth.continent is not null

select * from PercentPeopleVaccinated_1