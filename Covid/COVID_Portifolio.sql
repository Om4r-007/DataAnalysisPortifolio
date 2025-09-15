/* ------------------------------------------------------------------------------- Covid 19 Data Exploration ----------------------------------------------------------------------------------------------------------- */

SELECT *
FROM ..covid

SELECT * 
FROM ..covid
ORDER BY 3,4

SELECT location , date , total_cases , new_cases , total_deaths , population
FROM ..covid
ORDER BY 1,2

-- Percentage of total deaths to toal cases per day

SELECT location , date , total_cases , total_deaths , (total_deaths/total_cases)*100 as DeathPercentage
FROM ..covid 
ORDER BY 1,2

-- Percentage of total deaths to toal cases per day in Iraq

SELECT location , date , total_cases , total_deaths , (total_deaths/total_cases)*100 as DeathPercentage
FROM ..covid 
WHERE location = 'Iraq'
ORDER BY 1,2

-- Percentage of iraq popualtion that got covid

SELECT location , date , population , total_cases , (total_cases/population)*100 as PopulationInfectedPercentage
FROM ..covid 
WERE location = 'Iraq'
ORDER BY 1,2

-- Countries with highest infection rate according to population 

SELECT location , population , max(total_cases) as AllCases , max((total_cases / population )* 100) as PopulationInfectedPercentage
FROM ..covid
WHERE continent is not null
GROUP BY location , population 
ORDER BY PopulationInfectedPercentage desc

-- Countries with highest deaths 

SELECT location , max(total_deaths) as TotalDeaths 
FROM ..covid
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeaths desc

-- Countries with highest infections 

SELECT location , max(total_cases) as TotalCases 
FROM ..covid
WHERE continent is not null
GROUP BY location
ORDER BY TotalCases desc

-- Countries with highest deaths according to population 

SELECT location , population , max(total_deaths) as TotalDeaths , max((total_deaths/population)*100)  as PopulationDeathedPercentage
FROM ..covid
WHERE continent is not null
GROUP BY location , population
ORDER BY PopulationDeathedPercentage desc

-- Continents with highest infections

SELECT location , max(total_cases) as TotalCases 
FROM ..covid
WHERE continent is null
GROUP BY location
ORDER BY TotalCases desc

-- Continents with highest deaths

SELECT location , max(total_deaths) as TotalDeaths 
FROM ..covid
WHERE continent is null
GROUP BY location
ORDER BY TotalDeaths desc

-- Global numbers by date

SELECT date ,sum(new_cases) as TotalCases , sum(new_deaths) as TotalDeaths
FROM ..covid
WHERE continent is not null
GROUP BY date
ORDER BY 1

-- Global numbers

SELECT sum(new_cases) as TotalCases , sum(new_deaths) as TotalDeaths , sum(new_deaths)/sum(new_cases) * 100 as DeathPercentage
FROM ..covid
WHERE continent is not null
--group by date
ORDER BY 1


SELECT * 
FROM ..[covidvac ]
ORDER BY 3,4

-- Total Population vs Vaccinations
-- Percentage of Population that has received at least one Covid Vaccine


SELECT a.continent, a.location, a.date, vac.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by a.Location order by a.location , a.date) as RollingPeopleVaccinated
FROM ..covid a
JOIN ..[covidvac ] vac
	ON a.location = vac.location
	AND a.date = vac.date
WHERE a.continent IS NOT NULL
ORDER BY 2,3


-- USING CTE

WITH PopulationvsVaccinations (Continent, Location, date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT a.continent, a.location, a.date, vac.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by a.location ORDER BY a.location, a.date) AS RollingPeopleVaccinated
FROM ..covid a
JOIN ..[covidvac ] vac
	ON a.location = vac.location
	and a.date = vac.date
WHERE a.continent is NOT NULL 
)
SELECT *, ROUND((RollingPeopleVaccinated/Population)*100,2) AS RollingPercent
FROM PopulationvsVaccinations
ORDER BY 2,3


-- Using TEMP TABLE to perform calculation on Partition By in previous query 

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255), 
date datetime, 
Population numeric, 
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT a.continent, a.location, a.date, vac.population, vac.new_vaccinations, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by a.location ORDER BY a.location, a.date) AS RollingPeopleVaccinated
FROM ..covid a
JOIN ..[covidvac ] vac
	ON a.location = vac.location
	AND a.date = vac.date
WHERE a.continent is NOT NULL 

SELECT *, ROUND((RollingPeopleVaccinated/Population)*100,2) AS RollingPercent
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualisations

CREATE VIEW PercentPopulationVaccinated as
SELECT a.continent, a.location, a.date, vac.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by a.location ORDER BY a.location, a.date) AS RollingPeopleVaccinated
FROM ..covid a
JOIN ..covidVac vac
	ON a.location = vac.location
	AND a.date = vac.date
WHERE a.continent is NOT NULL 


