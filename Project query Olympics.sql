Create database SQL_Project;
 use sql_project;
 
create table noc_regions
(noc varchar(10),
region varchar(100),
notes varchar(50)
);

create table athlete_events
(ID int,
name varchar(50),
Sex varchar(10),
Age	varchar(10),
Height varchar(10),
Weight varchar(10),
Team varchar(50),
noc varchar(10),
games varchar(50),
Year int,
Season varchar(30),
City varchar(50),
Sport varchar(50),
Event varchar(100),
Medal varchar(10)
);

#1.Total no of Olympic games

select count(distinct games) as totalgames
from athlete_events;

#2.Find the average weight and height of the athletes gender wise

with t as
(select ID, round(avg(weight),2) as avgwgt, round(avg(height),2) as avghgt,   # Used CTE func. to create a temporary table(t) in order
	  sex                                                                     # to get average of height and weight for unique people.
	  from athlete_events
	  group by ID, sex)
select sex, round(avg(avgwgt),2) as AvgWgt, round(avg(avghgt),2) AvgHgt      # Extracted the desired data from the temp table(t) and
from t                                                                       # grouped it gender wise.
group by sex;

#3.Top 5 athletes with most medals in their career

 with t1 as
            (select name, team, count(*) as total_medals             # Used CTE func to create a temp table(t1) in order
            from athlete_events                                      # to get the desired data for total medals achieved by 
            where medal in ('Gold', 'Silver', 'Bronze')              # each athlete country-wise.
            group by name, team
            order by total_medals desc),
        t2 as
            (select *, dense_rank() over (order by total_medals desc) as rnk   # Used CTE func. to create temp table(t2) in order 
            from t1)                                                           # to get the ranks of each athlete according to their 
    select name, team, total_medals, rnk                                       # medal achievement.
    from t2                                         
    where rnk <= 5;                                                  #At the end extracted the top 5 athletes having most medals.
    
#4.Top regions with the highest medals count year wise	
	
Select n.region, year, count(medal) as totalmedal
from athlete_events a inner join noc_regions n                        #Used join func to get the medal count for each region 
using(noc)                                                            #from other table using foreign key as noc.                                                
group by region, year        
order by year;

#5.Country wise average age of the athletes
Select Team, round(avg(age),1) as avgage                    #Used average function to get the average age of athletes country-wise.
from athlete_events
group by team;
            
#6.Players participated in maximum number of events in their whole career and rank them accordingly.
with t1 as 
(select  ID, name as players, count(distinct(event)) as totalevent   # Used CTE function to create a temporary table(t1) which gives 
from athlete_events                                                  # us the count of total events which helps to determine the rank
group by  ID, name                                                   # in the next table(t2) and finally used both the tables in order to get the desired output.
order by totalevent desc), 
t2 as     
     (select *, dense_rank() over (order by totalevent desc) as rnk
	  from t1)
Select *
from t2;

/* 7. Depending upon the average weight of the athletes set a benchmark for 
      getting permitted for qualifying in olympics */
      
select Name, Weight,
case                                           #Used case-when method to check the benchmark for minimum and maximum weight. 
    when Weight < 60
        then "Under-Weight"
    when Weight > 85
        then "Over-Weight"
    else "Normal-Weight"
    End as Status
from athlete_events;

#8. Create a stored procedure to get all the details about a athlete by giving the ID

DELIMITER //
CREATE Procedure GetAthleteDetails (IN ChosenID VarChar(100))
BEGIN 
SELECT *, ID                                             # Used stored procedure to get details of any athlete.
FROM athlete_events                                      # It is used to save time by saving the query on the database server, 
Where ID = chosenID;                                     # as opposed to sending the query from MySQL Workbench to MySQL Server and then running it.
END//
DELIMITER ;

Call GetAthleteDetails(8);

#9. Countries with the most gold, most silver and most bronze medals in each olympic games.

with t1 as
         (Select region as country, count(medal) as gold
         from athlete_events a inner join noc_regions n
		 Where a.noc = n.noc and medal = "gold"
         group by region, medal
		 order by gold desc),
t2 as
         (Select region as country, count(medal) as silver
         from athlete_events a inner join noc_regions n
		 Where a.noc = n.noc and medal = "silver"
         group by region, medal
		 order by silver desc),
t3 as
		(Select region as country, count(medal) as bronze
         from athlete_events a inner join noc_regions n
		 Where a.noc = n.noc and medal = "bronze"
         group by region, medal
		 order by bronze desc)
select * from
t1, t2, t3;

#10. Find the no of olympic games for summer and winter.

Select distinct(year), season
from athlete_events
where season = "Summer" OR Season = "Winter"
order by year;

#11. Games with maximum no of countries that have participated.

  with total_countries as
        (select games, nr.region
        from athlete_events ae
        join noc_regions nr using (noc)
        group by games, nr.region)
    select games, count(*) as total_countries
    from total_countries
    group by games
    order by total_countries desc limit 10;

#12. Countries that got highest medals in winter.

Select n.region, count(medal) as totalmedal
from athlete_events a inner join noc_regions n                        #Used join func to get the medal count for each region 
using(noc)   
Where season = "Winter"                                               #from other table using foreign key as noc.                                                
group by region        
order by totalmedal desc;

#13. Countries that got highest medals in summer.

Select n.region, count(medal) as totalmedal
from athlete_events a inner join noc_regions n                        #Used join func to get the medal count for each region 
using(noc)   
Where season = "Summer"                                               #from other table using foreign key as noc.                                                
group by region        
order by totalmedal desc;

#14. Countries that have participated in both the seasons.

 with tot_games as
              (select count(distinct games) as total_games
              from athlete_events),
          countries as
              (select games, nr.region as country
              from athlete_events a
              join noc_regions n using (noc)
              group by games, n.region),
          countries_participated as
              (select country, count(*) as total_participated_games
              from countries
              group by country)
      select cp.*
      from countries_participated cp
      join tot_games tg on tg.total_games = cp.total_participated_games
      order by 1;
	





