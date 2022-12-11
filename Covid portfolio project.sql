select *
FROM
Portfolio_project..CovidDeaths

--Select the data that we are going to use
select location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_project..CovidDeaths
order by 1,2

-- Total Cases vs Total deaths
select location, date, total_cases, total_deaths , (CAST(total_deaths as float)/ cast(total_cases as float))*100 as DeathPercentage
FROM Portfolio_project..CovidDeaths
WHERE location like '%india%'
order by 1,2

-- Looking at Total cases vs population
select location, date, total_cases, population , (CAST(total_cases as float)/ cast(population as float))*100 as DeathPercentage
FROM Portfolio_project..CovidDeaths
--WHERE location like '%india%'
order by 1,2 

-- Looking at countries with highest infection rate compared to population
select location, population, Max(total_cases) AS HighestInfectionCount, MAX((CAST(total_deaths as float))/ cast(population as float))*100 as PercentagePopulationinfected
FROM Portfolio_project..CovidDeaths
--WHERE location like '%india%'
GROUP BY Location, population
order by 4 desc

--showing countries with Highest Death count per population
select location, MAX(total_deaths) as TotalDeathCount
FROM Portfolio_project..CovidDeaths
where continent is not NULL
Group by location
order by TotalDeathCount DESC

-- Showing continents with highest death count per population
select continent, MAX(total_deaths) as TotalDeathCount
FROM Portfolio_project..CovidDeaths
where continent is not NULL
Group by continent
order by TotalDeathCount DESC

--Global Numbers

select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, sum(cast(new_deaths as float))/sum(new_cases)*100 as Deathpercentage
FROM Portfolio_project..CovidDeaths
Where continent is not NULL
Group by date
order by Deathpercentage DESC

--Total population v/s vaccination
--use CTE
with popvsvac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as(
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations, sum(cast(vacc.new_vaccinations as bigint)) OVER (Partition by death.location order by death.location,death.date) as RollingPeopleVaccinated
FROM Portfolio_project..CovidDeaths death
JOIN Portfolio_project..CovidVaccination vacc
On death.location = vacc.location
and death.date=vacc.date 
where death.continent is not null)

select *, (cast(RollingPeopleVaccinated as float)/population)*100
FROM popvsvac


--TEMP TABLE
DROP Table if exists #PercentagePopulationvaccinated
Create table #PercentagePopulationvaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated  numeric
)
Insert into #PercentagePopulationvaccinated
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations, sum(cast(vacc.new_vaccinations as bigint)) OVER (Partition by death.location order by death.location,death.date) as RollingPeopleVaccinated
FROM Portfolio_project..CovidDeaths death
JOIN Portfolio_project..CovidVaccination vacc
On death.location = vacc.location
and death.date=vacc.date 
--where death.continent is not null)
select *, (cast(RollingPeopleVaccinated as float)/population)*100
FROM #PercentagePopulationvaccinated

--creating view to create visualizations

create view  PercentagePopulationvaccinated as 
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations, sum(cast(vacc.new_vaccinations as bigint)) OVER (Partition by death.location order by death.location,death.date) as RollingPeopleVaccinated
FROM Portfolio_project..CovidDeaths death
JOIN Portfolio_project..CovidVaccination vacc
On death.location = vacc.location
and death.date=vacc.date 
where death.continent is not null





