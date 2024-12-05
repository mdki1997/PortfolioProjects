select *
from PortfolioProject..CovidDeaths
order by 3,4


select *
from PortfolioProject..CovidVaccinations
order by 3,4
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2;


select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2


--showing Countries with Highest Death Count per Population

Select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


--let's break thing down by continent

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc  

Select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

--showing continents with highest death count per populations


select date, new_cases, new_deaths 
--sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

select * from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date

--GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths,
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2


--Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations))
OVER (Partition by dea.location  ORDER BY dea.location, dea.date) as RunningTotal 
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use CTE

WITH PopvsVac (continent, location, date, population, new_vaccination, runningtotal)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations))
OVER (Partition by dea.location  ORDER BY dea.location, dea.date) as RunningTotal 
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (runningtotal/population)*100 from PopvsVac



DROP table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RunningTotal numeric,
)
Insert into #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations))
OVER (Partition by dea.location  ORDER BY dea.location, dea.date) as RunningTotal 
from PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (runningtotal/population)*100
from #PercentPopulationVaccinated



-- creating view to store data for later visualisation

DROP VIEW IF EXISTS PercentPopulationVaccinated

CREATE VIEW PercentPopulationVaccinated AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CONVERT(INT, ISNULL(vac.new_vaccinations, 0))) 
    OVER (PARTITION BY dea.location ORDER BY dea.date) AS RunningTotal
FROM 
    PortfolioProject..CovidDeaths dea
JOIN 
    PortfolioProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL;


SELECT * 
FROM PercentPopulationVaccinated