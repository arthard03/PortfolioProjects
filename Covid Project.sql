select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4 

select *
from PortfolioProject..CovidVaccinations
where continent is not null

order by 3,4

select  location, date,total_cases,new_cases,  total_deaths,population
from PortfolioProject..CovidDeaths
where continent is not null

order by 1,2
 
 --Looking at Total Casses vs Total Deaths
 --Show likehood of dying if you contract covid in your country 
 select  location, date,total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathProcentage 
from PortfolioProject..CovidDeaths
--where location like '%Ukraine%'
where continent is not null
order by 1,2

--Looking at Total Cases vs Population
--Show what percentage of population get Covid
 select  location, date, Population,total_cases,(total_cases/population)*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%Ukraine%'
where continent is not null
order by 1,2

--Looking at Countries with Highest infection Rate compared to Population

 select  Location,  Population,MAX(total_cases)as HighestInfectionCount,Max((total_cases/population))*100 as  PercentagePopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%Ukraine%'
where continent is not null
group by  location, population
order by  PercentagePopulationInfected desc

--Showing Countries with Highest Death Count per Population

 select  Location, Max(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%Ukraine%
where continent is not null
group by  location
order by  TotalDeathCount desc

--Showing continents with the highest death count per population
 select  continent, Max(cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%Ukraine%
where continent is not null
group by  continent
order by  TotalDeathCount desc

--Global Numbers

 select  sum(new_cases)as TotalCases, sum(new_deaths  )as TotalDeaths, 
 sum(new_deaths )/sum((new_cases)+1)*100 as DeathPercentage-- total_deaths,(total_deaths/total_cases)*100 as DeathProcentage 
from PortfolioProject..CovidDeaths
--where location like '%Ukraine%'
where continent is not null
order by 1,2

--Looking at Total Population vs Vaccinations
--CTE
with PopvsVac (Continent , Location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
	as 
	(
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, sum(vac.new_vaccinations) 
	over (partition by  dea.location order by dea.Location ,dea.Date ) as RollingPeopleVaccinated
	
	from PortfolioProject..CovidDeaths dea 
	join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location and dea.date=vac.date
	where dea.continent is not null
	--order by 2,3
	)
	select *,(RollingPeopleVaccinated/Population)*100
	from PopvsVac
	
	--TMP
	drop  table if exists #PerecentPopulationVaccinated
	CREATE TABLE  #PerecentPopulationVaccinated
	(continent nvarchar(255), location nvarchar(255), date datetime , population float , new_vaccination float,  rollingpeoplevaccinated numeric)


	INSERT INTO  #PerecentPopulationVaccinated
		select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, sum(vac.new_vaccinations) 
	over (partition by  dea.location order by dea.Location ,dea.Date ) as RollingPeopleVaccinated
	
	from PortfolioProject..CovidDeaths dea 
	join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location and dea.date=vac.date
	where dea.continent is not null
	--order by 2,3
		select *,(RollingPeopleVaccinated/Population)*100
	from #PerecentPopulationVaccinated


	--Creating view to store data for later visualizations
	--drop view PercentagePopulationVaccinated
	Create view PercentagePopulationVaccinated as 
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, sum(vac.new_vaccinations) 
	over (partition by  dea.location order by dea.Location ,dea.Date ) as RollingPeopleVaccinated
	
	from PortfolioProject..CovidDeaths dea 
	join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location and dea.date=vac.date
	where dea.continent is not null
	--order by 2,3
	SELECT *
FROM PercentagePopulationVaccinated