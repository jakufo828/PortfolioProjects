Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--where continent is not null
--order by 3,4

--Select Data we are going to be using

Select Location, date, total_cases, New_cases, total_deaths, population 
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


--Looking at Total Cases vs. Total Deaths
-- Shows likelihood of dying if you contract COVID in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Location LIKE '%states%' and continent is not null
order by 1,2


--Looking at Total Cases vs. Population
-- Shows what percentage of population got COVID

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where Location LIKE '%states%' and continent is not null
order by 1,2


--Looking at countries with highest infection rate compared to population

Select Location, population, MAX(total_cases) as HighestInfectionCount 
,MAX(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where Location LIKE '%states%'
where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc


--Showing Countries with the highest death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where Location LIKE '%states%'
where continent is not null
Group by Location
order by TotalDeathCount desc


--LETS BREAK THINGS DOWN BY CONTINENT



-- Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where Location LIKE '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths
, Sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
--Group by date
order by 1,2


--Looking at TOTAL population vs Vaccinations
--shows percentage of population that has received at least one COVID vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER by dea.location, 
dea.date) as RollingVaccinationNumbers
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
where dea.continent is not null
order by 2,3



--USING CTE to perform calculation on Partition By in previous query

With PopvsVac (continent, location, date, population, New_vaccinations, RollingVaccinationNumbers)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER by dea.location, 
dea.date) as RollingVaccinationNumbers
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingVaccinationNumbers/Population)*100
From PopvsVac



--USING TEMP TABLE to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinationNumbers numeric)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER by dea.location, 
dea.date) as RollingVaccinationNumbers
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
where dea.continent is not null
order by 2,3

Select *, (RollingVaccinationNumbers/Population)*100
From #PercentPopulationVaccinated 



--Creating View to Store Data for Later Visualizations:


CREATE View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (partition by dea.location ORDER by dea.location, 
dea.date) as RollingVaccinationNumbers
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated