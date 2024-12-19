-- SELECTING SPECIFIC COLUMNS FROM COVIDDEATHS TABLE
SELECT location, date, total_cases, total_deaths, new_cases, population
FROM PortfolioProject..CovidDeaths
ORDER BY location, date;

-- SELECTING SPECIFIC COLUMNS FROM COVIDVACCINATIONS TABLE
SELECT location, date, total_vaccinations, new_vaccinations
FROM PortfolioProject..CovidVaccinations
ORDER BY location, date;

-- CALCULATING DEATH PERCENTAGE FOR SPECIFIC LOCATIONS
SELECT location, date, total_cases, total_deaths,
       (total_deaths * 100.0 / NULLIF(total_cases, 0)) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY location, date;

-- SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- BREAKING DATA BY CONTINENT
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- SHOWING LOCATIONS WITH NULL CONTINENT AND DEATH COUNTS
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- SHOWING NEW CASES AND NEW DEATHS BY DATE
SELECT date, SUM(new_cases) AS TotalNewCases, SUM(new_deaths) AS TotalNewDeaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

-- JOINING COVIDDEATHS AND COVIDVACCINATIONS TABLES
SELECT dea.location, dea.date, dea.total_cases, dea.total_deaths, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date;

-- GLOBAL NUMBERS (AGGREGATE DATA)
SELECT SUM(new_cases) AS TotalCases,
       SUM(CAST(new_deaths AS INT)) AS TotalDeaths,
       SUM(CAST(new_deaths AS INT)) * 100.0 / NULLIF(SUM(new_cases), 0) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL;

-- TOTAL POPULATION VS VACCINATIONS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(INT, ISNULL(vac.new_vaccinations, 0)))
       OVER (PARTITION BY dea.location ORDER BY dea.date) AS RunningTotalVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY location, date;

-- USING COMMON TABLE EXPRESSIONS (CTE)
WITH PopulationVaccinationData AS
(
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
           SUM(CONVERT(INT, ISNULL(vac.new_vaccinations, 0)))
           OVER (PARTITION BY dea.location ORDER BY dea.date) AS RunningTotalVaccinations
    FROM PortfolioProject..CovidDeaths dea
    JOIN PortfolioProject..CovidVaccinations vac
      ON dea.location = vac.location
      AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *, (RunningTotalVaccinations * 100.0 / NULLIF(population, 0)) AS VaccinationPercentage
FROM PopulationVaccinationData;

-- TEMPORARY TABLE FOR PERCENTAGE OF POPULATION VACCINATED
DROP TABLE IF EXISTS #PercentPopulationVaccinated;
CREATE TABLE #PercentPopulationVaccinated
(
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population NUMERIC,
    new_vaccination NUMERIC,
    runningtotal NUMERIC
);

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(INT, ISNULL(vac.new_vaccinations, 0)))
       OVER (PARTITION BY dea.location ORDER BY dea.date) AS RunningTotalVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date;

SELECT *, (runningtotal * 100.0 / NULLIF(population, 0)) AS VaccinationPercentage
FROM #PercentPopulationVaccinated;

-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION
DROP VIEW IF EXISTS PercentPopulationVaccinated;
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(INT, ISNULL(vac.new_vaccinations, 0)))
       OVER (PARTITION BY dea.location ORDER BY dea.date) AS RunningTotalVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *
FROM PercentPopulationVaccinated;
