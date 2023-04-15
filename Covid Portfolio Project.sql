select *
from ProjectPortfolio..CovidDeaths
where continent is not null
order by 3,4

--select *
--from ProjectPortfolio..CovidVaccinations
--order by 3,4

select Location, date,total_cases , new_cases, total_deaths,population
from ProjectPortfolio..CovidDeaths
order by 1,2

-- looking at total cases vs total deaths
-- shoes likelihood of dying if u contract covid in your country
select Location, date,total_cases , total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from ProjectPortfolio..CovidDeaths
where location like '%state%'
where continent is not null
order by 1,2

-- looking at total cases vs population
-- shows what % of population got covid
select Location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
from ProjectPortfolio..CovidDeaths
where location like '%state%'
where continent is not null
order by 1,2

-- looking at countries with highest infection rate comparted to population
select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
from ProjectPortfolio..CovidDeaths
Group by location, Population
order by PercentagePopulationInfected desc


-- showing countries with highest death counts per population
select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from ProjectPortfolio..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

-- lets break it by continent
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from ProjectPortfolio..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

-- global numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_Deaths , sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from ProjectPortfolio..CovidDeaths
--where location like '%state%'
where continent is not null
--group by date
order by 1,2

-- looking for total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations ,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location)
from ProjectPortfolio..CovidDeaths dea
join  ProjectPortfolio..CovidVaccinations vac
on dea.location =vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- use cte

with PopsvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations ,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated 
from ProjectPortfolio..CovidDeaths dea
join  ProjectPortfolio..CovidVaccinations vac
on dea.location =vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * ,(RollingPeopleVaccinated/Population)*100
from PopsvsVac

--Temp table

create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations ,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated 
from ProjectPortfolio..CovidDeaths dea
join  ProjectPortfolio..CovidVaccinations vac
on dea.location =vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * ,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--creating view to store data for later visualtizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations ,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated 
from ProjectPortfolio..CovidDeaths dea
join  ProjectPortfolio..CovidVaccinations vac
on dea.location =vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
from PercentPopulationVaccinated