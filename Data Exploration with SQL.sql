#Total Death vs total cases in the USA
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM coviddeaths
WHERE location like '%states%'
order by 1, 2 DESC;

#Percentage of population who got COVID in the USA 
SELECT location, date, total_cases, population, (total_cases/population)*100 AS Percentage_Population_Infection
FROM coviddeaths
WHERE location like '%states%'
order by 1, 2;

#Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS Total_cases, MAX((total_cases/population)*100) as Percentage_Population_Infection
FROM coviddeaths
GROUP BY location, population
WHERE continent is not NULL
order by Percentage_Population_Infection DESC;

#Countries with highest deaths count 
SELECT location, population, MAX(total_deaths) AS Total_deaths
FROM coviddeaths
WHERE continent is not NULL
GROUP BY location, population
order by Total_deaths DESC;

#Continents in order of deaths count 
SELECT continent, MAX(total_deaths) AS Total_deaths
FROM coviddeaths
WHERE continent is not NULL
GROUP BY continent
order by Total_deaths DESC;

#Global numbers 
SELECT date, SUM(new_cases) AS Total_Cases, SUM(new_deaths) AS Total_Deaths, (SUM(new_deaths)/SUM(new_cases)) * 100 AS Death_Percentage
FROM coviddeaths
WHERE continent is not NULL
GROUP BY date
order by date;

#Joining the two tables of Covid Deaths and Covid Vaccinations
SELECT *
FROM coviddeaths dea
JOIN covidvaccinations Vac
ON dea.location = Vac.location AND dea.date = Vac.date

#Total population vaccinated in each country 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM coviddeaths dea
JOIN covidvaccinations Vac
ON dea.location = Vac.location AND dea.date = Vac.date
WHERE dea.continent is not NULL
ORDER BY 2, 3;


#Sum of vaccinated population in each country 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER By dea.location, dea.date) 
FROM coviddeaths dea
JOIN covidvaccinations Vac
ON dea.location = Vac.location AND dea.date = Vac.date
WHERE dea.continent is not NULL
ORDER BY 2, 3;

#Percentage of vaccinated population in each country 
With PopVac (Continent, Location, Date, Population, Daily_Vaccinations, Rolling_People_Vaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER By dea.location, dea.date) AS Rolling_People_Vaccinated
FROM coviddeaths dea
JOIN covidvaccinations Vac
ON dea.location = Vac.location AND dea.date = Vac.date
WHERE dea.continent is not NULL
)
SELECT *, (Rolling_People_Vaccinated/Population)*100 AS Vaccinated_Percentage
FROM PopVac;
