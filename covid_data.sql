-- Total cases vs Total deaths 
-- Death rate percentage in India & Canada

SELECT Location, date, total_cases,total_deaths, (CAST(total_deaths AS float) / CAST(total_cases AS float)) * 100 AS death_rate_percentage
FROM PortfolioProject..CovidDeaths$
where location like '%india%'
order by 1,2

SELECT Location, date, total_cases,total_deaths, (CAST(total_deaths AS float) / CAST(total_cases AS float)) * 100 AS death_rate_percentage
FROM PortfolioProject..CovidDeaths$
where location like '%canada%'
order by 1,2


-- Total cases vs population 
-- Percentage of population got covid 

SELECT Location, date,population, total_cases,(CAST(total_cases AS float) / CAST(population AS float)) * 100 AS per_of_infected 
FROM PortfolioProject..CovidDeaths$
--where location like '%india%'
order by 1,2

-- Countries with highest infection rate compared to population

SELECT Location,population, Max(total_cases) as highest_infectionCount,(CAST(Max(total_cases) AS float) / CAST(population AS float)) * 100 AS Percentage_of_infected 
FROM PortfolioProject..CovidDeaths$
GROUP BY LOCATION, POPULATION
order by Percentage_of_infected DESC

-- SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
-- percentage of deaths 

SELECT Location,population  ,Max(cast(total_deaths as int)) as total_deathss ,(CAST(Max(total_deaths) AS float) / CAST(population AS float)) * 100 AS Per_deaths
FROM PortfolioProject..CovidDeaths$
where continent is not null
GROUP BY LOCATION , population
order by total_deathss DESC

select * 
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4 

-- DEATHS PER CONTINENT 

SELECT continent, Max(cast(total_deaths as int)) as total_deathss 
FROM PortfolioProject..CovidDeaths$
where continent is not null
GROUP BY continent  
order by total_deathss DESC

-- Global Total Numbers 

SELECT Sum(cast(total_cases as float))  as totalCases, sum(cast(total_deaths as float)) as totalDeaths,
CASE WHEN sum(cast(total_cases as float)) = 0 THEN NULL ELSE sum(cast(total_deaths as float))/sum(cast(total_cases as float))*100 END as Deathpercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL


select *
from PortfolioProject..CovidDeaths$


-- Total population vs Vaccinations


SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
  SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
    JOIN PortfolioProject..CovidVaccinations$ vac ON dea.location = vac.location AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3

-- Common Table Expression 

with popvsvac(continent, location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
    SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
    JOIN PortfolioProject..CovidVaccinations$ vac ON dea.location = vac.location AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
	)
--ORDER BY 2,3)
select * , (RollingPeopleVaccinated/population)*100 per_vacc
from popvsvac

-- Temp Table

drop table if exists #percentpopulationVaccinated
create table #percentpopulationVaccinated 
(continent nvarchar(255),location nvarchar(255),date datetime,population numeric,new_vaccinations numeric,RollingPeopleVaccinated numeric )
insert into #percentpopulationVaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
    SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
   JOIN PortfolioProject..CovidVaccinations$ vac ON dea.location = vac.location AND dea.date = vac.date 
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

select *,(RollingPeopleVaccinated/population)*100 as  per_vacc
from #percentpopulationVaccinated



-- Creatinng View to Store data for later Visualization

CREATE VIEW PercentPopulationVaccinated_nnde AS
WITH popvsvac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) AS
(
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
        SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
    JOIN PortfolioProject..CovidVaccinations$ vac ON dea.location = vac.location AND dea.date = vac.date WHERE dea.continent IS NOT NULL
)
SELECT *
FROM popvsvac;
