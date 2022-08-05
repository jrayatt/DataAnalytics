Select *
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 3,4

--select *
--From PortfolioProject..CovidVaccinations$
--Order by 3,4

--Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1,2

-- Looking at total cases vs total deaths
-- shows likelihood of dying if you contracted covid in your country.

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
order by 1,2

-- loking at total cases vs population
-- Shows what percentage of population got covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
-- Where location like '%United Kingdom%'
order by 1,2

--Looking at countries with highest infection reate compared to population

Select Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
-- Where location like '%United Kingdom%'
Group by Location, population
order by PercentPopulationInfected desc

-- Showing countries with highest death count per population

Select Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths$
-- Where location like '%United Kingdom%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

--- Breaking down by continent

-- Showing continents with highest death count per population

Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths$
-- Where location like '%United Kingdom%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null
Group by date
Order by 1,2
 

 --Looking at total population vs vaccinations

 -- USE CTE

 With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population Numeric,
New_Vaccinations Numeric,
RollingPeopleVaccinated Numeric,
)


INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating view to store data for later data visulisations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select *
FROM PercentPopulationVaccinated