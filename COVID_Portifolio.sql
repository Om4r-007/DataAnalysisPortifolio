/* ------------------------------------------------------------------------------- Covid 19 Data Exploration ----------------------------------------------------------------------------------------------------------- */

select *
from ..covid

select * 
from ..covid
order by 3,4

select location , date , total_cases , new_cases , total_deaths , population
from ..covid
order by 1,2

-- Percentage of total deaths to toal cases per day

select location , date , total_cases , total_deaths , (total_deaths/total_cases)*100 as DeathPercentage
from ..covid 
order by 1,2

-- Percentage of total deaths to toal cases per day in Iraq

select location , date , total_cases , total_deaths , (total_deaths/total_cases)*100 as DeathPercentage
from ..covid 
Where location = 'Iraq'
order by 1,2

-- Percentage of iraq popualtion that got covid

select location , date , population , total_cases , (total_cases/population)*100 as PopulationInfectedPercentage
from ..covid 
Where location = 'Iraq'
order by 1,2

-- Countries with highest infection rate according to population 

select location , population , max(total_cases) as AllCases , max((total_cases / population )* 100) as PopulationInfectedPercentage
from ..covid
Where continent is not null
group by location , population 
order by PopulationInfectedPercentage desc

-- Countries with highest deaths 

select location , max(total_deaths) as TotalDeaths 
from ..covid
Where continent is not null
group by location
order by TotalDeaths desc

-- Countries with highest infections 

select location , max(total_cases) as TotalCases 
from ..covid
where continent is not null
group by location
order by TotalCases desc

-- Countries with highest deaths according to population 

select location , population , max(total_deaths) as TotalDeaths , max((total_deaths/population)*100)  as PopulationDeathedPercentage
from ..covid
where continent is not null
group by location , population
order by PopulationDeathedPercentage desc

-- Continents with highest infections

select location , max(total_cases) as TotalCases 
from ..covid
where continent is null
group by location
order by TotalCases desc

-- Continents with highest deaths

select location , max(total_deaths) as TotalDeaths 
from ..covid
Where continent is null
group by location
order by TotalDeaths desc

-- Global numbers by date

select date ,sum(new_cases) as TotalCases , sum(new_deaths) as TotalDeaths
from ..covid
where continent is not null
group by date
order by 1

-- Global numbers

select sum(new_cases) as TotalCases , sum(new_deaths) as TotalDeaths , sum(new_deaths)/sum(new_cases) * 100 as DeathPercentage
from ..covid
where continent is not null
--group by date
order by 1


select * 
from ..[covidvac ]
order by 3,4

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
order by 2,3


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
insert into #PercentPopulationVaccinated
SELECT a.continent, a.location, a.date, vac.population, vac.new_vaccinations, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by a.location ORDER BY a.location, a.date) AS RollingPeopleVaccinated
FROM ..covid a
JOIN ..[covidvac ] vac
	ON a.location = vac.location
	and a.date = vac.date
WHERE a.continent is NOT NULL 

SELECT *, ROUND((RollingPeopleVaccinated/Population)*100,2) AS RollingPercent
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualisations

CREATE View PercentPopulationVaccinated as
SELECT a.continent, a.location, a.date, vac.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by a.location ORDER BY a.location, a.date) AS RollingPeopleVaccinated
FROM ..covid a
JOIN ..covidVac vac
	ON a.location = vac.location
	and a.date = vac.date
WHERE a.continent is NOT NULL 


