/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select the data that we will be using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at the Total cases vs total deaths
-- Shows the likelihood of dying if you contract covid in your country 

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
FROM PortfolioProject..covidDeaths
WHERE location LIKE '%states%'
order by 1,2

--Looking at the total cases vs the population
--shows percentage of population that contracted covid

Select location, date, total_cases, population, 
(CONVERT(float, total_cases ) / NULLIF(CONVERT(float, population), 0))* 100 AS Deathpercentage
FROM PortfolioProject..covidDeaths
WHERE location LIKE '%states%'
order by 1,2

--Looking at countries with highest infection rate compared to population

Select location,population, MAX(total_cases) as HighestInfectionCount,
MAX(CONVERT(float, total_cases ) / NULLIF(CONVERT(float, population), 0))* 100 AS PercentPopulationInfected
FROM PortfolioProject..covidDeaths
--WHERE location LIKE '%states%'
GROUP BY population, location
ORDER BY PercentPopulationInfected DESC


-- Showing countries with the highest death count per population

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..covidDeaths
WHERE continent is not null
GROUP BY population, location
ORDER BY TotalDeathCount DESC




--Showing continents with the highest death counts

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC





-- GLobal numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


--Looking at total Population vs Vaccinations

SELECT dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location 
ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent is not null
order by 1,2;


-- Use a CTE 

WITH PopvsVac (continent, location,  date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(

SELECT dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location 
ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent is not null
--order by 1,2;
)

SELECT * , (RollingPeopleVaccinated/population)*100
FROM PopvsVac



--Temp Table 
DROP TABLE IF EXISTS #PercentPopVaccinated
CREATE TABLE #PercentPopVaccinated
(
continent NVARCHAR(255), 
location NVARCHAR(255),
date DATETIME, 
population NUMERIC, 
new_vaccinations NUMERIC, 
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopVaccinated(continent,date,location,population,new_vaccinations, RollingPeopleVaccinated)
SELECT dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location 
ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	--WHERE dea.continent is not null
--order by 1,2;

SELECT * , (RollingPeopleVaccinated/population)*100
FROM #PercentPopVaccinated

-- Creating view to store data for later visualizations

CREATE VIEW PercentPopVaccinated AS
SELECT dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location 
ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent is not null
--order by 2,3


CREATE VIEW GlobeNum AS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
--order by 1,2;