
--Check if data is loaded Correctly
SELECT * 
FROM PortfolioProjects..CovidDeaths
ORDER BY 3,4

SELECT * 
FROM PortfolioProjects..CovidVaccinations
ORDER BY 3,4


SELECT location, date, population, total_cases, total_deaths, 
ROUND((total_deaths/total_cases)*100,2) as DeathPercentage, 
ROUND((total_cases/population)*100,2) as PercentagePopulationInfected
FROM PortfolioProjects..CovidDeaths
WHERE location LIKE '%STATES'
ORDER BY 1, 2
--Looking at total cases vs total deaths worldwide from 02/2020 to 02/2022 
--'Death Percentage' shows the likelihood of death if you infected by Covid-19 worldwide
--'PercentagePopulationInfected' shows the number of cases verse the population


--Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM PortfolioProjects..CovidDeaths
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC

--Showing Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Showing the continents with Highest deathcount(Instead of by Countries, Filter by continent)

SELECT continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProjects..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- WORLDWIDE VIEW 
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths
--WHERE location LIKE '%STATES'
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2

--Looking at Total Population vs Vaccination Records
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
 SUM(cast(v.new_vaccinations as int)) OVER (Partition by d.location order by d.location, d.date) as TotalVaccinatedToDate
FROM PortfolioProjects..CovidDeaths d
JOIN PortfolioProjects..CovidVaccinations v
	ON d.location = v.location
	and d.date = v.date	
where d.continent is not null
order by 2,3

--with cte

With PopVsVac (Continent, location, date, Population, new_vaccinations, TotalVaccinatedToDate)
as 
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
 sum(cast(v.new_vaccinations as int)) OVER (Partition by d.location order by d.location, d.date) as TotalVaccinatedToDate
FROM PortfolioProjects..CovidDeaths d
JOIN PortfolioProjects..CovidVaccinations v
	ON d.location = v.location
	and d.date = v.date	
where d.continent is not null
--order by 2,3
)
select *, (TotalVaccinatedToDate/Population)*100 
from PopVsVac




-- Creating a TEMP TABLE to compare Population vs Vaccinations

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalVaccinatedToDate numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
 sum(cast(v.new_vaccinations as int)) OVER (Partition by d.location order by d.location, d.date) as TotalVaccinatedToDate
FROM PortfolioProjects..CovidDeaths d
JOIN PortfolioProjects..CovidVaccinations v
	ON d.location = v.location
	and d.date = v.date	
where d.continent is not null
order by 2,3;

select *, ROUND((TotalVaccinatedToDate/Population)*100,4)AS PercentVaccinated 
from #PercentPopulationVaccinated;


-- CREATE VIEW to store date for later visualizations using Tableu

CREATE VIEW PercentPopulationVaccinated AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
 sum(cast(v.new_vaccinations as int)) OVER (Partition by d.location order by d.location, d.date) as TotalVaccinatedToDate
FROM PortfolioProjects..CovidDeaths d
JOIN PortfolioProjects..CovidVaccinations v
	ON d.location = v.location
	and d.date = v.date	
where d.continent is not null
select *
from PercentPopulationVaccinated