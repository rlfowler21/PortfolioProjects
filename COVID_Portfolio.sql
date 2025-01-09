Select *
from `eighth-physics-440919-t4.Portfolio_Project.Covid_Deaths`
order by 3,4


select location, date, total_cases, new_cases, total_deaths, population 
from `eighth-physics-440919-t4.Portfolio_Project.Covid_Deaths`
order by 1,2

-- Looking at Total Cases vs Total Deaths 
-- Shows probability of dying from contracting Covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from `eighth-physics-440919-t4.Portfolio_Project.Covid_Deaths`
where location = 'United States'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows probability of contracting Covid
select location, date,  population, total_cases, (total_cases/population)*100 as Population_Percentage_Infected
from `eighth-physics-440919-t4.Portfolio_Project.Covid_Deaths`
where location = 'United States'
order by 1,2

-- Looking at Countries with Highest Infection Rate Per Population

select 
  location, population, Max(total_cases) as Highest_Infection_Count, max((total_cases/population))*100 
  as Population_Percentage_Infected
from 
  'eighth-physics-440919-t4.Portfolio_Project.Covid_Deaths`
group by 
  location, population
order by 
  Population_Percentage_Infected desc

-- Showing Countires with Highest Death Count Per Population

SELECT 
    continent,
    MAX(CAST(total_deaths AS INT)) AS Highest_Death_Count,  -- Maximum deaths per location
    MAX(CAST(total_deaths AS INT) / population) * 100 AS Population_Percentage_Death  -- Maximum percentage of deaths relative to population
FROM 
    `eighth-physics-440919-t4.Portfolio_Project.Covid_Deaths`
where 
continent is not null
GROUP BY 
    continent
ORDER BY 
    Highest_Death_Count DESC;  -- Order by Highest_Death_Count instead

-- Continents with the Highest Death Count Per Population 
SELECT
  continent,
  max(cast(total_deaths as int)) as Total_Death_Count
FROM
  `eighth-physics-440919-t4.Portfolio_Project.Covid_Deaths`
WHERE
  continent is not null
GROUP BY
  continent 
ORDER BY
  Total_Death_Count desc

--GLOBAL TOTAL CASES AND DEATHS
SELECT
  sum(new_cases) as total_cases,
  sum(cast(new_deaths as int)) as total_deaths,
  sum(cast(new_deaths as int))/sum(new_cases)* 100 as Death_Percentage
FROM
    `eighth-physics-440919-t4.Portfolio_Project.Covid_Deaths`
WHERE
  continent is not null
order by
  1,2

--Looking at Total Population vs Total Vaccinations 
SELECT 
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS rolling_people_vaccinated
FROM   
  `eighth-physics-440919-t4.Portfolio_Project.Covid_Deaths` dea
JOIN 
  `eighth-physics-440919-t4.Portfolio_Project.Covid_Vaccinations` vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE 
  dea.continent IS NOT NULL
ORDER BY 
  2,3

--Creating CTE to compare population to people vaccinated 
WITH PopVsVac
AS
(
  SELECT 
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS rolling_people_vaccinated
FROM   
  `eighth-physics-440919-t4.Portfolio_Project.Covid_Deaths` dea
JOIN 
  `eighth-physics-440919-t4.Portfolio_Project.Covid_Vaccinations` vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE 
  dea.continent IS NOT NULL
--ORDER BY 2,3
)

select *,
  (rolling_people_vaccinated/population)*100 as Percentage_Vaccinated 
from PopVsVac

-- Creating View to store for later visualization 

CREATE VIEW `eighth-physics-440919-t4.Portfolio_Project.PopVsVac` AS
SELECT 
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS INT64)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
FROM   
  `eighth-physics-440919-t4.Portfolio_Project.Covid_Deaths` dea
JOIN 
  `eighth-physics-440919-t4.Portfolio_Project.Covid_Vaccinations` vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE 
  dea.continent IS NOT NULL;

