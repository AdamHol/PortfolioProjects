--SELECT *
--FROM CovidDeaths
--ORDER BY 3,4

--SELECT *
--FROM CovidVaccinations
--ORDER BY 3,4


--SELECT Location,date, total_cases, new_cases, total_deaths, population
--From CovidDeaths
--ORDER BY 1,2

-- Total Cases vs Total Deaths


SELECT Location,date, total_cases, total_deaths, (CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 AS DeathPercentage
FROM CovidDeaths
WHERE Location = 'Poland'
ORDER BY 1,2

-- Total Cases vs Population

SELECT Location,date, population, total_cases, (CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0))*100 AS PercentPopulationInfected
FROM CovidDeaths
--WHERE Location = 'Poland'
ORDER BY 1,2


-- Highest infection rate compared to population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0)))*100 AS PerentPopulationInfected
FROM CovidDeaths
--WHERE Location = 'Poland'
GROUP BY location, population
ORDER BY 4 DESC

-- Countries with highest death count per population

SELECT Location, MAX(CONVERT(int,total_deaths)) as TotalDeathCount
FROM CovidDeaths
--WHERE Location = 'Poland'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Showing the continent with the highest death count

SELECT continent, MAX(CONVERT(int,total_deaths)) as TotalDeathCount
FROM CovidDeaths
--WHERE Location = 'Poland'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- global numbers


SELECT date, SUM(new_cases) as 'Total Cases',SUM(new_deaths) as 'Total Deaths',cast(ISNULL(SUM(new_deaths)/ NULLIF(SUM(new_cases),0),0)*100 As decimal(12,8)) AS DeathPercentage
FROM CovidDeaths
--WHERE Location = 'Poland'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


--------------------------------------------

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated,
	--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent IS NOT NULL
	order by 2,3


-- USE CTE

WITH PopVsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent IS NOT NULL
	--order by 2,3
)
Select * , (RollingPeopleVaccinated/Population)*100
From PopVsVac


-- TEMP TABLE


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent IS NOT NULL
	--order by 2,3

Select * , (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




--- Creating View to store data for later visualizations

Use PortfolioProject
GO

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
	--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent IS NOT NULL
	--order by 2,3

Select * From PercentPopulationVaccinated