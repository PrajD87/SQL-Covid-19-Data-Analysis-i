--Select * 
--from ITOM6265_F23_85DhamPraj..CovidDeaths
--order by 3,4

--Select * 
--from ITOM6265_F23_85DhamPraj..CovidVaccinations
--order by 3,4

total cases per country and total deaths ---Changed dataType for total_deaths column to INT
ALTER TABLE ITOM6265_F23_85DhamPraj..CovidDeaths
ALTER COLUMN total_deaths int;

--total count of cases and deaths per continent and location
SELECT continent,location, SUM(total_cases) AS total_cases_count,sum(total_deaths) as total_death_count
FROM ITOM6265_F23_85DhamPraj..CovidDeaths
GROUP BY continent,location
order by 1,2;


--Total cases  and deaths per location per day
SELECT continent,location,date, SUM(total_cases) AS total_cases_count,sum(total_deaths) as total_death_count,(total_deaths/total_cases)*100 as DeathPercantage
FROM ITOM6265_F23_85DhamPraj..CovidDeaths
GROUP BY continent,location,date,(total_deaths/total_cases)*100
order by 2,3;

--number of cases vs population 
SELECT continent,location, max(date),population,total_cases,round((total_cases/population)*100,2) as InfectedPopulationPercantage
FROM ITOM6265_F23_85DhamPraj..CovidDeaths
where location like '%india%'
GROUP BY continent,location,population,total_cases,(total_cases/population)*100
order by 2,3;

--percantage of covid infected people in each country vs its total population.
--used left jpin to select max date.
SELECT 
    cd.continent,cd.location,
    cd.population,cd.total_cases,
    round((cd.total_cases * 100.0 / NULLIF(cd.population, 0)),2) AS InfectedPopulationPercentage
FROM ITOM6265_F23_85DhamPraj..CovidDeaths cd
JOIN (
    SELECT continent,location,MAX(date) AS max_date
    FROM  ITOM6265_F23_85DhamPraj..CovidDeaths
    GROUP BY continent, location
) as sub
ON 
    cd.continent = sub.continent
    AND cd.location = sub.location
    AND cd.date = sub.max_date
group by cd.continent,cd.location,cd.total_cases,(cd.total_cases * 100.0 / NULLIF(cd.population, 0)),cd.population
ORDER BY cd.continent, cd.location;

--OR

select continent,location,population,max(total_cases),max(round((total_cases/population)*100,2)) as InfectedPopulationPercantage
FROM ITOM6265_F23_85DhamPraj..CovidDeaths
GROUP BY continent,location,population
order by InfectedPopulationPercantage desc

-- showing countries with highest death count agaist population
select continent,max(total_deaths)as maximum_deathCount,max(round((total_deaths/population)*100,2)) as DeathPopulationPercantage
FROM ITOM6265_F23_85DhamPraj..CovidDeaths
where continent is not null
GROUP BY continent
order by maximum_deathCount desc

--Global count of total cases and deaths and death percantage for each date

select date,sum(total_cases) as Global_total_cases,sum(total_deaths) as Global_total_cases,round((sum(total_deaths)/sum(total_cases)*100),2) as deathPercantage
FROM ITOM6265_F23_85DhamPraj..CovidDeaths
where continent is not null
group by date
order by 1,2;


--joining 2 tables "covidDeaths" and "CovidVaccinations"

select *
FROM ITOM6265_F23_85DhamPraj..CovidVaccinations as vac
join ITOM6265_F23_85DhamPraj..CovidDeaths as dea
on vac.location = dea.location
 and vac.date = dea.date
 where vac.continent is not null
 order by 1,2

 --% of people vaccinated per continent
 
select vac.continent,vac.location,sum(cast(vac.new_vaccinations as bigint)) as total_vaccinations
FROM ITOM6265_F23_85DhamPraj..CovidVaccinations as vac
join ITOM6265_F23_85DhamPraj..CovidDeaths as dea
on vac.location = dea.location
 and vac.date = dea.date
where vac.continent is not null
group by vac.continent,vac.location
order by 1,2


select dea.continent,dea.location,dea.date,dea.population,
		vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,dea.date) as rollingVaccination
FROM ITOM6265_F23_85DhamPraj..CovidDeaths as dea
left join  ITOM6265_F23_85DhamPraj..CovidVaccinations as vac
		on dea.location = vac.location
		and dea.date = vac.date
where dea.continent is not null
group by dea.continent,dea.location,dea.date,dea.population,
		vac.new_vaccinations
order by 2,3;

---use CTE to calculate % of vaccination vs population.

with new_table ( continent,location,date,population,
		new_vaccinations,rollingVaccination) as
		(select dea.continent,
				dea.location,
				dea.date,
				dea.population,
				vac.new_vaccinations,
				sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location,dea.date) as rollingVaccination
FROM ITOM6265_F23_85DhamPraj..CovidDeaths as dea
left join  ITOM6265_F23_85DhamPraj..CovidVaccinations as vac
		on dea.location = vac.location
			and dea.date = vac.date
where dea.continent is not null
group by dea.continent,dea.location,dea.date,dea.population,
		vac.new_vaccinations
)
select *,round((rollingVaccination/population)*100,2) as percantage_vaccination
from new_table
order by 2,3











