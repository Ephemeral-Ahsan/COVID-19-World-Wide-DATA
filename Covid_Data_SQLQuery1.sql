
--
select * from PortfolioProject..CovidVaccinations
where continent is not null
--

--
select * from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4;
--
-- taking those features we're going to start with.

select location, date , total_cases, new_cases , total_deaths, population 
from PortfolioProject..CovidDeaths 
Where continent is not null 
order by 1,2;

--

--total_cases vs total_deaths

select location, date , total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from PortfolioProject..CovidDeaths 
Where continent is not null 
order by 1,2;

--

-- Total Cases vs Population

select location, date , total_cases, population, (total_cases/population)*100 as InfectedPercentage 
from PortfolioProject..CovidDeaths 
Where continent is not null 
order by 1,2;

--

-- Countries with Highest Infection Rate compared to Population

select location, population, max(total_cases) as HighestInfectedCases, (max(total_cases)/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
group by location,population
order by PercentPopulationInfected desc;

--
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

select location, max(cast(total_deaths as int)) as HighesDeathCases
from PortfolioProject..CovidDeaths
where continent is not null
group by location,population
order by HighesDeathCases desc;

--

-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the Total death count

select continent, SUM(cast(new_deaths as int)) as HighestDeathCases
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by HighestDeathCases desc;



---- GLOBAL NUMBERS

select sum(new_cases) as total_cases,sum(Convert(int,new_deaths)) as total_deaths, (sum(Convert(int,new_deaths))/sum(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine also using CTE to perform Calculation on Partition By in previous query

with PopvsVac( continent,location,date,population,new_vaccinations,RollingPeopleVaccinated )
as

(select dea.continent,dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac ;

---- Using Temp Table to perform Calculation on Partition By in previous query

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

Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
	
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPopVaccinated
From #PercentPopulationVaccinated
where continent is not null
order by location,date

--

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated  as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 as PercentPopVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 