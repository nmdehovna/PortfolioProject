select *
from PortfolioProject..Covid_deaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..Covid_vaccinations
--order by 3,4

-- Select data that we are going to be using

select Location, date, total_cases, new_cases, total_deaths, population_density
from PortfolioProject..Covid_deaths
order by 1,2


--Looking at Total Cases vs Total Deaths
select Location, date, total_cases, total_deaths, cast(total_deaths as float) / CAST(total_cases as float)*100 as DeathPercentage
from PortfolioProject..Covid_deaths
where location like '%argentina%'
order by 1,2

--Looking at Total Cases vs Population
select Location, date, total_cases, population, cast(total_cases as float) / CAST(population as float)*100 as PopulationPercentage
from PortfolioProject..COVID
where location like '%argentina%'
order by 1,2

--Looking at Countries with highest infection rate compared to population
select Location, population, MAX(total_cases) as HighestInfectionCount, MAX(cast(total_cases as float) / CAST(population as float))*100 as PopulationPercentage
from PortfolioProject..COVID
--where location like '%argentina%'
group by Location, Population
order by PopulationPercentage desc

--Showing Countries with Highest Death Count Per Population
select Location, MAX(cast(total_deaths as float)) as TotalDeathCount
from PortfolioProject..Covid_deaths
where continent is not null
--where location like '%argentina%'
group by Location
order by TotalDeathCount desc

-- Let's break things down by continent
select continent, MAX(cast(total_deaths as float)) as TotalDeathCount
from PortfolioProject..Covid_deaths
where continent is not null
--where location like '%argentina%'
group by continent
order by TotalDeathCount desc

--Showing continets with the highest death count per population
select continent, MAX(cast(total_deaths as float)) as TotalDeathCount
from PortfolioProject..Covid_deaths
where continent is not null
--where location like '%argentina%'
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
select SUM(cast(total_cases as float)), SUM(cast(new_deaths as float)), SUM(cast(new_deaths as float)) / SUM(cast(new_cases as float)) * 100 as DeathPercentage
from PortfolioProject..Covid_deaths
--where location like '%argentina%'
where continent is not null
--group by date
order by 1,2

--Looking at Total Population vs Vaccination
select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/vac.population)*100
from PortfolioProject..Covid_deaths dea
Join PortfolioProject..Covid_vaccinations vac
On dea.location = vac.location
and	dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE
with PopVsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as (
select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/vac.population)*100
from PortfolioProject..Covid_deaths dea
Join PortfolioProject..Covid_vaccinations vac
On dea.location = vac.location
and	dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopVsVac

--TEMP Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)
Insert Into #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/vac.population)*100
from PortfolioProject..Covid_deaths dea
Join PortfolioProject..Covid_vaccinations vac
On dea.location = vac.location
and	dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--Creating view to store data for later visualizations
Create View PercentPopulatedVaccinated as
select dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/vac.population)*100
from PortfolioProject..Covid_deaths dea
Join PortfolioProject..Covid_vaccinations vac
On dea.location = vac.location
and	dea.date = vac.date
where dea.continent is not null
--order by 2,3

Drop view PercentPopulatedVaccinated
