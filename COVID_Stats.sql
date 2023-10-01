select * from SQLprojects..CovidDeaths
where continent is not null and continent like 'North America'


-- Data that we will be considering

select location, date, total_cases, new_cases, total_deaths, population
from SQLprojects..CovidDeaths
order by 1,2;

--Looking at total_cases vs total_deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from SQLprojects..CovidDeaths
where location like '%Germany%' and continent is not null
order by 1,2;

--Looking at total_cases vs population

select location, date, total_cases, population, (total_cases/population)*100 as Percentage_Infection
from SQLprojects..CovidDeaths
where location like '%Germany%' and continent is not null
order by 1,2;

--Looking at countries with highest infection rate

select location, population, max(total_cases), max((total_cases/population)*100) as HighestInfectionRate
from SQLprojects..CovidDeaths
where continent is not null
group by location, population 
order by HighestInfectionRate desc

-- countries with highest death count per population

select location, max(cast(total_deaths as int)) as highestDeathCount
from SQLprojects..CovidDeaths
where continent is not null
group by location
order by highestDeathCount desc


-- Continents with highest death count per population

select continent, max(cast(total_deaths as int)) as highestDeathCount
from SQLprojects..CovidDeaths
where continent is not null
group by continent
order by highestDeathCount desc

-- Global Stats

select date, sum(new_cases) as newCases, SUM(convert(int,new_deaths)) as Deaths, SUM(convert(int,new_deaths))/sum(new_cases) * 100 as deathPercentage
from SQLprojects..CovidDeaths
where continent is not null
group by date
order by 1,2

-- Total population vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
from SQLprojects..CovidDeaths dea
join SQLprojects..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- using CTE to perform further calculation

with PopVsVac (continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
from SQLprojects..CovidDeaths dea
join SQLprojects..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population) *100 
from PopVsVac

-- creating a temp table

drop table if exists percentPopVaccinated
create table percentPopVaccinated
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into percentPopVaccinated 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
from SQLprojects..CovidDeaths dea
join SQLprojects..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/population) *100 
from percentPopVaccinated
where Location like '%Albania%'


-- creating View for Data visualization

create View PopulationVaccinatedPercentage as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated 
from SQLprojects..CovidDeaths dea
join SQLprojects..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null