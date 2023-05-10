SELECT*
FROM [Portfolio Project ]..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT*
--FROM [Portfolio Project ]..CovidVaccinations
--ORDER BY 3,4

--Select data that we are going to be using 

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project ]..CovidDeaths
WHERE continent is not null
ORDER BY 1,2 


--Looking at total Cases vs Total Deaths
--shows likelihood of dying if you contract covid in your country 

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100  Deathpercentage
FROM [Portfolio Project ]..CovidDeaths
WHERE location LIKE '%states%'
and continent is not null 
ORDER BY 1,2 

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100  Deathpercentage
FROM [Portfolio Project ]..CovidDeaths
WHERE location LIKE '%Nigeria%'
and continent is not null
ORDER BY 1,2 

--Looking at Total cases vs Population 
--shows what percentage of population got covid 

SELECT Location, date, Population, total_cases, (total_cases/population)*100  PercentPopulationInfected
FROM [Portfolio Project ]..CovidDeaths
--WHERE location LIKE '%Nigeria%'
WHERE continent is not null
ORDER BY 1,2 

SELECT Location, date, Population, total_cases, (total_cases/population)*100  Deathpercentage
FROM [Portfolio Project ]..CovidDeaths
WHERE location LIKE '%states%'
WHERE continent is not null
ORDER BY 1,2 

--Looking at countries with highest infection rate compared to population 
SELECT location, Population, MAX(total_cases)  HighestInfectionCount, MAX((total_cases/population))*100  PercentPopulationInfected
FROM [Portfolio Project ]..CovidDeaths
--WHERE location LIKE '%Nigeria%'
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

-- Showing countries witth the Highest Death per population 
SELECT location, MAX(cast(Total_deaths as int))  TotalDeathCount
FROM [Portfolio Project ]..CovidDeaths
--WHERE location LIKE '%Nigeria%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

--showing Deathcount by Continent 

SELECT continent, MAX(cast(Total_deaths as int))  TotalDeathCount
FROM [Portfolio Project ]..CovidDeaths
--WHERE location LIKE '%Nigeria%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Showing continents with the highest death count Per Population 

SELECT location, MAX(cast(Total_deaths as int))  TotalDeathCount
FROM [Portfolio Project ]..CovidDeaths
--WHERE location LIKE '%Nigeria%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Global Numbers 

SELECT SUM(new_cases)  Total_cases,  SUM(cast(new_deaths as int))  as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100  Deathpercentage
FROM [Portfolio Project ]..CovidDeaths
--WHERE location LIKE '%Nigeria%'
WHERE continent is not null
--GROUP BY date 
ORDER BY 1,2 

--Looking at the Total Population vs Vaccinations

Select *
FROM [Portfolio Project ]..CovidDeaths  dea
Join [Portfolio Project ]..[CovidVaccinations ] as vac
  On  dea.location = vac.location
  and dea.date = vac.date 
   select*
   FROM [Portfolio Project ]..[CovidVaccinations ]

   SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
   FROM [Portfolio Project ]..CovidDeaths  dea
   Join [Portfolio Project ]..[CovidVaccinations ] vac
     ON dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
	 ORDER BY 1,2,3

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (PARTITION by dea.location order by dea.location,dea.date)	RollingpeopleVaccinated
  FROM [Portfolio Project ]..CovidDeaths  dea
   Join [Portfolio Project ]..[CovidVaccinations ] vac
     ON dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
	 ORDER BY 2,3

--Using CTE 
with PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccination)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (PARTITION by dea.location order by dea.location,dea.date)	RollingproplrVaccinated
  FROM [Portfolio Project ]..CovidDeaths  dea
   Join [Portfolio Project ]..[CovidVaccinations ] vac
     ON dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
	 --ORDER BY 2,3
	 )
	 Select *, (RollingPeopleVaccination/Population)*100
	 from PopvsVac

--using Temp Table

Drop table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continet nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
rollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (PARTITION by dea.location order by dea.location,dea.date)	RollingproplrVaccinated
  FROM [Portfolio Project ]..CovidDeaths  dea
   Join [Portfolio Project ]..[CovidVaccinations ] vac
     ON dea.location = vac.location
	 and dea.date = vac.date
--where dea.continent is not null
	 --ORDER BY 2,3
	 
	 Select *, (RollingPeopleVaccinated/population)*100  PopulationPercent
	 from #PercentPopulationVaccinated

 --Creating views for visulisation

 Create View PercentPopulationVaccinated as 

 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (PARTITION by dea.location order by dea.location,dea.date)	RollingproplrVaccinated
  FROM [Portfolio Project ]..CovidDeaths  dea
   Join [Portfolio Project ]..[CovidVaccinations ] vac
     ON dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
	 from #PercentPopulationVaccinated
	 


