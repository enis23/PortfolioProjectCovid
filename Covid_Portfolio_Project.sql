#select * from PortfolioProject.covid_vaccinations
#order by 3,4;
SELECT * FROM PortfolioProject.covid_deaths
where continent != ''
order by 3,4;

#Select Data that we are going to be using

Select Location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject.covid_deaths
order by 1,2;

#Looking at Total Cases vs Total Deaths
#Shows likelihood of dying if you contract covid in your country

Select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.covid_deaths
where location like '%states%'
order by 1,2;

#Looking at Total Cases vs Population
#Shows what percentage of population got Covid

Select Location,date,population,total_cases,(total_cases/population)*100 as DeathPercentage
from PortfolioProject.covid_deaths
#where location like '%states%'
order by 1,2;

#Looking at Countries with Highest Infection Rate compared to Population

SELECT 
    Location,
    population,
    MAX(total_cases) AS HighestInfectionCount,
    MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM
    PortfolioProject.covid_deaths
GROUP BY location , population
ORDER BY PercentPopulationInfected;

#Showing Countries with Highest Death Count per Population

SELECT 
    Location,
    MAX(CAST(total_deaths AS DECIMAL)) AS TotalDeathCount
FROM
    PortfolioProject.covid_deaths
    where continent != ''
GROUP BY location
ORDER BY TotalDeathCount desc;

#Let's break things down by continent

#Showing the continents with the highest death count per population

SELECT 
    continent,
    MAX(CAST(total_deaths AS DECIMAL)) AS TotalDeathCount
FROM
    PortfolioProject.covid_deaths
    where continent != ''
GROUP BY continent
ORDER BY TotalDeathCount desc;


#GLOBAL NUMBERS

SELECT 
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS DECIMAL)) AS toal_deaths,
    SUM(CAST(new_deaths AS DECIMAL)) / SUM((new_cases)) * 100 AS DeathPercentage
FROM
    PortfolioProject.covid_deaths
WHERE
    continent != ''
#GROUP BY date
ORDER BY 1 , 2;

#Looking at Total Population vs Vaccinations

SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date)
    as RollingPeopleVaccinated
   # ,(RollingPeopleVaccinated/population)*100
FROM
    covid_deaths AS dea
        JOIN
    covid_vaccinations AS vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    dea.continent != ''
ORDER BY 2 , 3;

#USE CTE

with PopvsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as(
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date)
    as RollingPeopleVaccinated
   # ,(RollingPeopleVaccinated/population)*100
FROM
    covid_deaths AS dea
        JOIN
    covid_vaccinations AS vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    dea.continent != ''
##ORDER BY 2 , 3
)
select *,(RollingPeopleVaccinated/population)*100
from PopvsVac;

Set session sql_mode='';

#Temp Table
drop table if exists PercentPopulationVaccinated;
create table PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations decimal,
RollingPeopleVaccinated numeric
);

Insert into PercentPopulationVaccinated
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    sum(cast(vac.new_vaccinations as decimal)) over (partition by dea.location order by dea.location,dea.date)
    as RollingPeopleVaccinated
   # ,(RollingPeopleVaccinated/population)*100
FROM
    covid_deaths AS dea
        JOIN
    covid_vaccinations AS vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    dea.continent != '';
##ORDER BY 2 , 3

select *,(RollingPeopleVaccinated/population)*100
from PercentPopulationVaccinated;


#Create View to store data for later visualizations

Create view PercentPopulationVaccinated_ as
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    sum(cast(vac.new_vaccinations as decimal)) over (partition by dea.location order by dea.location,dea.date)
    as RollingPeopleVaccinated
   # ,(RollingPeopleVaccinated/population)*100
FROM
    covid_deaths AS dea
        JOIN
    covid_vaccinations AS vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    dea.continent != '';
##ORDER BY 2 , 3

#Show view


SELECT * FROM PortfolioProject.percentpopulationvaccinated_;

















