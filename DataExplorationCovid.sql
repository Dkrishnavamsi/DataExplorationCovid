select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

-- select Data we are going to be using

select Location, date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths

select Location, date,population,total_cases,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
-- where location like '%India%'
order by 1,2


-- Looking at countries with Highest infection rate compared to population
select Location, Population, max(total_cases) as HighestInfectionCount, max((total_cases/Population)*100) as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
-- where location like '%India%'
group by Location, population
order by 4 desc


-- Looking at countries with Highest death rate compared to population
select Location, Population, max(cast(total_deaths as int)) as TotalDeathCount, max((total_deaths/Population)*100) as PercentPopulationDied
from PortfolioProject..CovidDeaths
where continent is not null
-- where location like '%India%'
group by Location, population
order by 3 desc


-- Breaking Things Down by continent
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
-- where location like '%India%'
group by continent
order by 2 desc

-- showing continents with highest death count per population
select continent, max(total_deaths/population)*100 as TotalDeathPerPopulation
from PortfolioProject..CovidDeaths
where continent is not null
-- where location like '%India%'
group by continent
order by 2 desc


-- Global Numbers
select  sum(new_cases) as Total_cases, sum(CAST(new_deaths as int)) as Total_deaths, sum(CAST(new_deaths as int))*100/sum(new_cases) as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
-- where location like '%India%'
--group by date
order by 1,2


-- Loking at Total Population vs Vaccinations
select dea.continent , dea.location ,dea.date, dea.population, vac.new_vaccinations
,sum(CONVERT(int,vac.new_vaccinations)) over (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/dea.population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
  on dea.location=vac.location and dea.date= vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

with PopvsVac (Continent,Location,Date,Population, new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent , dea.location ,dea.date, dea.population, vac.new_vaccinations
,sum(CONVERT(int,vac.new_vaccinations)) over (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/dea.population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
  on dea.location=vac.location and dea.date= vac.date
where dea.continent is not null
--order by 2,3
)

select * ,(RollingPeopleVaccinated/Population)*100
from PopvsVac


-- Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent , dea.location ,dea.date, dea.population, vac.new_vaccinations
,sum(CONVERT(int,vac.new_vaccinations)) over (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/dea.population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
  on dea.location=vac.location and dea.date= vac.date
--where dea.continent is not null
--order by 2,3

select * ,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


-- Creating view to store data for later visualization

Create View  PercentPeopulationVaccinated as
select dea.continent , dea.location ,dea.date, dea.population, vac.new_vaccinations
,sum(CONVERT(int,vac.new_vaccinations)) over (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/dea.population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
  on dea.location=vac.location and dea.date= vac.date
where dea.continent is not null
--order by 2,3

Select * 
From PercentPeopulationVaccinated