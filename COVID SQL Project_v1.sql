
Select*
From [Covid Project]..CovidDeaths
Order by 3, 4


Select*
From [Covid Project]..CovidVaccinations
Order by 3,4

Select location, date, total_cases,new_cases,total_deaths, population
From [Covid Project]..CovidDeaths	
Order by 1,2

/*This query examines the total cases vs the total deaths to calculate the percentage of deaths based on the total cases
Return all location from a location that contains the word "States" */
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Covid Project]..CovidDeaths
Where location like '%states%'
Order by 1,2

/*This query looks at the total cases in relation to thepopulation to calculate the population infected percentage.*/
Select location, date,population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From [Covid Project]..CovidDeaths
Where location like '%states%' and continent is not null
Order by 1,2

/*This query examines the countries with the highest infection rate compared to the population*/
Select location,population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
From [Covid Project]..CovidDeaths
Where continent is not null
Group by location, population
Order by PercentPopulationInfected desc

/*This query shows countries with highest death count*/
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Covid Project]..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc

/*This query summed the total deaths in each continent. European Union is part of Europe*/
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is null
and location not in ('World', 'European Union', 'International')
Group by location
Order by TotalDeathCount desc

/*This query categorizes by continent from highest death to lowest death counts*/
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Covid Project]..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc

/*This query showcases the total cases, total deaths, and death percentage for each year globally.*/
Select year(date) as Year, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Covid Project]..CovidDeaths
Where continent is not null
Group by Year(date)
Order by 1,2

/* This query showcases the new vaccinations*/
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingVaccination
From [Covid Project]..CovidDeaths dea
Join [Covid Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2, 3

/*This query creates a temporary table using CTE and create table code*/
--Using CTE
With PopvsVacc (Continent, Location, Date, Population, New_Vaccinations, RollingVaccination)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingVaccination
From [Covid Project]..CovidDeaths dea
Join [Covid Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select*, (RollingVaccination/Population)*100 as VaccinationPercentage
From PopvsVacc

--Using Create Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime,
Population numeric,
New_vaccinations numeric, 
RollingVaccination numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingVaccination
From [Covid Project]..CovidDeaths dea
Join [Covid Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select*, (RollingVaccination/Population)*100 as VaccinationPercentage
From #PercentPopulationVaccinated

/*This query creates a view for Data Visualizations (i.e. Tableau)
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingVaccination
From [Covid Project]..CovidDeaths dea
Join [Covid Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null*/
