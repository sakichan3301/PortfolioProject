SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths 
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths 
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathRatio
FROM CovidDeaths 
WHERE location like '%bang%' 
AND continent is not NULL
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population contracted covid
SELECT Location, Date, population, total_cases, (total_cases/population)*100 AS PercentPopulationAffected
FROM CovidDeaths 
WHERE location like '%bang%'
AND continent is not NULL
ORDER BY 1,2


--Looking at Countries with highest infection rate compared to Population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, 
MAX((total_cases/population)*100) AS PercentPopulationAffected
FROM CovidDeaths 
--WHERE location like '%bang%'
WHERE continent is not NULL
GROUP BY location, population
ORDER BY PercentPopulationAffected desc


-- Looking at Countries with Highest Death Count per Population

SELECT Location, MAX(CAST (total_deaths as int)) as TotalDeathCount 
FROM CovidDeaths 
--WHERE location like '%bang%'
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount desc


-- Showing continents with highest death counts

SELECT continent, MAX(CAST (total_deaths as int)) as TotalDeathCount 
FROM PortofolioProject1..CovidDeaths 
--WHERE location like '%bang%'
WHERE continent is not NULL 
GROUP BY continent
ORDER BY TotalDeathCount desc


-- Global Numbers Cases and Deaths Everyday

SELECT Date, SUM(new_cases) AS TotalCasesEveryday, 
             SUM(CAST(new_deaths AS int)) AS TotalDeathsPerDay,
			 (SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 AS DeathPercentage
FROM PortofolioProject1..CovidDeaths 
--WHERE location like '%bang%' 
WHERE continent is not NULL
GROUP BY date
ORDER BY 1,2 


-- GLOBAL Numbers

SELECT SUM(new_cases) AS TotalCasesEveryday, 
       SUM(CAST(new_deaths AS int)) AS TotalDeathsPerDay, 
	  (SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 AS DeathPercentage
FROM PortofolioProject1..CovidDeaths 
--WHERE location like '%bang%' 
WHERE continent is not NULL
--GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Total Vaccinations


With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,  
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER 
                           (Partition by dea.location ORDER BY dea.location, dea.date)
			                AS RollingPeopleVaccinated   
                            -- (RollingPeopleVaccinated/Population)*100
FROM CovidDeaths AS dea
     JOIN CovidVaccinations AS vac
     ON dea.location = vac.location
     AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

--USE CTE
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--TEMP Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE  #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,  
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER 
                           (Partition by dea.location ORDER BY dea.location, dea.date)
			                AS RollingPeopleVaccinated   
                            -- (RollingPeopleVaccinated/Population)*100
FROM CovidDeaths AS dea
     JOIN CovidVaccinations AS vac
     ON dea.location = vac.location
     AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for Later Visualisations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,  
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER 
                           (Partition by dea.location ORDER BY dea.location, dea.date)
			                AS RollingPeopleVaccinated   
                            -- (RollingPeopleVaccinated/Population)*100
FROM CovidDeaths AS dea
     JOIN CovidVaccinations AS vac
     ON dea.location = vac.location
     AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

