SELECT *
FROM SQL_projects..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM SQL_projects..CovidVaccinations
--ORDER BY 3,4


--Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM SQL_projects..CovidDeaths
ORDER BY 1,2


--Looking at total cases vs total deaths

--shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deathpercentage
FROM SQL_projects..CovidDeaths
WHERE location like '%Philippines%'
ORDER BY 1,2


--looking at the total cases vs population

--shows what percentage of population got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS percentpopulationinfected
FROM SQL_projects..CovidDeaths
WHERE location like '%Philippines%'
ORDER BY 1,2


--looking at countries with highest infection rate compared to population
--Tableau table #3

SELECT location, population, MAX(total_cases) AS HighestInfectionCount,
MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM SQL_projects..CovidDeaths
--WHERE location like '%Philippines%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


--showing countries with highest death count per population

SELECT location, MAX(CAST(total_deaths AS int)) AS totaldeathcount
FROM SQL_projects..CovidDeaths
--WHERE location like '%Philippines%'
WHERE continent IS NOT null
GROUP BY location
ORDER BY totaldeathcount DESC


--let's break things down by continent

--showing continents with highest death count per population

SELECT continent, MAX(CAST(total_deaths AS int)) AS totaldeathcount
FROM SQL_projects..CovidDeaths
--WHERE location like '%Philippines%'
WHERE continent IS NOT null
GROUP BY continent
ORDER BY totaldeathcount DESC


--global numbers
--tableau table #1

SELECT SUM(new_cases) AS totalcases, SUM(CAST(new_deaths AS int)) AS totaldeaths, 
SUM(CAST(new_deaths AS int))/SUM(new_cases)*100  AS deathpercentage
FROM SQL_projects..CovidDeaths
--WHERE location like '%Philippines%' 
WHERE continent IS NOT null
--GROUP BY date
ORDER BY 1,2


--looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(CONVERT(int, vac.new_vaccinations)) 
		OVER (PARTITION BY  dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevaccinated,
		--(rollingpeoplevaccinated/population)*100
FROM SQL_projects..CovidDeaths dea
JOIN SQL_projects..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE DEA.continent IS NOT null
ORDER BY 2,3


--use cte

WITH popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(CONVERT(int, vac.new_vaccinations)) 
		OVER (PARTITION BY  dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevaccinated
		--(rollingpeoplevaccinated/population)*100
FROM SQL_projects..CovidDeaths dea
JOIN SQL_projects..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE DEA.continent IS NOT null
--ORDER BY 2,3
)
SELECT *, (rollingpeoplevaccinated/population)*100
FROM popvsvac


--temp table

DROP TABLE IF EXISTS #percentpopulationvaccinated
CREATE TABLE #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)
INSERT INTO #percentpopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(CONVERT(int, vac.new_vaccinations)) 
		OVER (PARTITION BY  dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevaccinated
		--(rollingpeoplevaccinated/population)*100
FROM SQL_projects..CovidDeaths dea
JOIN SQL_projects..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE DEA.continent IS NOT null
--ORDER BY 2,3

SELECT *, (rollingpeoplevaccinated/population)*100
FROM #percentpopulationvaccinated


--creating view to store data for later visualizations

CREATE VIEW percentpopulationvaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(CONVERT(int, vac.new_vaccinations)) 
		OVER (PARTITION BY  dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevaccinated
		--(rollingpeoplevaccinated/population)*100
FROM SQL_projects..CovidDeaths dea
JOIN SQL_projects..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE DEA.continent IS NOT null
--ORDER BY 2,3

SELECT *
FROM percentpopulationvaccinated


--tableau table #2

SELECT location, SUM(CAST(new_deaths AS int)) AS TotalDeathCount
FROM SQL_projects..CovidDeaths
--WHERE location like '%Philippines%'
WHERE continent IS null
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC

--Tbaleau Table #4
SELECT location, population, date, MAX(total_cases) AS HighestInfectionCount,
MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM SQL_projects..CovidDeaths
--WHERE location like '%Philippines%'
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC