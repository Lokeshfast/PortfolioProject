
use PortfolioProject;

select * 
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select * from CovidVaccsinations
--order by 3,4

--Select Data that we are going to be use

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


--Looking at Total Cases vs Total Deaths
--show likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths,(total_deaths/total_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2


--looking  at Total Cases vs Population
--show what percentage of population got Covid

select location, date,population, total_cases, (total_cases/population) * 100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2


--looking at Countries with Highest Infection Rate compared to Population

select location, population, MAX(total_cases) as HighestInfectionCount , MAX(total_cases/population) * 100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc


--showing Countries with Highest Death Count per Population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc


--BREAKING THINGS DOWN BY CONTINENT 

--Showing continent with the highest death count per population


select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMBER

select SUM(new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_deaths ,
SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
   
   Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


--USE CTE to perform Calculation by in previous query

with PopvsVac (Continent, Location, data, Population, New_Vaccination, RollingPeopleVaccinated)
as
(
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)* 100
from PopvsVac


--Using Temp Table to perform Calculation on Partition By in previous query

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccination numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3
select *, (RollingPeopleVaccinated/Population)* 100
from #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3




select * 
from PercentPopulationVaccinated
 








