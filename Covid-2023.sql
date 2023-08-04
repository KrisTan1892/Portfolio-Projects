--total cases vs total deaths and their death percentage
--Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From Covid_Deaths
Where Location = 'Philippines' and continent is not null
Order by 1

--Shows percentage of populaion got Covid
Select location, date, population, total_cases, (total_cases/population)*100 as Percent_Population_Infected
From Covid_Deaths
Order by 1

--Countries with highest infection rate compared to population
Select Location, Population, MAX(total_cases) as Highest_Infection_Count, MAX((total_cases/population))*100 as Percent_Population_Infected
From Covid_Deaths
where continent is not null 
Group by location, population
Order by 1


--Showing Total Death Count per Country and Population

Select Location, MAX(cast(Total_deaths as int)) as Total_Death_Count
From Covid_Deaths
Where continent is not null
Group by location
Order by 2 desc

--Breaking things down by continent
--Showing continents with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as Total_Death_Count
From Covid_Deaths
Where continent is not null 
Group by continent
Order by 2 desc




--Drill down Asia. ex: Get those countries and find out who had the highest infection rate, anything you can find out and put on views

--Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int)) / SUM(New_Cases)*100 as Death_Percentage
From Covid_Deaths
Where continent is not null 
Group by date
order by 1

--Global Death Percentage of Covid 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int)) / SUM(New_Cases)*100 as Death_Percentage
From Covid_Deaths
Where continent is not null 
order by 1


--Looking at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From Covid_Deaths dea
Join Covid_Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null 
Order by 1


--If u want to remove the date duplicates for a better view later in tableau
WITH CTE AS (
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        ROW_NUMBER() OVER (PARTITION BY dea.continent, dea.location, dea.date, dea.population ORDER BY vac.new_vaccinations) AS rn
    FROM
        Covid_Deaths dea
    JOIN Covid_Vaccinations vac 
	ON dea.location = vac.location 
	AND dea.date = vac.date
    WHERE
        dea.continent IS NOT NULL
    -- AND vac.new_vaccinations IS NOT NULL
)
SELECT
    continent,
    location,
    date,
    population,
    new_vaccinations
FROM
    CTE
WHERE
    rn = 1
ORDER BY 1;


















--Looking at total population vs vaccinations (ROLLING COUNT) Again we are having duplicated date values just use the cte's all over again
--HAVING LOTS OF PROBLEM IN THE ROLLING COUNT THERES SOMETHING MISSING AND KAPOY
-- IM WORKING ON HOW MA ASCEND NAKO (date and variable) WITHOUT THE DUPLICATED ROWS 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_Count
From Covid_Deaths dea
Join Covid_Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null --and vac.new_vaccinations is not null 
Order by 3 asc




--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_Count
From Covid_Deaths dea
Join Covid_Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null and vac.new_vaccinations is not null 
--Order by 3 asc
)

Select *, (Rolling_People_Vaccinated/Population)*100
From PopvsVac


--Temp Tables
  Drop table if exists #Percent_People_Vaccinated
Create table #Percent_population_vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vacinnations numeric,
Rolling_People_Vaccinated numeric,
)

Insert Into #Percent_population_vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_Count
From Covid_Deaths dea
Join Covid_Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null --and vac.new_vaccinations is not null 
Order by 3 asc

Select *, (Rolling_People_Vaccinated/Population)*100 
From #Percent_population_vaccinated 


--Creating view to store data later visualizations

Create View Percent_people_vaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as Rolling_Count
From Covid_Deaths dea
Join Covid_Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null --and vac.new_vaccinations is not null 
--Order by 3 asc