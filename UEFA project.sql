/* importing data from source by creating tables */
create table goals(
GOAL_ID varchar,
MATCH_ID varchar,
PID varchar,
DURATION int, 
ASSIST varchar,
GOAL_DESC varchar
)
COPY goals FROM 'C:/Users/neela_ynpe59d/OneDrive/Desktop/PGP DATA SCIENCE/RAVI SQL Project/goals.csv' delimiter ',' csv header;
create table matches(
MATCH_ID varchar,
SEASON varchar,
DATE varchar,
HOME_TEAM varchar, 
AWAY_TEAM varchar,
STADIUM varchar,
HOME_TEAM_SCORE int,
AWAY_TEAM_SCORE int,
PENALTY_SHOOT_OUT int,
ATTENDANCE int
)
copy matches from 'C:/Users/neela_ynpe59d/OneDrive/Desktop/PGP DATA SCIENCE/RAVI SQL Project/Matches.csv' delimiter ',' csv header;
create table players(
PLAYER_ID varchar,
FIRST_NAME varchar,
LAST_NAME varchar,
NATIONALITY varchar,
DOB varchar,
TEAM varchar,
JERSEY_NUMBER int,
POSITION varchar,
HEIGHT int,
WEIGHT int,
FOOT varchar
)
copy players from 'C:/Users/neela_ynpe59d/OneDrive/Desktop/PGP DATA SCIENCE/RAVI SQL Project/Players.csv' delimiter ',' csv header;
create table stadiums(
NAME varchar,
CITY varchar,
COUNTRY varchar,
CAPACITY int
)
copy stadiums from 'C:/Users/neela_ynpe59d/OneDrive/Desktop/PGP DATA SCIENCE/RAVI SQL Project/Stadiums.csv' delimiter ',' csv header;
create table teams (
TEAM_NAME varchar,
COUNTRY varchar,
HOME_STADIUM varchar
)	
copy teams from 'C:/Users/neela_ynpe59d/OneDrive/Desktop/PGP DATA SCIENCE/RAVI SQL Project/Teams.csv' delimiter ',' csv header;

select * from teams 
select * from stadiums
select * from players 
select * from matches
select * from goals

/* task 1:Count the Total Number of Teams */
select count(*) as Total_teams from teams;

/* task 2:Find the Number of Teams per Country*/
select country, count(*) as teams_per_country from teams
group by country;

/*task 3:Calculate the Average Team Name Length*/
select avg(length(team_name)) as Average_Team_Name_Length from teams;

/*task 4:Calculate the Average Stadium Capacity in Each Country round it off and sort by the total stadiums in the country*/
select round(avg(capacity)) as Avg_stadium_capacity,
count(*) as Total_stadiums
from stadiums
group by country
order by Total_stadiums desc;

/* task 5:Calculate the Total Goals Scored.*/
select sum(home_team_score + away_team_score) as Total_goals from matches;

/*task 6:Find the total teams that have city in their names*/
select count(*) as team_named_cities  from teams
where team_name like '%city%'

/* task 7: Use Text Functions to Concatenate the Team's Name and Country*/
select team_name || '-' || country as concatenated_team_name  from teams

/* task 8:What is the highest attendance recorded in the dataset, 
and which match (including home and away teams, and date) does it correspond to? */
select home_team,away_team,attendance,date from matches 
order by attendance Desc
limit 1;

/* task 9:What is the lowest attendance recorded in the dataset, 
and which match (including home and away teams, and date) does it correspond to set the criteria as greater than 1 
as some matches had 0 attendance because of covid.*/
select home_team,away_team,attendance,date from matches
where attendance > 1
order by attendance asc

/* task 10: Identify the match with the highest total score (sum of home and away team scores) in the dataset. 
Include the match ID, home and away teams, and the total score.*/
select match_id,home_team,home_team,attendance,date,(home_team_score + away_team_score) as highest_total_score
from matches
order by highest_total_score desc

/* task 11:Find the total goals scored by each team, distinguishing between home and away goals. 
Use a CASE WHEN statement to differentiate home and away goals within the subquery*/
select team_name,
(select sum(home_team_score)
from matches
where matches.home_team=teams.team_name)as home_goals,
(select sum(away_team_score)
from matches
where matches.away_team=teams.team_name)as away_goals
from teams
order by home_goals desc

/* task 12: windows function - Rank teams based on their total scored goals (home and away combined) using a window function.
In the stadium Old Trafford.*/
select team_name, rank() over (order by sum(goals) desc) as rank
from (
select team_name, 
case when home_team = team_name then home_team_score else away_team_score end as goals
from matches
join Teams on home_team = team_name or away_team = team_name
where stadium = 'Old Trafford')as team_goals
group by team_name;

/* task 13: TOP 5 players who scored the most goals in Old Trafford,
ensuring null values are not included in the result (especially pertinent for cases where a player might not have scored any goals).*/
select pid, count(*) as goals
from goals
join matches on goals.match_id=matches.match_id
where matches.stadium='Old Trafford'
group by pid
order by goals desc
limit 5;

/* task 14:Write a query to list all players along with the total number of goals they have scored. 
Order the results by the number of goals scored in descending order to easily identify the top 6 scorers.*/
select pid, count(*) as total_goals
from goals
group by pid
order by total_goals desc
limit 5;

/*task 15:Identify the Top Scorer for Each Team - Find the player from each team who has scored the most goals in all matches combined. 
This question requires joining the Players, Goals, and possibly the Matches tables, 
and then using a subquery to aggregate goals by players and teams.*/
select pid, team, max(total_goals) as max_goals
from (
select players.team, goals.pid, count(*) as total_goals
from goals
join players on goals.pid = players.player_id
group by players.team, Goals.pid
) as team_goals
group by team, pid;

/* task 16:Find the Total Number of Goals Scored in the Latest Season - 
Calculate the total number of goals scored in the latest season available in the dataset. 
This question involves using a subquery to first identify the latest season from the Matches table, 
then summing the goals from the Goals table that occurred in matches from that season.*/
select count(*) as total_goals
from goals
where match_id in (
select match_id
from matches
where season = (select max(season) from Matches)
)

/*task 17: Find Matches with Above Average Attendance - Retrieve a list of matches that had an attendance higher 
than the average attendance across all matches. This question requires a subquery to calculate the average attendance first, 
then use it to filter matches.*/
with avg_attendance as (
select avg(attendance) as avg_attendance
from matches
)
select match_id, home_team, home_team, attendance
from Matches, avg_attendance
where attendance > avg_attendance;

/* task 18:Find the Number of Matches Played Each Month - Count how many matches were played in each month across all seasons. 
This question requires extracting the month from the match dates and grouping the results by this value. as January Feb march*/
select to_char(to_date(date, 'DD-MM-YYYY'), 'Month') as month, count(*) as matches
from matches
group by month
order by matches desc










