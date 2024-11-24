select*
from PortfolioSqlDataEx..CovidDeaths
where continent is not null
order by 3,4

--select*
--from PortfolioSqlDataEx..CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioSqlDataEx..CovidDeaths
where continent is not null
order by 1,2

-- looking at total cases vs total deaths
-- likelihood of dying if you contract covid in the US

select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPerc
from PortfolioSqlDataEx..CovidDeaths
where location like '%states%'
order by 1,2

-- looking at total cases vs population
-- percentage of popul who got covid

select location, date, total_cases , population ,(total_cases/population)*100 as InfectionRate
from PortfolioSqlDataEx..CovidDeaths
--where location like '%states%'
order by 1,2


-- looking at countries with highest infection rate
--3
select location, population,  MAX(total_cases) as highestinfectioncount,(MAX(total_cases/population))*100 as percenofpopulinfected
from PortfolioSqlDataEx..CovidDeaths
--where location like '%states%'
Group by location, population
order by percenofpopulinfected desc

-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioSqlDataEx..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc

-- Countries with highest death count per Population

select location,  MAX(cast(total_deaths as int)) as totaldeathcount
from PortfolioSqlDataEx..CovidDeaths
--where location like '%states%'
where continent is not null
Group by location
order by totaldeathcount desc



-- break things downby continent
--continent

select continent,  MAX(cast(total_deaths as int)) as totaldeathcount
from PortfolioSqlDataEx..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by totaldeathcount desc

--Globa numbers
--1
select  SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/ SUM(new_cases)*100 as DeathPerc
from PortfolioSqlDataEx..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2


--2 
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioSqlDataEx..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

--join the 2 tables


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as Rolling_people_vaccinated
From PortfolioSqlDataEx..CovidDeaths dea
Join PortfolioSqlDataEx..CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3
		
-- USe CTE

With PopvsVac (Continent, Location, Date, Population,New_vaccinations, RollingPeopleVaccinated) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.date) as RollingPeopleVaccinated
From PortfolioSqlDataEx..CovidDeaths dea
Join PortfolioSqlDataEx..CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
SELECT * , (RollingPeopleVaccinated/Population)*100
FROM PopvsVac




-- Use Tem table

drop table if exists #percentpopulvaccinated
create Table #percentpopulvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date  datetime,
population numeric,
new_vaccination numeric,
Rollingpeoplevaccinated numeric
)



insert into #percentpopulvaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.date) as RollingPeopleVaccinated
From PortfolioSqlDataEx..CovidDeaths dea
Join PortfolioSqlDataEx..CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--order by 2,3
SELECT * , (RollingPeopleVaccinated/Population)*100
FROM #percentpopulvaccinated


-- Create view to dotre data fpr later visualizations

create view percentpopulationvaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.date) as RollingPeopleVaccinated
From PortfolioSqlDataEx..CovidDeaths dea
Join PortfolioSqlDataEx..CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null

  
 select*
 from percentpopulationvaccinated





