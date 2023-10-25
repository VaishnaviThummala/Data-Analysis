select*
from Covid19..Deaths
where continent is not null
order by 3,4


select location, date, total_cases, new_cases, total_deaths, population
from Covid19..Deaths
where continent is not null
order by 1,2

--Total Cases Vs Total Deaths in India
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Covid19..Deaths
where location like '%india%'
and continent is not null
order by 1,2

--Total Cases vs Population
-- Percent of population got Covid

select location, date, total_cases, population, (total_cases/population)*100 as InfectedPopulation
from Covid19..Deaths
where continent is not null
order by 1,2


--Countries with highest case rate vs population
select location, population, max(total_cases) as HighestCaseCount, max((total_cases/population))*100 as InfectedPopulation
from Covid19..Deaths
where continent is not null
group by population, location
order by InfectedPopulation desc


--Countries with Highest Death count
select location, max(cast(total_deaths as int)) as Deathcount
from Covid19..Deaths
where continent is not null
group by location
order by Deathcount desc

--Continents with Highest Death Count
select location, max(cast(total_deaths as int)) as Deathcount
from Covid19..Deaths
where continent is  null and
location not like '%income%'
group by location
order by Deathcount desc

--Global Numbers



select date, sum(new_cases) as GlobalNewcases, sum(new_deaths) as GlobalNewdeaths
from Covid19..Deaths
where continent is not null
group by date 
order by 1, 2

--Total cases and deaths

select sum(new_cases) as GlobalNewcases, sum(new_deaths) as GlobalNewdeaths ,(sum(new_deaths)/sum(new_cases)) as GlobalDeathPercentage
from Covid19..Deaths
where continent is not null
order by 1,2

select*
from Covid19..Deaths dea
join Covid19..vaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date

-- Total Population Vaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as Ongoingpeoplevaccinated
from Covid19..Deaths dea
join Covid19..vaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 1,2



--Percent of people vaccinated using CTE
with popvsvac (continent, location, date, population, new_vaccinations, Ongoingpeoplevaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Ongoingpeoplevaccinated
from Covid19..Deaths dea
join Covid19..vaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
)
select*, (Ongoingpeoplevaccinated/population)*100 as VaccinationPercentage
from popvsvac




--Temp Table
Drop table if exists #percentofvaccination
create table #percentofvaccination
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Ongoingpeoplevaccinated numeric
)


Insert into #percentofvaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Ongoingpeoplevaccinated
from Covid19..Deaths dea
join Covid19..vaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
--where dea.continent is not null
select*, (Ongoingpeoplevaccinated/population)*100 as vaccinationpercentage
from #percentofvaccination




use Covid19
go
Create view Vaccinationpercentage as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Ongoingpeoplevaccinated
from Covid19..Deaths dea
join Covid19..vaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null

select*
from Vaccinationpercentage