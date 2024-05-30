-- Checks imported data set
SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

SELECT *
FROM CovidVaccinations
ORDER BY 1,2

--Select Data that we are going to be using
SELECT
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
--Shows percentage of dying if you contract covid in Turkey
SELECT
	location,
	date,
	total_cases,
	total_deaths,
	100.0 * total_deaths/total_cases  AS Death_Percentage
FROM CovidDeaths
WHERE location = 'Turkey'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT
	location,
	date,
	total_cases,
	population,
	100.0 * total_cases/population AS PercentPopulationInfected
FROM CovidDeaths
WHERE location IS NOT NULL
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT
	location,
	population,
	MAX(total_cases) AS HighestInfectionCount,
	MAX(100.0 * total_cases/population) AS PercentPopulationInfected
FROM CovidDeaths
WHERE location IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

--Shows Countries with Highest Death Count per Population
SELECT
	location,
	population,
	MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL and location IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeathCount desc

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT
	continent,
	SUM(CAST(population as bigint)) AS population,
	MAX(total_cases) AS HighestInfectionCount,
	MAX(100.0 * total_cases/population) AS PercentPopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY PercentPopulationInfected desc

-- Shows Countinents with Highest Death Count per Population
SELECT
	continent,
	SUM(CAST(population as bigint)) AS population,
	MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY population desc

-- Global Numbers
-- Total Cases vs Total Deaths by Date
SELECT
	date,
	SUM(new_cases) AS Total_Cases,
	SUM(new_deaths) AS Total_Deaths,
	100.0 * SUM(CAST(new_deaths as int))/SUM(new_cases) as DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL AND new_deaths != 0
GROUP BY date
ORDER BY 1,2

-- Global Total Cases vs Total Deaths
SELECT
	SUM(new_cases) AS Total_Cases,
	SUM(new_deaths) AS Total_Deaths,
	100.0 * SUM(CAST(new_deaths as int))/SUM(new_cases) as DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL AND new_deaths != 0
ORDER BY 1,2

-- Joins CovidDeaths and CovidVaccinations Tables together
SELECT TOP 1000 *
FROM CovidDeaths AS cd
JOIN CovidVaccinations AS cv 
ON cd.date = cv.date
AND cd.location = cv.location

-- Shows Total Population vs Vaccinations
-- Creating CTE
WITH PopulationVsVaccinations (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated) 
AS
(
SELECT 
	cd.continent,
	cd.location, cd.date,
	cd.population,
	cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations as bigint)) OVER(PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS cd
JOIN CovidVaccinations AS cv 
ON cd.date = cv.date
AND cd.location = cv.location
WHERE cd.continent IS NOT NULL
--ORDER BY 1,2
)
SELECT *,
	100.0 * RollingPeopleVaccinated/population as PercentPopulationVaccinated
FROM PopulationVsVaccinations

--Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT 
	cd.continent,
	cd.location, cd.date,
	cd.population,
	cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations as bigint)) OVER(PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS cd
JOIN CovidVaccinations AS cv 
ON cd.date = cv.date
AND cd.location = cv.location
WHERE cd.continent IS NOT NULL

SELECT *,
	100.0 * RollingPeopleVaccinated/population AS PercetPopulationVaccinated
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated 
AS
SELECT 
	cd.continent,
	cd.location, cd.date,
	cd.population,
	cv.new_vaccinations,
	SUM(CAST(cv.new_vaccinations as bigint)) OVER(PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS cd
JOIN CovidVaccinations AS cv 
ON cd.date = cv.date
AND cd.location = cv.location
WHERE cd.continent IS NOT NULL




















	
