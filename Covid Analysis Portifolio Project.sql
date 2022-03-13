
Select * 
FROM dbo.CovidDeaths
Where continent is not null
Order by 3,4;

--Select * 
--FROM dbo.CovidVaccinations
--Order by 3,4;

----- Select Data that we will be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortifolioProject..CovidDeaths
Where continent is not null
Order by 1,2;

-- Looking at Total Cases VS Deaths
-- Shows the likehood of dying if you contract Covid19
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathPercentage
From PortifolioProject..CovidDeaths
Where location like '%zimbabwe%' AND continent is not null
Order by 1,2;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
Select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From PortifolioProject..CovidDeaths
Where continent is not null
--Where location like '%zimbabwe%'
Order by 1,2;

-- Looking at Countries with Highest Infection rate 
Select location, population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases)/population)*100 as HighestInfectionPercentage
From PortifolioProject..CovidDeaths
Where continent is not null
Group by location, population
Order by HighestInfectionPercentage desc;

-- Showing countries with the highest death count per Population.
Select location, MAX(cast(total_deaths as int)) as TotalDeathsCounts
From PortifolioProject..CovidDeaths
Where continent is not null
Group by location, population
Order by TotalDeathsCounts desc;


-----------------------------  Breaking down things by Continent-------------------------

Select location, MAX(cast(total_deaths as int)) as TotalDeathsCounts
From PortifolioProject..CovidDeaths
Where continent is null
Group by location
Order by TotalDeathsCounts desc;

-- Looking at Continents with Highest Death Counts

Select continent, MAX(cast(total_deaths as int)) as TotalDeathsCounts
From PortifolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathsCounts desc;

-- Global Numbers

Select date, SUM(new_cases) as TotalGlobal, SUM(cast (new_deaths as int)) as NewDeaths, SUM(cast (new_deaths as int))/ SUM(new_cases) * 100 as DeathPercentage
From PortifolioProject..CovidDeaths
Where continent is not null
Group by date
Order by TotalGlobal desc;

-- 
Select SUM(new_cases) as TotalGlobal, SUM(cast (new_deaths as int)) as NewDeaths, SUM(cast (new_deaths as int))/ SUM(new_cases)* 100 as DeathPercentage
From PortifolioProject..CovidDeaths
Where continent is not null
Order by 1,2;

---------------------------------------------------------------

Select deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations, SUM(CONVERT(bigint, vacs.new_vaccinations)) OVER (Partition by deaths.location order by deaths.location, deaths.date) as GlobalVacs
FROM PortifolioProject..CovidDeaths deaths
Join PortifolioProject..CovidVaccinations vacs  
 On deaths.location = vacs.location AND deaths.date = vacs.date
Where deaths.continent is not null
Order by 2,3;

-- Using CTE
-- If the number of columns in the selection list is different with the ones in the actual select query, the cte will have an error

With PopulationvsVacs (Continent, Location, Date, Population, NewVaccinations, GlobalVacs)
as 
(
	Select deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations, SUM(CONVERT(bigint, vacs.new_vaccinations)) OVER (Partition by deaths.location order by deaths.location, deaths.date) as GlobalVacs
FROM PortifolioProject..CovidDeaths deaths
Join PortifolioProject..CovidVaccinations vacs  
 On deaths.location = vacs.location AND deaths.date = vacs.date
Where deaths.continent is not null
--Order by 2,3
)
Select * , (GlobalVacs/Population) * 100 as VacsPercentage
From PopulationvsVacs;

--- Trying with a TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVacination 
Create table #PercentPopulationVacination 
(Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
NewVaccinations numeric, 
GlobalVacs numeric)

INSERT INTO #PercentPopulationVacination
Select deaths.continent, deaths.location, deaths.date, deaths.population, vacs.new_vaccinations, SUM(CONVERT(bigint, vacs.new_vaccinations)) OVER (Partition by deaths.location order by deaths.location, deaths.date) as GlobalVacs
FROM PortifolioProject..CovidDeaths deaths
Join PortifolioProject..CovidVaccinations vacs  
 On deaths.location = vacs.location AND deaths.date = vacs.date
Where deaths.continent is not null

Select * , (GlobalVacs/Population) * 100 as VacsPercentage
From #PercentPopulationVacination


--- Creating a View to visualise data 
Go
Create View GlobalDeathsView 
as
Select continent, MAX(cast(total_deaths as int)) as TotalDeathsCounts
From PortifolioProject..CovidDeaths
Where continent is not null
Group by continent

-- Selecting from the View
Select *
From GlobalDeathsView;
--