/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

--Dataset--

SELECT *
FROM 
  `eighth-physics-440919-t4.Portfolio_Project.Covid_Deaths`
ORDER BY 
  3,4

-- Beginning Data --
SELECT 
  location, 
  date, 
  total_cases, 
  new_cases, 
  total_deaths, 
  population 
FROM 
  `eighth-physics-440919-t4.Portfolio_Project.Covid_Deaths`
ORDER BY 
  1,2

-- Total Cases vs Total Deaths --
-- Shows probability of dying from contracting COVID in your country
SELECT 
  location, 
  date, 
  total_cases, 
  total_deaths, 
  (total_deaths/total_cases)*100 AS Death_Percentage
FROM 
  `eighth-physics-440919-t4.Portfolio_Project.Covid_Deaths`
WHERE 
  location = 'United States'
ORDER BY 
  1,2

-- Total Cases vs Population --
-- Shows probability of contracting COVID
SELECT 
  location, 
  date,  
  population,
  total_cases,
  (total_cases/population)*100 AS Population_Percentage_Infected
FROM 
  `eighth-physics-440919-t4.Portfolio_Project.Covid_Deaths`
WHERE 
  location = 'United States'
ORDER BY 
  1,2

-- Countries with Highest Infection Rate Per Population --

SELECT 
  location, 
  population, 
  Max(total_cases) AS Highest_Infection_Count, 
  max((total_cases/population))*100 AS Population_Percentage_Infected
FROM 
  'eighth-physics-440919-t4.Portfolio_Project.Covid_Deaths`
GROUP BY
  location, population
ORDER BY
  Population_Percentage_Infected desc

-- Countries with Highest Death Count Per Population --

SELECT 
  continent,
  MAX(CAST(total_deaths AS INT)) AS Highest_Death_Count,  
  MAX(CAST(total_deaths AS INT) / population) * 100 AS Population_Percentage_Death  
FROM 
  `eighth-physics-440919-t4.Portfolio_Project.Covid_Deaths`
WHERE 
  continent is not null
GROUP BY 
  continent
ORDER BY 
  Highest_Death_Count DESC
  
-- Continents with the Highest Death Count Per Population --
SELECT
  continent,
  max(cast(total_deaths as int)) AS Total_Death_Count
FROM
  `eighth-physics-440919-t4.Portfolio_Project.Covid_Deaths`
WHERE
  continent is not null
GROUP BY
  continent 
ORDER BY
  Total_Death_Count desc

-- Global Total Cases and Deaths --
SELECT
  sum(new_cases) as Total_Cases,
  sum(cast(new_deaths as int)) as Total_Deaths,
  sum(cast(new_deaths as int))/sum(new_cases)* 100 as Death_Percentage
FROM
    `eighth-physics-440919-t4.Portfolio_Project.Covid_Deaths`
WHERE
  continent is not null
order by
  1,2

-- Total Population vs Vaccinations --
-- Shows percentage of population that has recieved at least one COVID vaccine
SELECT 
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS Rolling_People_Vaccinated
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
-- Using CTE to perform Calculation on Partition By in previous query --
WITH PopVsVac
AS
(
  SELECT 
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location order by dea.location, dea.date) AS Rolling_People_Vaccinated
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

SELECT *,
  (rolling_people_vaccinated/population)*100 as Percentage_Vaccinated 
FROM
  PopVsVac
  
  -- Using Temp Table to Perform Calculation on Partition By in Previous Query -- 
  BEGIN
  CREATE TEMPORARY TABLE Temp_Percent_Population_Vaccinated AS
  WITH Percent_Population_Vaccinated AS (
    SELECT 
      dea.continent, 
      dea.location, 
      dea.date, 
      dea.population, 
      vac.new_vaccinations,
      SUM(CAST(vac.new_vaccinations AS INT64)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
    FROM 
      `eighth-physics-440919-t4.Portfolio_Project.Covid_Deaths` dea
    JOIN 
      `eighth-physics-440919-t4.Portfolio_Project.Covid_Vaccinations` vac
      ON dea.location = vac.location
      AND dea.date = vac.date
   
   WHERE dea.continent IS NOT NULL
  )

  SELECT 
    *, 
    (Rolling_People_Vaccinated / population) * 100 AS Percent_Population_Vaccinated
  FROM 
    Percent_Population_Vaccinated;
END;

-- Creating View to Store for Later Visualization --

CREATE VIEW `eighth-physics-440919-t4.Portfolio_Project.PopVsVac` AS
SELECT 
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations AS INT64)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated
FROM   
  `eighth-physics-440919-t4.Portfolio_Project.Covid_Deaths` dea
JOIN 
  `eighth-physics-440919-t4.Portfolio_Project.Covid_Vaccinations` vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE 
  dea.continent IS NOT NULL;

