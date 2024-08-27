-- Data of Premier League Player Stats

-- Add columns MnPerGoal, ShotAccuracy, GoalAccuracy

select *
	, MinPerGoal = [Min] / Nullif(G,0)
	, ShotAccuracy =  ROUND(CAST(Sog AS FLOAT)/CAST(Nullif(Shots,0) AS float),3)*100
	, GoalAccuracy =  ROUND(CAST(G AS FLOAT)/CAST(Nullif(Shots,0) AS float),3)*100
from Players


-- Create a new table called InjuredPlayers
-- Get IDs which less than or equal to 300 and choose IsInjured raws randomly and insert  data to the InjuredPlayers table
-- Data type of IsInjured is bit(boolean: if true 1, false 0)

create table InjuredPlayers
(
Id int, IsInjured bit
)

Declare @Id int, @IsInjured bit
set @Id = 1 set @IsInjured = 1 
while @Id <= 300 
begin
	set @IsInjured = round(rand(),0)
	insert into InjuredPlayers values (@Id, @IsInjured)
	set @Id += 1
end

select *
from InjuredPlayers


-- Create a new table  called PlayersNewData insert data to this table

create table PlayersNewData
(
Id int Identity(1,1), Player varchar(100) 
)

insert into PlayersNewData values
('Danny Ings'),
('Michail Antonio'),
('Mason Mount'),
('Todd Cantwell'),
('David Silva'),
('Bernardo Mota Veiga de Carvalho e Silva'),
('Ashley Barnes'),
('Oliver McBurnie'),
('Joshua King'),
('Mahmoud Ahmed Ibrahim Hassan'),
('Harvey Barnes'),
('James Maddison'),
('John Fleck'),
('Leandro Trossard'),
('John Lundstram'),
('James Ward-Prowse'),
('Wesley Moraes Ferreira da Silva'),
('Patrick van Aanholt'),
('John McGinn'),
('Conor Hourihane'),
('Douglas Luiz Soares de Paulo'),
('Gabriel Teodoro Martinelli Silva'),
('Ricardo Domingos Barbosa Pereira'),
('Ben Chilwell'),
('Pedro Lomba Neto'),
('Youri Tielemans'),
('Pierre-Emerick Aubameyang'),
('Raheem Shaquille Sterling'),
('Mohamed Salah Ghaly'),
('Kevin De Bruyne'),
('Dominic Calvert-Lewin'),
('Richarlison de Andrade'),
('Teemu Pukki')

select *
from PlayersNewData


-- Change Identity seed

insert into PlayersNewData  (Id, Player) values
(600, 'Cristiano Ronaldo'),
(601, 'Leonel Messi')

set Identity_insert PlayersNewData on


-- Join table Players to InjuredPlayers table

select *
from Players a 
left Join InjuredPlayers b on a.[rank] = b.id

-- Add a new column to the Player's table
alter table Players add IsInjured bit

-- Update the IsInjured column with the case statement
update a 
set a.IsInjured = case when b.Id is not Null then b.IsInjured else 0 end
from Players a 
left Join InjuredPlayers b on a.[rank] = b.id


-- Work with Merge

MERGE PlayersNewData as T
USING Players as S
ON T.Id = S.[Rank]
WHEN MATCHED Then 
	UPDATE SET T.Player = S.Player
WHEN NOT MATCHED BY TARGET THEN 
	 INSERT (ID, PLAYER) VALUES (S.[RANK], S.PLAYER)
WHEN NOT MATCHED BY SOURCE THEN 
	DELETE; 

select *
from PlayersNewData

select *
from Players


-- Creating a function to get players 
-- who elapsed the most time between their previous and next goal(related @Top variable)

create function udf_TopPlayers(@Top int)
returns table
as 
return (
with CTE as (
	select *, DENSE_RANK() over (order by MinPerGoal desc) as DRNK
	From 
		(
		select *
			, MinPerGoal = isnull([Min] / Nullif(G,0), 0)
			, ShotAccuracy =  ROUND(CAST(Sog AS FLOAT)/CAST(Nullif(Shots,0) AS float),3)*100
			, GoalAccuracy =  ROUND(CAST(G AS FLOAT)/CAST(Nullif(Shots,0) AS float),3)*100
		from Players
		) a 
            )
select *
from CTE 
where DRNK <= @Top
)

SELECT * FROM udf_TopPlayers(5)

-- Join inline table-valued function to table Players

select *
from udf_TopPlayers (50) a
join Players b on a.Player = b.Player


--Creating a procedure and using the function in that procedure

create proc uspTopPlayers @Best int
as
begin
	select *
	from udf_TopPlayers (@Best) a
	join Players b on a.Player = b.Player
end

exec uspTopPlayers 15
 
