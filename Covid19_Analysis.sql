Select *
From Portfolio..Covid_Deaths$
order by 3,4


-- Check the data

Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolio..Covid_Deaths$
order by 1,2


-- Total Cases vs Total Deaths

Select Location, total_cases, total_deaths, (total_deaths/total_cases)*100 as Covid_Death
From Portfolio..Covid_Deaths$
Where location like '%United Kingdom%'
order by 1,2 desc


-- Total Cases vs Population

Select Location, population, total_cases,  (total_cases/population)*100 as Percentage_Infected
From Portfolio..Covid_Deaths$
order by 1,2


-- Population per infection by Countries

Select Location, Population, MAX(total_cases) as MAximum_Infection,  Max((total_cases/population))*100 as Percentage_Infected
From Portfolio..Covid_Deaths$
Group by Location, Population
order by Percentage_Infected desc


-- Death from Covid by countries

Select Location,population, MAX(cast(Total_deaths as int)) as Covid_Death
From Portfolio..Covid_Deaths$
Where continent is not null 
Group by Location, population
order by Covid_Death desc

-- CONTINENTS STATISTICS

-- Deaths from covid by contnients

Select continent, MAX(cast(Total_deaths as int)) as Contninent_Death
From Portfolio..Covid_Deaths$
Where continent is not null 
Group by continent
order by Contninent_Death desc

--Daily Infection by Contninent

Select date, continent, SUM(new_cases) as Total_New_Cases
From Portfolio..Covid_Deaths$
Where continent is not null 
Group by date, continent
order by Total_New_Cases desc

--Daily Death by Contninent

Select date, continent, SUM(new_cases) as Total_New_Cases, SUM(cast(new_deaths as int)) AS Total_New_Death
From Portfolio..Covid_Deaths$
Where continent is not null 
Group by date, continent
order by date desc


-- Percentage Daily Death by Continent
Select date, SUM(new_cases) as Total_New_Cases, SUM(cast(new_deaths as int)) AS Total_New_Death, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 AS PercentageDeath
From Portfolio..Covid_Deaths$
Where continent is not null 
Group by date
order by date desc


-- Combine Covid Data and Vaccination data

SELECT *
FROM Portfolio..Covid_Deaths$ death
join Portfolio..Vaccination$ vaccine
ON death.location = vaccine.location
AND death.date = vaccine.date


--Check the vacination status by continent

SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
FROM Portfolio..Covid_Deaths$ death
join Portfolio..Vaccination$ vaccine
ON death.location = vaccine.location
AND death.date = vaccine.date 
Where death.continent is not null 
ORDER BY 1,2,3


--Arithmetic Sum of New Vaccinations

SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
SUM(CAST(vaccine.new_vaccinations as int)) OVER (Partition by death.location order by death.location, death.date) AS Arithemtic_Sum_of_Vaccine
FROM Portfolio..Covid_Deaths$ death
	join Portfolio..Vaccination$ vaccine
	ON death.location = vaccine.location
	AND death.date = vaccine.date 
Where death.continent is not null 
ORDER BY 2,3


--- Population per Vaccination... To know percentage of people that are vaccinated (This can be done with Use Common Table Expressions CTE)
WITH Pop_per_Vac(Continent, location, date, population,new_vaccinations, Arithemtic_Sum_of_Vaccine)
AS
(
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
SUM(CONVERT(int,vaccine.new_vaccinations)) OVER (Partition by death.location order by death.location, death.date) AS Arithemtic_Sum_of_Vaccine
FROM Portfolio..Covid_Deaths$ death
	join Portfolio..Vaccination$ vaccine
	ON death.location = vaccine.location
	AND death.date = vaccine.date
	WHERE death.continent is not null

)
SELECT *, (Arithemtic_Sum_of_Vaccine/population)*100 AS population_per_vaccination
FROM Pop_per_Vac


-- Use Temoprary Table
DROP TABLE IF EXISTS #Percentage_Vaccinated
CREATE TABLE #Percentage_Vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Arithemtic_Sum_of_Vaccine numeric
)

INSERT INTO #Percentage_Vaccinated
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
SUM(CONVERT(bigint,vaccine.new_vaccinations)) OVER (Partition by death.location order by death.location, death.date) AS Arithemtic_Sum_of_Vaccine
FROM Portfolio..Covid_Deaths$ death
	join Portfolio..Vaccination$ vaccine
	ON death.location = vaccine.location
	AND death.date = vaccine.date
SELECT *, (Arithemtic_Sum_of_Vaccine/population)*100 AS population_per_vaccination
FROM #Percentage_Vaccinated

	-- Create View for visualization
CREATE VIEW Vaccinated_Population AS
SELECT death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
SUM(CONVERT(bigint,vaccine.new_vaccinations)) OVER (Partition by death.location order by death.location, death.date) AS Arithemtic_Sum_of_Vaccine
FROM Portfolio..Covid_Deaths$ death
	join Portfolio..Vaccination$ vaccine
	ON death.location = vaccine.location
	AND death.date = vaccine.date
WHERE death.continent is not null


--- View of Population per infection by Countries
CREATE VIEW infected_numbers AS
Select Location, Population, MAX(total_cases) as MAximum_Infection,  Max((total_cases/population))*100 as Percentage_Infected
From Portfolio..Covid_Deaths$
Group by Location, Population


---- View of Percentage Daily Death by Continent
CREATE VIEW daily_death AS
Select date, SUM(new_cases) as Total_New_Cases, SUM(cast(new_deaths as int)) AS Total_New_Death, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 AS PercentageDeath
From Portfolio..Covid_Deaths$
Where continent is not null 
Group by date

