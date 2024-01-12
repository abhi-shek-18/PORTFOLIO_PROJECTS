USE PORTFOLIOPROJECT;
-- SELECT * FROM COVIDVACCINATIONS
-- ORDER BY 3,4;
SELECT * FROM COVIDDEATHS
WHERE continent is not null
ORDER BY 3,4;

-- SELECT DATA THAT WE ARE GOING TO BE USING
SELECT location, date, total_cases, new_cases,total_deaths,population
FROM COVIDDEATHS ORDER BY 1,2;

-- LOOKING AT THE TOTAL DEATHS VS TOTAL CASES 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercent
FROM COVIDDEATHS
WHERE location LIKE '%India%'
and continent is not null
 ORDER BY 1,2;

-- LOOKING AT THE TOTAL CASES VS POPULATION 
-- SHOWS THE PERCEMTAGE OF PEOPLE INDECTED FROM VIROUS OUT OF TOTAL POPULATION  
SELECT location, date, total_cases, population, (total_cases/population)*100 AS InfectedPercentage
FROM COVIDDEATHS
WHERE location LIKE '%India%'
and  continent is not null
 ORDER BY 1,2;
 
 -- LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
SELECT location,population, MAX(total_cases) AS HighestInfectionCount,MAX((total_cases/population))*100 AS HighestInfectedPercentage
FROM COVIDDEATHS
GROUP BY location, population
ORDER BY InfectedPercentage desc;

-- SHOWING COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULAITON
SELECT location, max(CAST(total_deaths AS FLOAT))AS TotalDeaths,MAX((CAST(total_deaths AS FLOAT)/population))*100 AS DeathPercentage
FROM COVIDDEATHS
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeaths desc;

-- WE WILL FIND THE ABOVE RESULT ON THE BASIS OF CONTINENTS
SELECT continent, max(CAST(total_deaths AS FLOAT))AS TotalDeaths
FROM COVIDDEATHS
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeaths desc;

-- NOW LOOKING AT THE GLOBAL DATA RESULTS
SELECT date, SUM(new_cases)AS TotalCases, SUM(cast(new_deaths as float))AS TotalDeaths, (SUM(cast(new_deaths as float))/SUM(new_cases))*100 AS DeathPercentOverNewCases
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

SELECT SUM(new_cases)AS TotalCases, SUM(cast(new_deaths as float))AS TotalDeaths, (SUM(cast(new_deaths as float))/SUM(new_cases))*100 AS DeathPercentOverNewCases
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;


-- NOW EXPLORATING DATA OF COVID VACCINATION
SELECT *
FROM CovidDeaths d
JOIN
CovidVaccinations v 
on d.location=v.location
and d.date=v.date;

-- LOOKING AT THE TOTAL POPULATION VS VACCINATION
SELECT d.continent,d.location,d.date,d.population, v.new_vaccinations
FROM CovidDeaths d
JOIN
CovidVaccinations v 
on d.location=v.location
and d.date=v.date
where d.continent is not null
order by 1,2,3;

SELECT d.continent,d.location,d.date,d.population, v.new_vaccinations
,SUM(CAST(v.new_vaccinations AS float))OVER (PARTITION BY d.location order by d.location,d.date) as cummulative_new_vaccinations
FROM CovidDeaths d
JOIN
CovidVaccinations v 
on d.location=v.location
and d.date=v.date
where d.continent is not null
order by 2,3;

-- USE CTE
WITH PopVsVac (continent,location,date,population,new_vaccinations,cummulative_new_vaccinations)
as
(SELECT d.continent,d.location,d.date,d.population, v.new_vaccinations
,SUM(CAST(v.new_vaccinations AS float))OVER (PARTITION BY d.location order by d.location,d.date) as cummulative_new_vaccinations
FROM CovidDeaths d
JOIN
CovidVaccinations v 
on d.location=v.location
and d.date=v.date
where d.continent is not null
)
SELECT *, (cummulative_new_vaccinations/population)*100 as VaccinatoinPerPopulationPercent 
FROM PopVsVac;


-- DOING ABOVE THING USING TEMP TABLE

/*
Create Table #PercentPopulationVaccinated(
continent NVARCHAR(255),
location NVARCHAR(100),
date DATETIME,
population NUMERIC,
new_vaccinations NUMERIC,
cummulative_new_vaccinations NUMERIC)

INSERT INTO #PercentPopulationVaccinated 
SELECT d.continent,d.location,d.date,d.population, v.new_vaccinations
,SUM(CAST(v.new_vaccinations AS float))OVER (PARTITION BY d.location order by d.location,d.date) as cummulative_new_vaccinations
FROM CovidDeaths d
JOIN
CovidVaccinations v 
on d.location=v.location and d.date=v.date
 where d.continent is not null

SELECT *, (cummulative_new_vaccinations/population)*100 as VaccinatoinPerPopulationPercent 
FROM #PercentPopulationVaccinated;
*/

-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated AS
SELECT d.continent,d.location,d.date,d.population, v.new_vaccinations
,SUM(CAST(v.new_vaccinations AS float))OVER (PARTITION BY d.location order by d.location,d.date) as cummulative_new_vaccinations
FROM CovidDeaths d
JOIN
CovidVaccinations v 
on d.location=v.location and d.date=v.date
 where d.continent is not null
