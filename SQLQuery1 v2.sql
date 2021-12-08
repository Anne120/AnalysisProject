Select *
from PortfolioProject.. CovidDeaths
where continent is not null
order by 3,4

--Select data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2  

--Looking at total cases vs total deaths
--Likelihood of dying if you contract Covid
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where location like '%Kenya%'
order by 1,2


--Total cases vs Population
--What percentage of population got covid
Select location, date, total_cases, population, total_deaths,  (total_cases/population)*100 as PopPercentage
from PortfolioProject..CovidDeaths
Where location like '%Kenya%'
order by 1,2


--Looking at countries with highest infection rate compared to population
Select location, population, Max(total_cases) as HighestInfecionCount,  Max(total_cases/population)*100 as PopPercentage
from PortfolioProject..CovidDeaths
Group by location, population
Order by PopPercentage desc

--Showing countries with highest death count per population
Select location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by location
Order by TotalDeathCount desc



--Showing the continents with  the highest death count
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
Order by TotalDeathCount desc


-- Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2

--Looking at total population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2, 3


 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location Order by dea.location) as rollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 order by 2, 3

 --USE CTE

 With PopvsVac (continent, location, date, population, new_vaccinations, rollingPeopleVaccinated)
 as
 (
  Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location Order by dea.location) as rollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2, 3
 )
 Select *, (rollingPeopleVaccinated/population)
 from PopvsVac

 --Temp table

 Drop table if exists #PercentePopulationVaccinated
 Create Table #PercentePopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric, 
 New_vaccinations numeric,
 rollingPeopleVaccinated numeric
 )

 Insert into #PercentePopulationVaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location Order by dea.location) as rollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 --where dea.continent is not null
 --order by 2, 3

  Select *, (rollingPeopleVaccinated/population)
 from #PercentePopulationVaccinated


 --Creating view to store data for later visualization

 Create View PercentPopulationVaccinated as
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location Order by dea.location) as rollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 --order by 2, 3

 Select *
 From PercentPopulationVaccinated
