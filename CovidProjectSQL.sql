Select * 
From PortfolioProject..CovidDeaths
Where continent is not null 
Order by 3,4

-- Select * 
-- From PortfolioProject..CovidVaccionations
-- Order by 3,4

-- Select the data I will use

Select location, date, total_cases, new_cases, total_deaths, Population
From PortfolioProject..CovidDeaths
Order by 1,2

-- Looking at Total cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)
From PortfolioProject..CovidDeaths
Order by 1,2
 
 -- Converting Float datatype when Null
 -- Shows likelihood of dying if you contract covid in The United States

Select location, date, total_cases, total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..covidDeaths
Where location like '%states%'
order by 1,2

-- Looking at Total cases  vs Population 
-- Shows what percentage of population got Covid 

Select location, date, total_cases, population, 
(CONVERT(float, population) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from PortfolioProject..covidDeaths
Where location like '%states%'
order by 1,2

-- Looking at Countries with highest infection rate compared to population 

Select location, population, Max(total_cases) as HighestInfectionCount,
Max((CONVERT(float, population) / NULLIF(CONVERT(float, total_cases), 0))) * 100 AS PercentPopulationInfected
from PortfolioProject..covidDeaths
-- Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected DESC

-- Showing countries with highest death count per population 

Select location, MAX(cast(total_deaths as int)) as TotalDeathsCount
from PortfolioProject..covidDeaths
-- Where location like '%states%'
Where continent is not null 
Group by location 
order by TotalDeathsCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT 

Select continent, MAX(cast(total_deaths as int)) as TotalDeathsCount
from PortfolioProject..covidDeaths
-- Where location like '%states%'
Where continent is not null 
Group by continent 
order by TotalDeathsCount DESC


-- Showing continents with the haghiest deaths count per popuation 

Select continent, MAX(cast(total_deaths as int)) as TotalDeathsCount
from PortfolioProject..covidDeaths
-- Where location like '%states%'
Where continent is not null 
Group by continent 
order by TotalDeathsCount DESC


-- GLOBAL NUMBERS 

Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, 
SUM(new_deaths)/ SUM(NULLIF(CONVERT(float, new_cases), 0))* 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null 
Group By date 
Order by 1,2


-- Looking at total population vs vaccinations 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
 -- (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccionations vac
     On dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null 
Order by 2,3

-- USE CTE

With PopvsVac (Continent, location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
 -- (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccionations vac
     On dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null 
-- Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP TABLE 
DROP Table if exists #PrcentpopulationVaccinated
Create Table #PrcentpopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccionations numeric,
RollingPeopleVaccinated Numeric
)
Insert into #PrcentpopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
 -- (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccionations vac
     On dea.location = vac.location
     and dea.date = vac.date
-- where dea.continent is not null 

Select *, (RollingPeopleVaccinated/Population)*100
From #PrcentpopulationVaccinated

-- Creating view to store data for visualizations 

create view PrcentpopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.Date) as RollingPeopleVaccinated
 -- (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccionations vac
     On dea.location = vac.location
     and dea.date = vac.date
     where dea.continent is not null 

 Select * 
 From PrcentpopulationVaccinated   
