SELECT *
From PortfolioProject..CovidDeaths$
order by 3,4

--SELECT *
--From PortfolioProject..CovidVaccination$
--order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1,2

-- Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%Turkey%'
and continent is not null
order by 1,2

-- The data tells us by the end of September 2021, over 6 million people living in Turkey had been infected.
--Shows the likelihood of  dying if you contract covid in Turkey (or any other)

-- Now, looking at Total cases vs Population

Select Location, date, total_cases, population, (total_cases/population)*100 as CaseOverPopulation
From PortfolioProject..CovidDeaths$
Where location like '%Turkey%'
order by 1,2

-- We see an increasing trend in 'case/population ratio' from early 2020 to the end of 2021

--Look at countries with Highest Infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
Group by Location, Population
order by PercentPopulationInfected desc

--What percentage of your population has gotten Covid its been  reported
-- Small populations tend to get higher infection rates

--Lets look at actually how many people died
--Countries with the highest Death Count per Population

Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by Location
order by TotalDeathCount desc

--LETS BREAK THINGS DOWN BY CONTINENT--

Select location, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is null
Group by location
order by TotalDeathCount desc

-- Showing continents with the highest death count

Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Numbers
--how many people died on each day all over the world (sum)
Select date, SUM(new_cases)--, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null
Group by date
order by 1,2

Select date, sum(new_cases) as total_cases,  SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null
Group by date
order by 1,2

Select sum(new_cases) as total_cases,  SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null
--Group by date
order by 1,2

Select *
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccination$ vac
	On dea.location = vac.location 
	and dea.date = vac.date

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccination$ vac
	On dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null
order by 2,3

--We wanna know rolling count, as the number increases we wanna add up new vaccinations.
--showcase!!! 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location)
--We want to partition by/breaking up by location because everytime it gets to new location we want the aggregate function to start over.
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccination$ vac
	On dea.location = vac. location
	and dea.date =vac.date
where dea.continent is not null
order by 2,3

--Order by dea.location, dea.date
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
--We want to partition by/breaking up by location because everytime it gets to new location we want the aggregate function to start over.
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccination$ vac
	On dea.location = vac. location
	and dea.date =vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

With PopulationvsVaccination (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
--We want to partition by/breaking up by location because everytime it gets to new location we want the aggregate function to start over.
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccination$ vac
	On dea.location = vac. location
	and dea.date =vac.date
where dea.continent is not null
--order by 2,3
)
Select * , (RollingPeopleVaccinated/Population)*100
From PopulationvsVaccination

--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
--We want to partition by/breaking up by location because everytime it gets to new location we want the aggregate function to start over.
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccination$ vac
	On dea.location = vac. location
	and dea.date =vac.date
where dea.continent is not null
--order by 2,3

Select * , (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as Worktable
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
--We want to partition by/breaking up by location because everytime it gets to new location we want the aggregate function to start over.
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccination$ vac
	On dea.location = vac. location
	and dea.date =vac.date
where dea.continent is not null
--order by 2,3

Select*
From #PercentPopulationVaccinated

