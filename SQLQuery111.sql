-- A glance at the COVID cases and death table 

SELECT * FROM 
[Portfolio Project].dbo.Covcd

-------------------------------------------------------------------------------------------

-- A glance at the COVID vaccination table

SELECT * FROM
[Portfolio Project].dbo.Covv

-------------------------------------------------------------------------------------------

-- A glance at all the common columns

SELECT continent, location, date FROM
[Portfolio Project].dbo.Covcd
WHERE continent IS NOT NULL
UNION
SELECT continent, location, date FROM
[Portfolio Project].dbo.Covv
WHERE continent IS NOT NULL

-------------------------------------------------------------------------------------------

-- On which date was the first COVID case recorded?

SELECT date, new_cases FROM
[Portfolio Project].dbo.Covcd
WHERE new_cases IS NOT NULL
ORDER BY 1 

-------------------------------------------------------------------------------------------

-- Which month recorded highest number of cases?

SELECT DATEPART(month, date) AS Month, SUM(new_cases) as total_cases
FROM [Portfolio Project].dbo.Covcd
GROUP BY DATEPART(month, date)
ORDER BY 2 DESC

CREATE VIEW Max_Month_cases
AS
SELECT DATEPART(month, date) AS Month, SUM(new_cases) as total_cases
FROM [Portfolio Project].dbo.Covcd
GROUP BY DATEPART(month, date)

-------------------------------------------------------------------------------------------

-- Which country has most cases?

SELECT location, SUM(new_cases) AS Country_TC
FROM [Portfolio Project].dbo.Covcd
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

CREATE VIEW Countrymostcases
AS
SELECT location, SUM(new_cases) AS Country_TC
FROM [Portfolio Project].dbo.Covcd
WHERE continent IS NOT NULL
GROUP BY location

-------------------------------------------------------------------------------------------

-- Which country has highest infection rate

Select cd.location, v.population, MAX(cd.total_cases) as HighestInfectionCount,  Max((cd.total_cases/v.population))*100 as PercentPopulationInfected
From [Portfolio Project].dbo.Covcd cd
JOIN [Portfolio Project].dbo.Covv v
ON cd.location = v.location AND cd.date = v.date
Group by cd.location, v.population
order by 4 desc

CREATE VIEW Perpop_infected
AS
Select cd.location, v.population, MAX(cd.total_cases) as HighestInfectionCount,  Max((cd.total_cases/v.population))*100 as PercentPopulationInfected
From [Portfolio Project].dbo.Covcd cd
JOIN [Portfolio Project].dbo.Covv v
ON cd.location = v.location AND cd.date = v.date
Group by cd.location, v.population

-------------------------------------------------------------------------------------------

-- Which country has highest infection rate (Datewise)

Select cd.location, v.population, cd.date, MAX(cd.total_cases) as HighestInfectionCount,  Max((cd.total_cases/v.population))*100 as PercentPopulationInfected
From [Portfolio Project].dbo.Covcd cd
JOIN [Portfolio Project].dbo.Covv v
ON cd.location = v.location AND cd.date = v.date
Group by cd.location, v.population, cd.date
order by 4 desc

CREATE VIEW Dateperpop_infected
AS
Select cd.location, v.population, cd.date, MAX(cd.total_cases) as HighestInfectionCount,  Max((cd.total_cases/v.population))*100 as PercentPopulationInfected
From [Portfolio Project].dbo.Covcd cd
JOIN [Portfolio Project].dbo.Covv v
ON cd.location = v.location AND cd.date = v.date
Group by cd.location, v.population, cd.date

-------------------------------------------------------------------------------------------

-- Which Country observed most deaths?

SELECT location, SUM(CAST(new_deaths AS INT)) AS Country_TD
FROM [Portfolio Project].dbo.Covcd
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

-------------------------------------------------------------------------------------------

-- Total deaths in different continents

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From [Portfolio Project].dbo.Covcd
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

CREATE VIEW Condeath_count ------------------------
AS
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From [Portfolio Project].dbo.Covcd
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location

-------------------------------------------------------------------------------------------

-- Which country has highest case to death conversion rate?

SELECT location, SUM(new_cases) AS TotNC, SUM(CAST(new_deaths AS INT)) AS TotD, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS Conv_rate
FROM [Portfolio Project].dbo.Covcd
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 4 DESC

CREATE VIEW Casetodeath_rate
AS
SELECT location, SUM(new_cases) AS TotNC, SUM(CAST(new_deaths AS INT)) AS TotD, (SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS Conv_rate
FROM [Portfolio Project].dbo.Covcd
WHERE continent IS NOT NULL
GROUP BY location

-------------------------------------------------------------------------------------------

-- Death percentage over population

SELECT location, population, TotD, (TotD/population)*100 AS Depop
FROM
(SELECT cd.location, v.population, SUM(CAST(cd.new_deaths AS INT)) AS TotD
FROM [Portfolio Project].dbo.Covcd cd
JOIN [Portfolio Project].dbo.Covv v
ON cd.location = v.location AND cd.date = v.date
WHERE cd.continent IS NOT NULL
GROUP BY cd.location, v.population) S1
ORDER BY 4 DESC

-------------------------------------------------------------------------------------------

-- Positive Case percentage over population (USING CTE)

WITH PCPerc (location, population, TotC)
AS
(SELECT cd.location, v.population, SUM(CAST(cd.new_cases AS INT)) AS TotC
FROM [Portfolio Project].dbo.Covcd cd
JOIN [Portfolio Project].dbo.Covv v
ON cd.location = v.location AND cd.date = v.date
WHERE cd.continent IS NOT NULL
GROUP BY cd.location, v.population)

SELECT location, population, TotC, (TotC/population)*100 AS Cspop
FROM
PCPerc
ORDER BY 4 DESC

-------------------------------------------------------------------------------------------

-- How many people got vaccinated in india

SELECT Location, MAX(people_fully_vaccinated) AS fully_vaccinated, SUM(CAST(new_vaccinations AS INT)) AS Tot_vac
FROM [Portfolio Project].dbo.Covv
WHERE continent IS NOT NULL and location = 'India'
GROUP BY location 

-------------------------------------------------------------------------------------------

-- Rolling count of how many people got vaccinated

SELECT cd.continent, cd.location, cd.date, v.population, v.new_vaccinations
, SUM(CAST(v.new_vaccinations AS INT)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS Vac_Sum_count
FROM [Portfolio Project].dbo.Covcd cd
JOIN [Portfolio Project].dbo.Covv v
ON cd.location = v.location AND cd.date = v.date
WHERE cd.continent IS NOT NULL

-------------------------------------------------------------------------------------------

-- When was the highest spike in number of deaths in india [consecutive days] 

SELECT date, (CAST(Lead_deaths AS INT)- CAST(new_deaths AS INT)) AS Difference
FROM
(SELECT date, new_deaths, LEAD (new_deaths) OVER (ORDER BY new_deaths) AS Lead_deaths
FROM [Portfolio Project].dbo.Covcd
WHERE new_deaths IS NOT NULL AND location = 'India') S2
ORDER BY 2 DESC

-------------------------------------------------------------------------------------------

--Creating a Temporary table with rolling sums and vaccination percentage

DROP TABLE if exists Percentpopvac
Create Table Percentpopvac
(
continent nvarchar(255),
location nvarchar(255),
Datte datetime,
Population numeric,
new_vaccinations numeric,
Vac_sum_count numeric
)

Insert into Percentpopvac
SELECT cd.continent, cd.location, cd.date, v.population, v.new_vaccinations,
SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS Vac_sum_count
FROM [Portfolio Project].dbo.Covcd cd
JOIN [Portfolio Project].dbo.Covv v
ON cd.location = v.location AND cd.date = v.date
WHERE cd.continent IS NOT NULL

SELECT *, (Vac_sum_count/population)*100 AS Vacperpop
FROM Percentpopvac

-------------------------------------------------------------------------------------------

-- Creating view for visualization

CREATE VIEW Percentpopvac_tab AS
SELECT cd.continent, cd.location, cd.date, v.population, v.new_vaccinations,
SUM(CONVERT(int, v.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS Vac_sum_count
FROM [Portfolio Project].dbo.Covcd cd
JOIN [Portfolio Project].dbo.Covv v
ON cd.location = v.location AND cd.date = v.date
WHERE cd.continent IS NOT NULL

-------------------------------------------------------------------------------------------

-- Grading countries according to their vaccinations (How many percent of people are vaccinated, 1=Lowest Rank, 4=Highest Rank)

SELECT location, NTILE(4) OVER (ORDER BY Totvac_per_pop) AS Vac_Quartiles
FROM
(SELECT location, population, Totv, (Totv/population)*100 AS Totvac_per_pop
FROM
(SELECT location, population, SUM(CAST(new_vaccinations AS INT)) AS Totv
FROM [Portfolio Project].dbo.Covv
WHERE continent IS NOT NULL
GROUP BY location, population) S4) S5
ORDER BY location

-------------------------------------------------------------------------------------------