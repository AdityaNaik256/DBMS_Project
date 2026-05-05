-- ============================================================
-- Tournament & League Management System - Sample Data
-- MySQL 8.0+
-- Run order : schema.sql → procedures.sql → triggers.sql
--             → functions.sql → sample_data.sql
-- ============================================================
-- Triggers are suppressed during bulk load via @DISABLE_TRIGGER.
-- Standings are inserted manually with pre-calculated values.
-- ============================================================

USE tournament_db;

-- Suppress automatic trigger logic during bulk load
SET @DISABLE_TRIGGER = 1;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE player_stats;
TRUNCATE TABLE standings;
TRUNCATE TABLE match_scores;
TRUNCATE TABLE matches;
TRUNCATE TABLE tournament_sponsors;
TRUNCATE TABLE tournament_teams;
TRUNCATE TABLE players;
TRUNCATE TABLE teams;
TRUNCATE TABLE tournaments;
TRUNCATE TABLE sponsors;
TRUNCATE TABLE venues;
TRUNCATE TABLE sports;
SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- SPORTS  (sport_id 1-4)
-- ============================================================
INSERT INTO sports (sport_name, description) VALUES
('Football',   'Association football, also known as soccer'),
('Cricket',    'Bat-and-ball game played between two teams of eleven players'),
('Kabaddi',    'Contact team sport originating from ancient India'),
('Basketball', 'Team sport where players shoot a ball through a hoop');

-- ============================================================
-- VENUES  (venue_id 1-12)
-- ============================================================
-- Football venues (1-6)
INSERT INTO venues (venue_name, city, country, capacity) VALUES
('Old Trafford',           'Manchester', 'England',  74310),   -- 1
('Emirates Stadium',       'London',     'England',  60704),   -- 2
('Anfield',                'Liverpool',  'England',  53394),   -- 3
('Santiago Bernabeu',      'Madrid',     'Spain',    81044),   -- 4
('Camp Nou',               'Barcelona',  'Spain',    99354),   -- 5
('Wanda Metropolitano',    'Madrid',     'Spain',    68456);   -- 6

-- Cricket venues (7-10)
INSERT INTO venues (venue_name, city, country, capacity) VALUES
('Wankhede Stadium',               'Mumbai',    'India',  33108),  -- 7
('Eden Gardens',                   'Kolkata',   'India',  68000),  -- 8
('M. Chinnaswamy Stadium',         'Bangalore', 'India',  40000),  -- 9
('Narendra Modi Stadium',          'Ahmedabad', 'India', 132000);  -- 10

-- Kabaddi venues (11-12)
INSERT INTO venues (venue_name, city, country, capacity) VALUES
('Dome NSCI SVP Stadium',                      'Mumbai',  'India',  8000),  -- 11
('Netaji Subhash Chandra Bose Indoor Stadium', 'Kolkata', 'India', 12000);  -- 12

-- ============================================================
-- SPONSORS  (sponsor_id 1-6)
-- ============================================================
INSERT INTO sponsors (sponsor_name, contact_email, website) VALUES
('Nike',        'partnerships@nike.com',        'https://www.nike.com'),           -- 1
('Adidas',      'partnerships@adidas.com',       'https://www.adidas.com'),         -- 2
('DreamSports', 'sponsorship@dreamsports.in',    'https://www.dreamsports.in'),     -- 3
('Tata',        'sponsorship@tata.com',          'https://www.tata.com'),           -- 4
('BYJU\'s',     'partnerships@byjus.com',        'https://www.byjus.com'),          -- 5
('Emirates',    'sponsorships@emirates.com',     'https://www.emirates.com');       -- 6

-- ============================================================
-- TEAMS  (team_id 1-34)
-- ============================================================

-- Premier League teams (sport_id=1, team_id 1-6)
INSERT INTO teams (team_name, sport_id, city, home_venue_id, founded_year) VALUES
('Manchester City',    1, 'Manchester', 1, 1880),   -- 1
('Arsenal',            1, 'London',     2, 1886),   -- 2
('Liverpool',          1, 'Liverpool',  3, 1892),   -- 3
('Chelsea',            1, 'London',     1, 1905),   -- 4
('Manchester United',  1, 'Manchester', 1, 1878),   -- 5
('Tottenham Hotspur',  1, 'London',     2, 1882);   -- 6

-- La Liga teams (sport_id=1, team_id 7-12)
INSERT INTO teams (team_name, sport_id, city, home_venue_id, founded_year) VALUES
('Real Madrid',     1, 'Madrid',       4, 1902),   -- 7
('Barcelona',       1, 'Barcelona',    5, 1899),   -- 8
('Atletico Madrid', 1, 'Madrid',       6, 1903),   -- 9
('Sevilla',         1, 'Sevilla',      4, 1890),   -- 10
('Valencia',        1, 'Valencia',     4, 1919),   -- 11
('Real Sociedad',   1, 'San Sebastian',4, 1909);   -- 12

-- IPL teams (sport_id=2, team_id 13-22)
INSERT INTO teams (team_name, sport_id, city, home_venue_id, founded_year) VALUES
('Mumbai Indians',           2, 'Mumbai',    7,  2008),   -- 13
('Chennai Super Kings',      2, 'Chennai',   7,  2008),   -- 14
('Royal Challengers Bangalore', 2, 'Bangalore', 9, 2008), -- 15
('Kolkata Knight Riders',    2, 'Kolkata',   8,  2008),   -- 16
('Delhi Capitals',           2, 'Delhi',     7,  2008),   -- 17
('Rajasthan Royals',         2, 'Jaipur',    7,  2008),   -- 18
('Punjab Kings',             2, 'Mohali',    7,  2008),   -- 19
('Sunrisers Hyderabad',      2, 'Hyderabad', 7,  2013),   -- 20
('Gujarat Titans',           2, 'Ahmedabad', 10, 2022),   -- 21
('Lucknow Super Giants',     2, 'Lucknow',   7,  2022);   -- 22

-- Pro Kabaddi League teams (sport_id=3, team_id 23-34)
INSERT INTO teams (team_name, sport_id, city, home_venue_id, founded_year) VALUES
('Patna Pirates',       3, 'Patna',       11, 2014),   -- 23
('Jaipur Pink Panthers',3, 'Jaipur',      11, 2014),   -- 24
('U Mumba',             3, 'Mumbai',      11, 2014),   -- 25
('Bengaluru Bulls',     3, 'Bangalore',   11, 2014),   -- 26
('Puneri Paltan',       3, 'Pune',        11, 2014),   -- 27
('Tamil Thalaivas',     3, 'Chennai',     11, 2014),   -- 28
('Telugu Titans',       3, 'Hyderabad',   11, 2014),   -- 29
('Bengal Warriors',     3, 'Kolkata',     12, 2014),   -- 30
('Haryana Steelers',    3, 'Chandigarh',  11, 2014),   -- 31
('Dabang Delhi',        3, 'Delhi',       11, 2014),   -- 32
('UP Yoddhas',          3, 'Lucknow',     11, 2014),   -- 33
('Gujarat Giants',      3, 'Ahmedabad',   11, 2014);   -- 34

-- ============================================================
-- TOURNAMENTS  (tournament_id 1-4)
-- ============================================================
INSERT INTO tournaments (tournament_name, sport_id, season, start_date, end_date, format, description) VALUES
('Premier League 2023-24',         1, '2023-24',   '2023-08-11', '2024-05-19', 'League+Knockout', 'English top-flight football league'),
('LaLiga 2023-24',                 1, '2023-24',   '2023-08-12', '2024-05-26', 'League+Knockout', 'Spanish top-flight football league'),
('IPL 2024',                       2, '2024',      '2024-03-22', '2024-05-26', 'League+Knockout', 'Indian Premier League cricket tournament'),
('Pro Kabaddi League Season 10',   3, 'Season 10', '2023-10-05', '2024-01-20', 'League+Knockout', 'Professional kabaddi league in India');

-- ============================================================
-- TOURNAMENT_TEAMS
-- ============================================================
-- Premier League (tournament 1): teams 1-6
INSERT INTO tournament_teams (tournament_id, team_id) VALUES
(1,1),(1,2),(1,3),(1,4),(1,5),(1,6);

-- La Liga (tournament 2): teams 7-12
INSERT INTO tournament_teams (tournament_id, team_id) VALUES
(2,7),(2,8),(2,9),(2,10),(2,11),(2,12);

-- IPL (tournament 3): teams 13-22
INSERT INTO tournament_teams (tournament_id, team_id) VALUES
(3,13),(3,14),(3,15),(3,16),(3,17),(3,18),(3,19),(3,20),(3,21),(3,22);

-- PKL (tournament 4): teams 23-34
INSERT INTO tournament_teams (tournament_id, team_id) VALUES
(4,23),(4,24),(4,25),(4,26),(4,27),(4,28),(4,29),(4,30),(4,31),(4,32),(4,33),(4,34);

-- ============================================================
-- TOURNAMENT_SPONSORS
-- ============================================================
INSERT INTO tournament_sponsors (tournament_id, sponsor_id, sponsorship_amount, contract_type) VALUES
-- Premier League
(1, 1, 5000000.00, 'Title Sponsor'),
(1, 6, 2000000.00, 'Kit Sponsor'),
-- La Liga
(2, 2, 4500000.00, 'Title Sponsor'),
-- IPL
(3, 3, 8000000.00, 'Title Sponsor'),
(3, 4, 3000000.00, 'Official Partner'),
(3, 5, 2500000.00, 'Associate Sponsor'),
-- PKL
(4, 4, 2000000.00, 'Title Sponsor'),
(4, 3, 1500000.00, 'Digital Partner');

-- ============================================================
-- PLAYERS
-- player_id 1-5   : Manchester City
-- player_id 6-10  : Arsenal
-- player_id 11-15 : Liverpool
-- player_id 16-20 : Chelsea
-- player_id 21-25 : Manchester United
-- player_id 26-30 : Tottenham Hotspur
-- player_id 31-35 : Real Madrid
-- player_id 36-40 : Barcelona
-- player_id 41-45 : Atletico Madrid
-- player_id 46-50 : Sevilla
-- player_id 51-55 : Valencia
-- player_id 56-60 : Real Sociedad
-- player_id 61-65 : Mumbai Indians
-- player_id 66-70 : Chennai Super Kings
-- player_id 71-75 : Royal Challengers Bangalore
-- player_id 76-80 : Kolkata Knight Riders
-- player_id 81-85 : Delhi Capitals
-- player_id 86-90 : Rajasthan Royals
-- player_id 91-95 : Punjab Kings
-- player_id 96-100: Sunrisers Hyderabad
-- player_id 101-105: Gujarat Titans
-- player_id 106-110: Lucknow Super Giants
-- player_id 111-115: Patna Pirates
-- player_id 116-120: Jaipur Pink Panthers
-- player_id 121-125: U Mumba
-- player_id 126-130: Bengaluru Bulls
-- player_id 131-135: Puneri Paltan
-- player_id 136-140: Tamil Thalaivas
-- player_id 141-145: Telugu Titans
-- player_id 146-150: Bengal Warriors
-- player_id 151-155: Haryana Steelers
-- player_id 156-160: Dabang Delhi
-- player_id 161-165: UP Yoddhas
-- player_id 166-170: Gujarat Giants
-- ============================================================

-- Manchester City (team 1, sport 1)
INSERT INTO players (player_name, team_id, sport_id, position, nationality, age, jersey_number) VALUES
('Erling Haaland',   1, 1, 'Forward',    'Norwegian',   23,  9),
('Kevin De Bruyne',  1, 1, 'Midfielder', 'Belgian',     32, 17),
('Ederson',          1, 1, 'Goalkeeper', 'Brazilian',   30, 31),
('Ruben Dias',       1, 1, 'Defender',   'Portuguese',  26,  3),
('Phil Foden',       1, 1, 'Midfielder', 'English',     23, 47);

-- Arsenal (team 2, sport 1)
INSERT INTO players (player_name, team_id, sport_id, position, nationality, age, jersey_number) VALUES
('Bukayo Saka',        2, 1, 'Winger',     'English',   22,  7),
('Martin Odegaard',    2, 1, 'Midfielder', 'Norwegian', 25,  8),
('David Raya',         2, 1, 'Goalkeeper', 'Spanish',   28, 22),
('William Saliba',     2, 1, 'Defender',   'French',    22, 12),
('Gabriel Martinelli', 2, 1, 'Winger',     'Brazilian', 22, 11);

-- Liverpool (team 3, sport 1)
INSERT INTO players (player_name, team_id, sport_id, position, nationality, age, jersey_number) VALUES
('Mohamed Salah',         3, 1, 'Forward',  'Egyptian',  31, 11),
('Virgil van Dijk',       3, 1, 'Defender', 'Dutch',     32,  4),
('Alisson Becker',        3, 1, 'Goalkeeper','Brazilian', 31,  1),
('Trent Alexander-Arnold',3, 1, 'Defender', 'English',   25, 66),
('Darwin Nunez',          3, 1, 'Forward',  'Uruguayan', 24,  9);

-- Chelsea (team 4, sport 1)
INSERT INTO players (player_name, team_id, sport_id, position, nationality, age, jersey_number) VALUES
('Cole Palmer',    4, 1, 'Midfielder', 'English',     21, 20),
('Reece James',    4, 1, 'Defender',   'English',     24, 24),
('Robert Sanchez', 4, 1, 'Goalkeeper', 'Spanish',     26,  1),
('Enzo Fernandez', 4, 1, 'Midfielder', 'Argentinian', 23,  8),
('Nicolas Jackson',4, 1, 'Forward',    'Senegalese',  22, 15);

-- Manchester United (team 5, sport 1)
INSERT INTO players (player_name, team_id, sport_id, position, nationality, age, jersey_number) VALUES
('Bruno Fernandes',   5, 1, 'Midfielder', 'Portuguese',  29,  8),
('Marcus Rashford',   5, 1, 'Forward',    'English',     26, 10),
('Andre Onana',       5, 1, 'Goalkeeper', 'Cameroonian', 27, 24),
('Lisandro Martinez', 5, 1, 'Defender',   'Argentinian', 26,  6),
('Rasmus Hojlund',    5, 1, 'Forward',    'Danish',      21, 11);

-- Tottenham Hotspur (team 6, sport 1)
INSERT INTO players (player_name, team_id, sport_id, position, nationality, age, jersey_number) VALUES
('Son Heung-min',     6, 1, 'Forward',    'South Korean',31,  7),
('James Maddison',    6, 1, 'Midfielder', 'English',     27, 10),
('Guglielmo Vicario', 6, 1, 'Goalkeeper', 'Italian',     27,  1),
('Cristian Romero',   6, 1, 'Defender',   'Argentinian', 26, 17),
('Richarlison',       6, 1, 'Forward',    'Brazilian',   26,  9);

-- Real Madrid (team 7, sport 1)
INSERT INTO players (player_name, team_id, sport_id, position, nationality, age, jersey_number) VALUES
('Vinicius Jr',    7, 1, 'Forward',    'Brazilian', 23,  7),
('Jude Bellingham',7, 1, 'Midfielder', 'English',   20,  5),
('Thibaut Courtois',7,1, 'Goalkeeper', 'Belgian',   31,  1),
('David Alaba',    7, 1, 'Defender',   'Austrian',  31,  4),
('Rodrygo',        7, 1, 'Forward',    'Brazilian', 22, 11);

-- Barcelona (team 8, sport 1)
INSERT INTO players (player_name, team_id, sport_id, position, nationality, age, jersey_number) VALUES
('Robert Lewandowski',    8, 1, 'Forward',    'Polish',    35,  9),
('Pedri',                 8, 1, 'Midfielder', 'Spanish',   21,  8),
('Marc-Andre ter Stegen', 8, 1, 'Goalkeeper', 'German',    31,  1),
('Ronald Araujo',         8, 1, 'Defender',   'Uruguayan', 24,  4),
('Gavi',                  8, 1, 'Midfielder', 'Spanish',   19,  6);

-- Atletico Madrid (team 9, sport 1)
INSERT INTO players (player_name, team_id, sport_id, position, nationality, age, jersey_number) VALUES
('Antoine Griezmann', 9, 1, 'Forward',    'French',    32,  7),
('Koke',              9, 1, 'Midfielder', 'Spanish',   31,  6),
('Jan Oblak',         9, 1, 'Goalkeeper', 'Slovenian', 30, 13),
('Jose Gimenez',      9, 1, 'Defender',   'Uruguayan', 29,  2),
('Alvaro Morata',     9, 1, 'Forward',    'Spanish',   31, 19);

-- Sevilla (team 10, sport 1)
INSERT INTO players (player_name, team_id, sport_id, position, nationality, age, jersey_number) VALUES
('Ivan Rakitic',       10, 1, 'Midfielder', 'Croatian',   35, 10),
('Youssef En-Nesyri',  10, 1, 'Forward',    'Moroccan',   26, 15),
('Bono',               10, 1, 'Goalkeeper', 'Moroccan',   32, 13),
('Marcos Acuna',       10, 1, 'Defender',   'Argentinian',32, 19),
('Nemanja Gudelj',     10, 1, 'Midfielder', 'Serbian',    32,  5);

-- Valencia (team 11, sport 1)
INSERT INTO players (player_name, team_id, sport_id, position, nationality, age, jersey_number) VALUES
('Jose Gaya',             11, 1, 'Defender',   'Spanish',   28, 14),
('Justin Kluivert',       11, 1, 'Forward',    'Dutch',     25,  7),
('Giorgi Mamardashvili',  11, 1, 'Goalkeeper', 'Georgian',  23, 25),
('Gabriel Paulista',      11, 1, 'Defender',   'Brazilian', 33,  5),
('Hugo Duro',             11, 1, 'Forward',    'Spanish',   24,  9);

-- Real Sociedad (team 12, sport 1)
INSERT INTO players (player_name, team_id, sport_id, position, nationality, age, jersey_number) VALUES
('David Silva',         12, 1, 'Midfielder', 'Spanish', 37, 21),
('Mikel Oyarzabal',     12, 1, 'Forward',    'Spanish', 26, 10),
('Alex Remiro',         12, 1, 'Goalkeeper', 'Spanish', 28, 25),
('Aritz Elustondo',     12, 1, 'Defender',   'Spanish', 32,  6),
('Ander Barrenetxea',   12, 1, 'Winger',     'Spanish', 22, 17);

-- Mumbai Indians (team 13, sport 2)
INSERT INTO players (player_name, team_id, sport_id, position, nationality, age, jersey_number) VALUES
('Rohit Sharma',       13, 2, 'Batsman',        'Indian',  36, 45),
('Jasprit Bumrah',     13, 2, 'Bowler',         'Indian',  30, 93),
('Hardik Pandya',      13, 2, 'All-rounder',    'Indian',  30,228),
('Suryakumar Yadav',   13, 2, 'Batsman',        'Indian',  33, 63),
('Ishan Kishan',       13, 2, 'Wicket-keeper',  'Indian',  25, 32);

-- Chennai Super Kings (team 14, sport 2)
INSERT INTO players (player_name, team_id, sport_id, position, nationality, age, jersey_number) VALUES
('MS Dhoni',       14, 2, 'Wicket-keeper', 'Indian',        42,  7),
('Ravindra Jadeja',14, 2, 'All-rounder',   'Indian',        35,  8),
('Ruturaj Gaikwad',14, 2, 'Batsman',       'Indian',        27, 31),
('Deepak Chahar',  14, 2, 'Bowler',        'Indian',        31, 90),
('Devon Conway',   14, 2, 'Batsman',       'New Zealander', 32, 18);

-- Royal Challengers Bangalore (team 15, sport 2)
INSERT INTO players (player_name, team_id, sport_id, position, nationality, age, jersey_number) VALUES
('Virat Kohli',     15, 2, 'Batsman',        'Indian',        35, 18),
('Faf du Plessis',  15, 2, 'Batsman',        'South African', 39, 13),
('Mohammed Siraj',  15, 2, 'Bowler',         'Indian',        29, 21),
('Glenn Maxwell',   15, 2, 'All-rounder',    'Australian',    35, 32),
('Dinesh Karthik',  15, 2, 'Wicket-keeper',  'Indian',        38, 19);

-- Kolkata Knight Riders (team 16, sport 2)
INSERT INTO players (player_name, team_id, sport_id, position, nationality, age, jersey_number) VALUES
('Andre Russell',  16, 2, 'All-rounder',  'Jamaican',    35, 12),
('Sunil Narine',   16, 2, 'All-rounder',  'Trinidadian', 35, 74),
('Nitish Rana',    16, 2, 'Batsman',      'Indian',      29,  9),
('Shreyas Iyer',   16, 2, 'Batsman',      'Indian',      29, 41),
('Pat Cummins',    16, 2, 'Bowler',       'Australian',  30, 30);

-- Delhi Capitals (team 17, sport 2)
INSERT INTO players (player_name, team_id, sport_id, position, nationality, age, jersey_number) VALUES
('David Warner',     17, 2, 'Batsman',      'Australian',   37, 31),
('Rishabh Pant',     17, 2, 'Wicket-keeper','Indian',        26, 17),
('Anrich Nortje',    17, 2, 'Bowler',       'South African', 29, 18),
('Axar Patel',       17, 2, 'All-rounder',  'Indian',        29, 20),
('Mitchell Marsh',   17, 2, 'All-rounder',  'Australian',    32,  8);

-- Rajasthan Royals (team 18, sport 2)
INSERT INTO players (player_name, team_id, sport_id, position, nationality, age, jersey_number) VALUES
('Sanju Samson',    18, 2, 'Wicket-keeper', 'Indian',       29, 10),
('Jos Buttler',     18, 2, 'Batsman',       'English',      33, 23),
('Yuzvendra Chahal',18, 2, 'Bowler',        'Indian',       33,  3),
('Shimron Hetmyer', 18, 2, 'Batsman',       'Guyanese',     27,  4),
('Trent Boult',     18, 2, 'Bowler',        'New Zealander',34,  6);

-- Punjab Kings (team 19, sport 2)
INSERT INTO players (player_name, team_id, sport_id, position, nationality, age, jersey_number) VALUES
('Shikhar Dhawan',   19, 2, 'Batsman',     'Indian',   38, 25),
('Liam Livingstone', 19, 2, 'All-rounder', 'English',  30, 23),
('Arshdeep Singh',   19, 2, 'Bowler',      'Indian',   24,  2),
('Sam Curran',       19, 2, 'All-rounder', 'English',  25, 58),
('Jonny Bairstow',   19, 2, 'Batsman',     'English',  34, 51);

-- Sunrisers Hyderabad (team 20, sport 2)
INSERT INTO players (player_name, team_id, sport_id, position, nationality, age, jersey_number) VALUES
('Travis Head',       20, 2, 'Batsman',       'Australian',   30, 10),
('Bhuvneshwar Kumar', 20, 2, 'Bowler',        'Indian',       33, 15),
('Aiden Markram',     20, 2, 'Batsman',       'South African',29, 12),
('Abdul Samad',       20, 2, 'All-rounder',   'Indian',       22, 16),
('Heinrich Klaasen',  20, 2, 'Wicket-keeper', 'South African',32, 32);

-- Gujarat Titans (team 21, sport 2)
INSERT INTO players (player_name, team_id, sport_id, position, nationality, age, jersey_number) VALUES
('Shubman Gill',       21, 2, 'Batsman',       'Indian',       24, 77),
('Mohammed Shami',     21, 2, 'Bowler',        'Indian',       33, 11),
('David Miller',       21, 2, 'Batsman',       'South African',34, 10),
('Rashid Khan',        21, 2, 'Bowler',        'Afghan',       25, 19),
('Wriddhiman Saha',    21, 2, 'Wicket-keeper', 'Indian',       39,  9);

-- Lucknow Super Giants (team 22, sport 2)
INSERT INTO players (player_name, team_id, sport_id, position, nationality, age, jersey_number) VALUES
('KL Rahul',        22, 2, 'Batsman',       'Indian',       31,  1),
('Quinton de Kock', 22, 2, 'Wicket-keeper', 'South African',31, 11),
('Ravi Bishnoi',    22, 2, 'Bowler',        'Indian',       23, 30),
('Marcus Stoinis',  22, 2, 'All-rounder',   'Australian',   34, 12),
('Nicholas Pooran', 22, 2, 'Wicket-keeper', 'Trinidadian',  28, 14);

-- Patna Pirates (team 23, sport 3)
INSERT INTO players (player_name, team_id, sport_id, position, nationality, age, jersey_number) VALUES
('Pardeep Narwal',         23, 3, 'Raider',   'Indian', 28, 37),
('Neeraj Kumar',           23, 3, 'Defender', 'Indian', 26,  5),
('Mohammadreza Shadloui',  23, 3, 'Defender', 'Iranian',27,  7),
('Sachin Tanwar',          23, 3, 'Raider',   'Indian', 22, 29),
('Sunil Malik',            23, 3, 'Defender', 'Indian', 25, 44);

-- Jaipur Pink Panthers (team 24, sport 3)
INSERT INTO players (player_name, team_id, sport_id, position, nationality, age, jersey_number) VALUES
('Arjun Deshwal',    24, 3, 'Raider',   'Indian', 25,  5),
('Ankush',           24, 3, 'Defender', 'Indian', 27, 13),
('Nitin Rawal',      24, 3, 'Defender', 'Indian', 26, 12),
('V Ajith Kumar',    24, 3, 'Raider',   'Indian', 24, 15),
('Reza Mirbagheri',  24, 3, 'Defender', 'Iranian',30, 25);

-- U Mumba (team 25, sport 3)
INSERT INTO players (player_name, team_id, sport_id, position, nationality, age, jersey_number) VALUES
('Abhishek Singh', 25, 3, 'Raider',   'Indian', 24, 30),
('Rinku HC',       25, 3, 'Defender', 'Indian', 26,  7),
('Surinder Singh', 25, 3, 'Defender', 'Indian', 28, 13),
('Shivam Singh',   25, 3, 'Raider',   'Indian', 23, 26),
('Athul MS',       25, 3, 'Defender', 'Indian', 25, 15);

-- Bengaluru Bulls (team 26, sport 3)
INSERT INTO players (player_name, team_id, sport_id, position, nationality, age, jersey_number) VALUES
('Bharat Hooda',   26, 3, 'Raider',   'Indian', 25, 45),
('Saurabh Nandal', 26, 3, 'Defender', 'Indian', 27,  1),
('Aman Antil',     26, 3, 'Defender', 'Indian', 24, 12),
('Neeraj Narwal',  26, 3, 'Raider',   'Indian', 23,  7),
('Mahender Singh', 26, 3, 'Defender', 'Indian', 29, 11);

-- Puneri Paltan (team 27, sport 3)
INSERT INTO players (player_name, team_id, sport_id, position, nationality, age, jersey_number) VALUES
('Aslam Inamdar',    27, 3, 'Raider',   'Indian',  22,  7),
('Fazel Atrachali',  27, 3, 'Defender', 'Iranian', 31,  5),
('Mohit Goyat',      27, 3, 'Raider',   'Indian',  24, 10),
('Sanket Sawant',    27, 3, 'Defender', 'Indian',  26, 17),
('Vishal Bharadwaj', 27, 3, 'All-rounder','Indian', 23, 22);

-- Tamil Thalaivas (team 28, sport 3)
INSERT INTO players (player_name, team_id, sport_id, position, nationality, age, jersey_number) VALUES
('Narender',          28, 3, 'Raider',      'Indian', 23, 99),
('Sagar',             28, 3, 'Defender',    'Indian', 25, 21),
('M Abishek',         28, 3, 'Raider',      'Indian', 22, 19),
('Himanshu',          28, 3, 'All-rounder', 'Indian', 24, 11),
('Sahil Gulia',       28, 3, 'Defender',    'Indian', 26, 15);

-- Telugu Titans (team 29, sport 3)
INSERT INTO players (player_name, team_id, sport_id, position, nationality, age, jersey_number) VALUES
('Monu Goyat',      29, 3, 'Raider',      'Indian', 27,  6),
('Rajnish',         29, 3, 'Defender',    'Indian', 25, 14),
('Vinod Kumar',     29, 3, 'Defender',    'Indian', 26,  8),
('Ankit Beniwal',   29, 3, 'Raider',      'Indian', 24, 20),
('Surjeet Singh',   29, 3, 'All-rounder', 'Indian', 28,  3);

-- Bengal Warriors (team 30, sport 3)
INSERT INTO players (player_name, team_id, sport_id, position, nationality, age, jersey_number) VALUES
('Maninder Singh',  30, 3, 'Raider',      'Indian', 26, 15),
('Shrikant Jadhav', 30, 3, 'Raider',      'Indian', 27, 11),
('Abozar Mighani',  30, 3, 'Defender',    'Iranian',28,  5),
('Amit Kumar',      30, 3, 'Defender',    'Indian', 25,  9),
('Akash Pikalmunde',30, 3, 'All-rounder', 'Indian', 23, 18);

-- Haryana Steelers (team 31, sport 3)
INSERT INTO players (player_name, team_id, sport_id, position, nationality, age, jersey_number) VALUES
('Meetu Sharma',   31, 3, 'Raider',      'Indian', 24,  8),
('Jaideep',        31, 3, 'Defender',    'Indian', 27, 17),
('Rahul Sethpal',  31, 3, 'Defender',    'Indian', 25,  4),
('Vinay',          31, 3, 'Raider',      'Indian', 23, 22),
('Ravi Kumar',     31, 3, 'All-rounder', 'Indian', 26, 19);

-- Dabang Delhi (team 32, sport 3)
INSERT INTO players (player_name, team_id, sport_id, position, nationality, age, jersey_number) VALUES
('Naveen Kumar',    32, 3, 'Raider',      'Indian', 24, 10),
('Vijay Malik',     32, 3, 'Defender',    'Indian', 26,  4),
('Ashu Malik',      32, 3, 'Raider',      'Indian', 22, 16),
('Sandeep Narwal',  32, 3, 'All-rounder', 'Indian', 28, 37),
('Joginder Narwal', 32, 3, 'Defender',    'Indian', 29,  6);

-- UP Yoddhas (team 33, sport 3)
INSERT INTO players (player_name, team_id, sport_id, position, nationality, age, jersey_number) VALUES
('Surender Gill',   33, 3, 'Raider',      'Indian', 25,  7),
('Rohit Tomar',     33, 3, 'Raider',      'Indian', 24, 14),
('Sumit',           33, 3, 'Defender',    'Indian', 26, 32),
('Nitesh Kumar',    33, 3, 'Defender',    'Indian', 27, 24),
('Shubham Kumar',   33, 3, 'All-rounder', 'Indian', 23, 11);

-- Gujarat Giants (team 34, sport 3)
INSERT INTO players (player_name, team_id, sport_id, position, nationality, age, jersey_number) VALUES
('Rakesh Narwal',   34, 3, 'Raider',      'Indian', 26, 17),
('Mahendra Rajput', 34, 3, 'Defender',    'Indian', 28,  5),
('Chandran Ranjit', 34, 3, 'Raider',      'Indian', 25, 22),
('Parvesh Bhainswal',34,3, 'Defender',   'Indian', 27,  8),
('Sonu',            34, 3, 'All-rounder', 'Indian', 24, 33);

-- ============================================================
-- MATCHES
-- match_id  1-12  : Premier League 2023-24  (tournament 1)
-- match_id 13-24  : LaLiga 2023-24          (tournament 2)
-- match_id 25-36  : IPL 2024                (tournament 3)
-- match_id 37-48  : Pro Kabaddi Season 10   (tournament 4)
-- ============================================================

-- ---- Premier League matches (tournament 1) ----
INSERT INTO matches (tournament_id, home_team_id, away_team_id, venue_id, match_date, round_number, match_status) VALUES
(1, 1, 2, 1, '2023-08-12 15:00:00', 1, 'Completed'),  --  1: Man City    3-1 Arsenal
(1, 3, 4, 3, '2023-08-12 17:30:00', 1, 'Completed'),  --  2: Liverpool   1-1 Chelsea
(1, 5, 6, 1, '2023-08-13 14:00:00', 1, 'Completed'),  --  3: Man Utd     2-0 Tottenham
(1, 2, 3, 2, '2023-08-19 15:00:00', 2, 'Completed'),  --  4: Arsenal     2-1 Liverpool
(1, 4, 1, 1, '2023-08-19 17:30:00', 2, 'Completed'),  --  5: Chelsea     0-2 Man City
(1, 6, 5, 2, '2023-08-20 14:00:00', 2, 'Completed'),  --  6: Tottenham   2-2 Man Utd
(1, 1, 3, 1, '2023-08-26 15:00:00', 3, 'Completed'),  --  7: Man City    1-0 Liverpool
(1, 4, 2, 1, '2023-08-26 17:30:00', 3, 'Completed'),  --  8: Chelsea     2-3 Arsenal
(1, 5, 4, 1, '2023-09-02 15:00:00', 4, 'Completed'),  --  9: Man Utd     1-1 Chelsea
(1, 3, 6, 3, '2023-09-02 17:30:00', 4, 'Completed'),  -- 10: Liverpool   3-1 Tottenham
(1, 2, 6, 2, '2023-09-09 15:00:00', 5, 'Completed'),  -- 11: Arsenal     2-0 Tottenham
(1, 1, 5, 1, '2023-09-09 17:30:00', 5, 'Completed');  -- 12: Man City    3-0 Man Utd

-- ---- La Liga matches (tournament 2) ----
INSERT INTO matches (tournament_id, home_team_id, away_team_id, venue_id, match_date, round_number, match_status) VALUES
(2,  7,  8, 4, '2023-08-13 20:00:00', 1, 'Completed'),  -- 13: Real Madrid  3-0 Barcelona
(2,  9, 10, 6, '2023-08-13 17:30:00', 1, 'Completed'),  -- 14: Atletico     1-1 Sevilla
(2, 11, 12, 4, '2023-08-13 15:00:00', 1, 'Completed'),  -- 15: Valencia     2-0 Real Sociedad
(2,  8,  9, 5, '2023-08-20 20:00:00', 2, 'Completed'),  -- 16: Barcelona    2-1 Atletico
(2, 10,  7, 4, '2023-08-20 17:30:00', 2, 'Completed'),  -- 17: Sevilla      0-2 Real Madrid
(2, 12, 11, 4, '2023-08-20 15:00:00', 2, 'Completed'),  -- 18: Real Sociedad 1-2 Valencia
(2,  7,  9, 4, '2023-08-27 20:00:00', 3, 'Completed'),  -- 19: Real Madrid  2-1 Atletico
(2,  8, 10, 5, '2023-08-27 17:30:00', 3, 'Completed'),  -- 20: Barcelona    3-1 Sevilla
(2, 11,  8, 4, '2023-09-03 20:00:00', 4, 'Completed'),  -- 21: Valencia     1-3 Barcelona
(2,  9, 12, 6, '2023-09-03 17:30:00', 4, 'Completed'),  -- 22: Atletico     2-0 Real Sociedad
(2,  7, 12, 4, '2023-09-10 20:00:00', 5, 'Completed'),  -- 23: Real Madrid  4-0 Real Sociedad
(2, 10, 11, 4, '2023-09-10 17:30:00', 5, 'Completed');  -- 24: Sevilla      1-2 Valencia

-- ---- IPL matches (tournament 3) ----
INSERT INTO matches (tournament_id, home_team_id, away_team_id, venue_id, match_date, round_number, match_status) VALUES
(3, 13, 14,  7, '2024-03-22 19:30:00', 1, 'Completed'),  -- 25: MI   185 vs CSK  175
(3, 15, 16,  9, '2024-03-22 15:30:00', 1, 'Completed'),  -- 26: RCB  160 vs KKR  165
(3, 17, 18,  7, '2024-03-23 19:30:00', 1, 'Completed'),  -- 27: DC   190 vs RR   185
(3, 19, 20,  7, '2024-03-28 19:30:00', 2, 'Completed'),  -- 28: PBKS 140 vs SRH  141
(3, 21, 22, 10, '2024-03-29 19:30:00', 2, 'Completed'),  -- 29: GT   200 vs LSG  180
(3, 13, 15,  7, '2024-04-05 19:30:00', 3, 'Completed'),  -- 30: MI   175 vs RCB  178
(3, 14, 16,  7, '2024-04-06 19:30:00', 3, 'Completed'),  -- 31: CSK  180 vs KKR  171
(3, 18, 20,  7, '2024-04-12 19:30:00', 4, 'Completed'),  -- 32: RR   210 vs SRH  200
(3, 21, 13, 10, '2024-04-13 19:30:00', 4, 'Completed'),  -- 33: GT   220 vs MI   225
(3, 16, 18,  8, '2024-04-19 19:30:00', 5, 'Completed'),  -- 34: KKR  195 vs RR   168
(3, 20, 15,  7, '2024-04-20 19:30:00', 5, 'Completed'),  -- 35: SRH  287 vs RCB  262
(3, 22, 14,  7, '2024-04-26 19:30:00', 6, 'Completed');  -- 36: LSG  176 vs CSK  179

-- ---- Pro Kabaddi matches (tournament 4) ----
INSERT INTO matches (tournament_id, home_team_id, away_team_id, venue_id, match_date, round_number, match_status) VALUES
(4, 23, 24, 11, '2023-10-05 20:00:00', 1, 'Completed'),  -- 37: Patna 35-28 Jaipur
(4, 25, 26, 11, '2023-10-06 20:00:00', 1, 'Completed'),  -- 38: U Mumba 32-36 Bengaluru
(4, 27, 28, 11, '2023-10-07 20:00:00', 1, 'Completed'),  -- 39: Puneri 38-30 Tamil
(4, 29, 30, 12, '2023-10-12 20:00:00', 2, 'Completed'),  -- 40: Telugu 28-35 Bengal
(4, 31, 32, 11, '2023-10-13 20:00:00', 2, 'Completed'),  -- 41: Haryana 42-38 Dabang
(4, 33, 34, 11, '2023-10-14 20:00:00', 2, 'Completed'),  -- 42: UP Yoddhas 33-37 Gujarat Giants
(4, 24, 26, 11, '2023-10-19 20:00:00', 3, 'Completed'),  -- 43: Jaipur 39-35 Bengaluru
(4, 23, 25, 11, '2023-10-20 20:00:00', 3, 'Completed'),  -- 44: Patna 40-32 U Mumba
(4, 28, 30, 11, '2023-10-21 20:00:00', 3, 'Completed'),  -- 45: Tamil 30-30 Bengal (Draw)
(4, 32, 27, 11, '2023-10-26 20:00:00', 4, 'Completed'),  -- 46: Dabang 38-40 Puneri
(4, 34, 31, 11, '2023-10-27 20:00:00', 4, 'Completed'),  -- 47: Gujarat Giants 35-38 Haryana
(4, 26, 33, 11, '2023-10-28 20:00:00', 4, 'Completed');  -- 48: Bengaluru 41-36 UP Yoddhas

-- ============================================================
-- MATCH SCORES
-- Triggers are disabled; standings inserted separately below.
-- Football winner_team_id = NULL for draws.
-- Cricket  (IPL): goals = runs scored; no draws possible.
-- Kabaddi  (PKL): goals = raid points; draws possible.
-- ============================================================

SET @DISABLE_TRIGGER = 1;

-- ---- Premier League scores ----
INSERT INTO match_scores (match_id, home_score, away_score, winner_team_id, match_notes) VALUES
( 1, 3, 1,    1, 'Haaland brace, Foden; Saka consolation'),
( 2, 1, 1, NULL, 'Salah vs Palmer - evenly contested'),
( 3, 2, 0,    5, 'Rashford and Hojlund on target'),
( 4, 2, 1,    2, 'Saka and Odegaard; Nunez for Liverpool'),
( 5, 0, 2,    1, 'Man City win away at Stamford Bridge'),
( 6, 2, 2, NULL, 'Son and Richarlison; Bruno and Rashford'),
( 7, 1, 0,    1, 'Foden the difference'),
( 8, 2, 3,    2, 'Martinelli double, Saka; Palmer and Jackson'),
( 9, 1, 1, NULL, 'Bruno vs Palmer share the spoils'),
(10, 3, 1,    3, 'Salah double, Nunez; Son for Spurs'),
(11, 2, 0,    2, 'Odegaard and Martinelli shut out Spurs'),
(12, 3, 0,    1, 'Haaland brace and De Bruyne; dominant display');

-- ---- La Liga scores ----
INSERT INTO match_scores (match_id, home_score, away_score, winner_team_id, match_notes) VALUES
(13, 3, 0,    7, 'Vinicius brace, Bellingham; clean sheet'),
(14, 1, 1, NULL, 'Griezmann vs En-Nesyri - derby draw'),
(15, 2, 0,   11, 'Kluivert and Duro seal the win'),
(16, 2, 1,    8, 'Lewandowski and Pedri; Morata reply'),
(17, 0, 2,    7, 'Bellingham and Rodrygo down Sevilla'),
(18, 1, 2,   11, 'Oyarzabal; Kluivert and Duro for Valencia'),
(19, 2, 1,    7, 'Vinicius and Bellingham; Griezmann'),
(20, 3, 1,    8, 'Lewandowski double, Gavi; En-Nesyri'),
(21, 1, 3,    8, 'Duro; Lewandowski double and Pedri'),
(22, 2, 0,    9, 'Griezmann and Morata; clean sheet'),
(23, 4, 0,    7, 'RM run riot - Vinicius 2, Bellingham, Rodrygo'),
(24, 1, 2,   11, 'En-Nesyri; Kluivert and Duro win it');

-- ---- IPL scores (runs) ----
INSERT INTO match_scores (match_id, home_score, away_score, winner_team_id, match_notes) VALUES
(25, 185, 175,  13, 'Rohit 67, SKY 55; Gaikwad 80 not enough'),
(26, 160, 165,  16, 'Kohli 72; KKR chase down target'),
(27, 190, 185,  17, 'DC defend 190; RR fall 5 short'),
(28, 140, 141,  20, 'SRH win by 1 wicket - thrilling finish'),
(29, 200, 180,  21, 'Gill 89; LSG collapse'),
(30, 175, 178,  15, 'Kohli 82 steers RCB to victory'),
(31, 180, 171,  14, 'Gaikwad 91 leads CSK home'),
(32, 210, 200,  18, 'Buttler 95; SRH fight back in vain'),
(33, 220, 225,  13, 'Rohit 78 leads MI chase of 221'),
(34, 195, 168,  16, 'Russell 54; KKR defend comfortably'),
(35, 287, 262,  20, 'Head 102, Klaasen 80; Kohli 113 not enough'),
(36, 176, 179,  14, 'CSK win by 3 wickets in last over');

-- ---- PKL scores (raid points) ----
INSERT INTO match_scores (match_id, home_score, away_score, winner_team_id, match_notes) VALUES
(37, 35, 28,   23, 'Pardeep Narwal leads Patna to comfortable win'),
(38, 32, 36,   26, 'Bengaluru Bulls storm back in second half'),
(39, 38, 30,   27, 'Inamdar and Atrachali dominate'),
(40, 28, 35,   30, 'Maninder Singh - 12 raid points'),
(41, 42, 38,   31, 'Haryana clinch in a high-scoring contest'),
(42, 33, 37,   34, 'Gujarat Giants edge it in the final minute'),
(43, 39, 35,   24, 'Arjun Deshwal 15 raid points for Jaipur'),
(44, 40, 32,   23, 'Patna maintain perfect home record'),
(45, 30, 30, NULL, 'Enthralling draw - neither side blinks'),
(46, 38, 40,   27, 'Puneri Paltan win away from home'),
(47, 35, 38,   31, 'Haryana Steelers make it two from two'),
(48, 41, 36,   26, 'Bengaluru Bulls dismantle UP Yoddhas');

-- ============================================================
-- STANDINGS  (pre-calculated; triggers bypassed above)
-- Football : 3 pts win | 1 pt draw | 0 pts loss
-- Cricket  : 2 pts win | 0 pts loss  (no draws)
-- Kabaddi  : 5 pts win | 3 pts draw | 0 pts loss
-- ============================================================

-- ---- Premier League standings (tournament 1) ----
-- Man City  : M1(W 3-1), M5(W away 0-2), M7(W 1-0), M12(W 3-0)
-- Arsenal   : M1(L), M4(W 2-1), M8(W away 2-3), M11(W 2-0)
-- Liverpool : M2(D), M4(L away), M7(L away), M10(W 3-1)
-- Chelsea   : M2(D), M5(L home), M8(L home), M9(D)
-- Man Utd   : M3(W), M6(D), M9(D away), M12(L away)
-- Tottenham : M3(L away), M6(D away), M10(L away), M11(L away)
INSERT INTO standings (tournament_id, team_id, played, won, drawn, lost, goals_for, goals_against, points) VALUES
(1,  1, 4, 4, 0, 0,  9,  1, 12),  -- Man City
(1,  2, 4, 3, 0, 1,  8,  6,  9),  -- Arsenal
(1,  5, 4, 1, 2, 1,  5,  6,  5),  -- Manchester United
(1,  3, 4, 1, 1, 2,  5,  5,  4),  -- Liverpool
(1,  4, 4, 0, 2, 2,  4,  7,  2),  -- Chelsea
(1,  6, 4, 0, 1, 3,  3,  9,  1);  -- Tottenham

-- ---- La Liga standings (tournament 2) ----
-- Real Madrid  : M13(W 3-0), M17(W away 0-2), M19(W 2-1), M23(W 4-0)
-- Barcelona    : M13(L away), M16(W 2-1), M20(W 3-1), M21(W away 1-3)
-- Valencia     : M15(W 2-0), M18(W away 1-2), M21(L home 1-3), M24(W away 1-2)
-- Atletico     : M14(D), M16(L away), M19(L away), M22(W 2-0)
-- Sevilla      : M14(D), M17(L home), M20(L away), M24(L home)
-- Real Sociedad: M15(L away), M18(L home), M22(L away), M23(L away)
INSERT INTO standings (tournament_id, team_id, played, won, drawn, lost, goals_for, goals_against, points) VALUES
(2,  7, 4, 4, 0, 0, 11,  1, 12),  -- Real Madrid
(2,  8, 4, 3, 0, 1,  8,  6,  9),  -- Barcelona
(2, 11, 4, 3, 0, 1,  7,  5,  9),  -- Valencia
(2,  9, 4, 1, 1, 2,  5,  5,  4),  -- Atletico Madrid
(2, 10, 4, 0, 1, 3,  3,  8,  1),  -- Sevilla
(2, 12, 4, 0, 0, 4,  1, 10,  0);  -- Real Sociedad

-- ---- IPL standings (tournament 3) ----
-- MI  : M25(W), M30(L), M33(W)   → 2W 1L
-- CSK : M25(L), M31(W), M36(W)   → 2W 1L
-- KKR : M26(W), M31(L), M34(W)   → 2W 1L
-- SRH : M28(W), M32(L), M35(W)   → 2W 1L
-- RCB : M26(L), M30(W), M35(L)   → 1W 2L
-- DC  : M27(W)                   → 1W
-- RR  : M27(L), M32(W), M34(L)   → 1W 2L
-- GT  : M29(W), M33(L)           → 1W 1L
-- PBKS: M28(L)                   → 0W 1L
-- LSG : M29(L), M36(L)           → 0W 2L
INSERT INTO standings (tournament_id, team_id, played, won, drawn, lost, goals_for, goals_against, points) VALUES
(3, 13, 3, 2, 0, 1, 585, 573, 4),  -- Mumbai Indians
(3, 14, 3, 2, 0, 1, 534, 532, 4),  -- Chennai Super Kings
(3, 16, 3, 2, 0, 1, 531, 508, 4),  -- Kolkata Knight Riders
(3, 20, 3, 2, 0, 1, 628, 612, 4),  -- Sunrisers Hyderabad
(3, 17, 1, 1, 0, 0, 190, 185, 2),  -- Delhi Capitals
(3, 15, 3, 1, 0, 2, 600, 627, 2),  -- Royal Challengers Bangalore
(3, 18, 3, 1, 0, 2, 563, 585, 2),  -- Rajasthan Royals
(3, 21, 2, 1, 0, 1, 420, 405, 2),  -- Gujarat Titans
(3, 19, 1, 0, 0, 1, 140, 141, 0),  -- Punjab Kings
(3, 22, 2, 0, 0, 2, 356, 379, 0);  -- Lucknow Super Giants

-- ---- PKL standings (tournament 4) ----
-- Points: Win=5, Draw=3, Loss=0
-- Patna    : M37(W 35-28), M44(W 40-32) → 2W
-- Bengaluru: M38(W away 32-36), M43(L away 39-35), M48(W 41-36) → 2W 1L
-- Puneri   : M39(W 38-30), M46(W away 38-40) → 2W
-- Haryana  : M41(W 42-38), M47(W away 35-38) → 2W
-- Bengal   : M40(W away 28-35), M45(D 30-30) → 1W 1D
-- Jaipur   : M37(L away), M43(W 39-35) → 1W 1L
-- Gujarat G: M42(W away 33-37), M47(L home 35-38) → 1W 1L
-- Tamil    : M39(L away), M45(D home 30-30) → 1D 1L
-- Telugu   : M40(L home 28-35) → 1L
-- Dabang   : M41(L away), M46(L home 38-40) → 2L
-- U Mumba  : M38(L home), M44(L away) → 2L
-- UP Yoddhas: M42(L home), M48(L away) → 2L
INSERT INTO standings (tournament_id, team_id, played, won, drawn, lost, goals_for, goals_against, points) VALUES
(4, 23, 2, 2, 0, 0, 75,  60, 10),  -- Patna Pirates
(4, 26, 3, 2, 0, 1,112, 107, 10),  -- Bengaluru Bulls
(4, 27, 2, 2, 0, 0, 78,  68, 10),  -- Puneri Paltan
(4, 31, 2, 2, 0, 0, 80,  73, 10),  -- Haryana Steelers
(4, 30, 2, 1, 1, 0, 65,  58,  8),  -- Bengal Warriors
(4, 24, 2, 1, 0, 1, 67,  70,  5),  -- Jaipur Pink Panthers
(4, 34, 2, 1, 0, 1, 72,  71,  5),  -- Gujarat Giants
(4, 28, 2, 0, 1, 1, 60,  68,  3),  -- Tamil Thalaivas
(4, 29, 1, 0, 0, 1, 28,  35,  0),  -- Telugu Titans
(4, 32, 2, 0, 0, 2, 76,  82,  0),  -- Dabang Delhi
(4, 25, 2, 0, 0, 2, 64,  76,  0),  -- U Mumba
(4, 33, 2, 0, 0, 2, 69,  78,  0);  -- UP Yoddhas

-- ============================================================
-- PLAYER STATS
-- Football : goals_scored, assists, yellow_cards, red_cards,
--            minutes_played  (special_stat unused)
-- Cricket  : goals_scored = runs, special_stat = wickets
-- Kabaddi  : goals_scored = raid pts, special_stat = tackle pts
-- ============================================================

-- ---- Premier League player stats (tournament 1) ----
-- (player_id, match_id, tournament_id, goals, assists, yc, rc, mins, special)

-- Match 1 : Man City 3-1 Arsenal
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
( 1,  1, 1, 2, 0, 0, 0, 90, 0),  -- Haaland   2 goals
( 2,  1, 1, 0, 2, 0, 0, 90, 0),  -- De Bruyne 2 assists
( 5,  1, 1, 1, 0, 0, 0, 90, 0),  -- Foden     1 goal
( 6,  1, 1, 1, 0, 0, 0, 90, 0);  -- Saka      1 goal (consolation)

-- Match 2 : Liverpool 1-1 Chelsea
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(11,  2, 1, 1, 0, 0, 0, 90, 0),  -- Salah  1 goal
(16,  2, 1, 1, 0, 0, 0, 90, 0);  -- Palmer 1 goal

-- Match 3 : Man Utd 2-0 Tottenham
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(22,  3, 1, 1, 0, 0, 0, 90, 0),  -- Rashford 1 goal
(25,  3, 1, 1, 0, 1, 0, 90, 0);  -- Hojlund  1 goal, 1 YC

-- Match 4 : Arsenal 2-1 Liverpool
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
( 6,  4, 1, 1, 1, 0, 0, 90, 0),  -- Saka       1 goal, 1 assist
( 7,  4, 1, 1, 0, 0, 0, 90, 0),  -- Odegaard   1 goal
(15,  4, 1, 1, 0, 0, 0, 75, 0);  -- Nunez      1 goal

-- Match 5 : Chelsea 0-2 Man City
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
( 1,  5, 1, 1, 0, 0, 0, 90, 0),  -- Haaland    1 goal
( 2,  5, 1, 1, 1, 0, 0, 90, 0);  -- De Bruyne  1 goal, 1 assist

-- Match 6 : Tottenham 2-2 Man Utd
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(26,  6, 1, 1, 0, 0, 0, 90, 0),  -- Son        1 goal
(30,  6, 1, 1, 0, 1, 0, 90, 0),  -- Richarlison 1 goal, 1 YC
(21,  6, 1, 1, 0, 0, 0, 90, 0),  -- Bruno      1 goal
(22,  6, 1, 1, 0, 0, 0, 90, 0);  -- Rashford   1 goal

-- Match 7 : Man City 1-0 Liverpool
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
( 5,  7, 1, 1, 0, 0, 0, 90, 0);  -- Foden 1 goal

-- Match 8 : Chelsea 2-3 Arsenal
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(16,  8, 1, 1, 1, 0, 0, 90, 0),  -- Palmer    1 goal, 1 assist
(20,  8, 1, 1, 0, 0, 0, 90, 0),  -- Jackson   1 goal
(10,  8, 1, 2, 0, 0, 0, 90, 0),  -- Martinelli 2 goals
( 6,  8, 1, 1, 0, 0, 0, 90, 0);  -- Saka      1 goal

-- Match 9 : Man Utd 1-1 Chelsea
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(21,  9, 1, 1, 0, 0, 0, 90, 0),  -- Bruno  1 goal
(16,  9, 1, 1, 0, 1, 0, 90, 0);  -- Palmer 1 goal, 1 YC

-- Match 10 : Liverpool 3-1 Tottenham
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(11, 10, 1, 2, 0, 0, 0, 90, 0),  -- Salah  2 goals
(15, 10, 1, 1, 1, 0, 0, 90, 0),  -- Nunez  1 goal, 1 assist
(26, 10, 1, 1, 0, 0, 0, 85, 0);  -- Son    1 goal

-- Match 11 : Arsenal 2-0 Tottenham
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
( 7, 11, 1, 1, 1, 0, 0, 90, 0),  -- Odegaard  1 goal, 1 assist
(10, 11, 1, 1, 0, 0, 0, 90, 0);  -- Martinelli 1 goal

-- Match 12 : Man City 3-0 Man Utd
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
( 1, 12, 1, 2, 0, 0, 0, 90, 0),  -- Haaland   2 goals
( 2, 12, 1, 1, 2, 0, 0, 90, 0);  -- De Bruyne 1 goal, 2 assists

-- ---- La Liga player stats (tournament 2) ----
-- Match 13 : Real Madrid 3-0 Barcelona
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(31, 13, 2, 2, 0, 0, 0, 90, 0),  -- Vinicius   2 goals
(32, 13, 2, 1, 1, 0, 0, 90, 0);  -- Bellingham 1 goal, 1 assist

-- Match 14 : Atletico 1-1 Sevilla
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(41, 14, 2, 1, 0, 0, 0, 90, 0),  -- Griezmann 1 goal
(47, 14, 2, 1, 0, 1, 0, 90, 0);  -- En-Nesyri 1 goal, 1 YC

-- Match 15 : Valencia 2-0 Real Sociedad
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(52, 15, 2, 1, 1, 0, 0, 90, 0),  -- Kluivert 1 goal, 1 assist
(55, 15, 2, 1, 0, 0, 0, 90, 0);  -- Duro     1 goal

-- Match 16 : Barcelona 2-1 Atletico
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(36, 16, 2, 1, 0, 0, 0, 90, 0),  -- Lewandowski 1 goal
(37, 16, 2, 1, 1, 0, 0, 90, 0),  -- Pedri       1 goal, 1 assist
(45, 16, 2, 1, 0, 1, 0, 90, 0);  -- Morata      1 goal, 1 YC

-- Match 17 : Sevilla 0-2 Real Madrid
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(32, 17, 2, 1, 0, 0, 0, 90, 0),  -- Bellingham 1 goal
(35, 17, 2, 1, 0, 0, 0, 90, 0);  -- Rodrygo    1 goal

-- Match 18 : Real Sociedad 1-2 Valencia
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(57, 18, 2, 1, 0, 0, 0, 90, 0),  -- Oyarzabal 1 goal
(52, 18, 2, 1, 0, 0, 0, 90, 0),  -- Kluivert  1 goal
(55, 18, 2, 1, 1, 0, 0, 90, 0);  -- Duro      1 goal, 1 assist

-- Match 19 : Real Madrid 2-1 Atletico
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(31, 19, 2, 1, 0, 0, 0, 90, 0),  -- Vinicius   1 goal
(32, 19, 2, 1, 1, 0, 0, 90, 0),  -- Bellingham 1 goal, 1 assist
(41, 19, 2, 1, 0, 1, 0, 90, 0);  -- Griezmann  1 goal, 1 YC

-- Match 20 : Barcelona 3-1 Sevilla
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(36, 20, 2, 2, 0, 0, 0, 90, 0),  -- Lewandowski 2 goals
(40, 20, 2, 1, 1, 0, 0, 90, 0),  -- Gavi        1 goal, 1 assist
(47, 20, 2, 1, 0, 0, 0, 90, 0);  -- En-Nesyri   1 goal

-- Match 21 : Valencia 1-3 Barcelona
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(55, 21, 2, 1, 0, 0, 0, 90, 0),  -- Duro        1 goal
(36, 21, 2, 2, 0, 0, 0, 90, 0),  -- Lewandowski 2 goals
(37, 21, 2, 1, 1, 0, 0, 90, 0);  -- Pedri       1 goal, 1 assist

-- Match 22 : Atletico 2-0 Real Sociedad
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(41, 22, 2, 1, 0, 0, 0, 90, 0),  -- Griezmann 1 goal
(45, 22, 2, 1, 0, 0, 0, 90, 0);  -- Morata    1 goal

-- Match 23 : Real Madrid 4-0 Real Sociedad
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(31, 23, 2, 2, 0, 0, 0, 90, 0),  -- Vinicius   2 goals
(32, 23, 2, 1, 2, 0, 0, 90, 0),  -- Bellingham 1 goal, 2 assists
(35, 23, 2, 1, 0, 0, 0, 90, 0);  -- Rodrygo    1 goal

-- Match 24 : Sevilla 1-2 Valencia
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(47, 24, 2, 1, 0, 1, 0, 90, 0),  -- En-Nesyri 1 goal, 1 YC
(52, 24, 2, 1, 1, 0, 0, 90, 0),  -- Kluivert  1 goal, 1 assist
(55, 24, 2, 1, 0, 0, 0, 90, 0);  -- Duro      1 goal

-- ---- IPL player stats (tournament 3) ----
-- goals_scored = runs batted; special_stat = wickets taken
-- minutes_played represents balls faced / balls bowled

-- Match 25 : MI 185 vs CSK 175
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(61, 25, 3, 67, 0, 0, 0, 45, 0),  -- Rohit Sharma 67 runs
(64, 25, 3, 55, 0, 0, 0, 36, 0),  -- SKY          55 runs
(62, 25, 3,  0, 0, 0, 0, 24, 3),  -- Bumrah       3 wickets
(67, 25, 3, 80, 0, 0, 0, 52, 0),  -- Gaikwad      80 runs (CSK)
(66, 25, 3, 32, 0, 0, 0, 20, 0);  -- Dhoni        32 runs

-- Match 26 : RCB 160 vs KKR 165
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(71, 26, 3, 72, 0, 0, 0, 54, 0),  -- Kohli        72 runs
(76, 26, 3, 54, 0, 0, 0, 38, 0),  -- Russell      54 runs
(77, 26, 3, 35, 0, 0, 0, 28, 0),  -- Narine       35 runs
(73, 26, 3,  0, 0, 0, 0, 24, 3);  -- Siraj        3 wickets

-- Match 27 : DC 190 vs RR 185
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(81, 27, 3, 75, 0, 0, 0, 48, 0),  -- Warner       75 runs
(85, 27, 3, 58, 0, 0, 0, 40, 0),  -- Marsh        58 runs
(86, 27, 3, 70, 0, 0, 0, 45, 0),  -- Samson       70 runs
(87, 27, 3, 62, 0, 0, 0, 42, 0),  -- Buttler      62 runs
(90, 27, 3,  0, 0, 0, 0, 20, 3);  -- Boult        3 wickets

-- Match 28 : PBKS 140 vs SRH 141
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(91, 28, 3, 52, 0, 0, 0, 40, 0),  -- Dhawan       52 runs
(96, 28, 3, 62, 0, 0, 0, 44, 0),  -- Travis Head  62 runs
(97, 28, 3,  0, 0, 0, 0, 24, 3);  -- Bhuvneshwar  3 wickets

-- Match 29 : GT 200 vs LSG 180
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(101,29, 3, 89, 0, 0, 0, 58, 0),  -- Shubman Gill 89 runs
(103,29, 3, 55, 0, 0, 0, 38, 0),  -- David Miller 55 runs
(104,29, 3,  0, 0, 0, 0, 24, 3),  -- Rashid Khan  3 wickets
(106,29, 3, 64, 0, 0, 0, 45, 0);  -- KL Rahul     64 runs

-- Match 30 : MI 175 vs RCB 178
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(63, 30, 3, 48, 0, 0, 0, 32, 0),  -- Hardik       48 runs
(71, 30, 3, 82, 0, 0, 0, 54, 0),  -- Kohli        82 runs
(74, 30, 3, 45, 0, 0, 0, 30, 0),  -- Maxwell      45 runs
(62, 30, 3,  0, 0, 0, 0, 24, 2);  -- Bumrah       2 wickets

-- Match 31 : CSK 180 vs KKR 171
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(67, 31, 3, 91, 0, 0, 0, 62, 0),  -- Gaikwad      91 runs
(68, 31, 3, 42, 0, 0, 0, 30, 0),  -- Jadeja       42 runs
(79, 31, 3, 65, 0, 0, 0, 46, 0),  -- Shreyas Iyer 65 runs
(69, 31, 3,  0, 0, 0, 0, 20, 3);  -- Deepak Chahar 3 wickets

-- Match 32 : RR 210 vs SRH 200
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(87, 32, 3, 95, 0, 0, 0, 58, 0),  -- Buttler      95 runs
(86, 32, 3, 68, 0, 0, 0, 44, 0),  -- Samson       68 runs
(96, 32, 3, 72, 0, 0, 0, 46, 0),  -- Travis Head  72 runs
(100,32, 3, 58, 0, 0, 0, 38, 0);  -- Klaasen      58 runs

-- Match 33 : GT 220 vs MI 225
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(101,33, 3, 76, 0, 0, 0, 48, 0),  -- Shubman Gill 76 runs
(103,33, 3, 72, 0, 0, 0, 44, 0),  -- David Miller 72 runs
(61, 33, 3, 78, 0, 0, 0, 50, 0),  -- Rohit        78 runs
(64, 33, 3, 89, 0, 0, 0, 52, 0);  -- SKY          89 runs

-- Match 34 : KKR 195 vs RR 168
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(76, 34, 3, 54, 0, 0, 0, 36, 0),  -- Russell      54 runs
(79, 34, 3, 78, 0, 0, 0, 50, 0),  -- Shreyas Iyer 78 runs
(87, 34, 3, 48, 0, 0, 0, 34, 0),  -- Buttler      48 runs
(80, 34, 3,  0, 0, 0, 0, 24, 3);  -- Pat Cummins  3 wickets

-- Match 35 : SRH 287 vs RCB 262
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(96, 35, 3,102, 0, 0, 0, 58, 0),  -- Travis Head 102 runs
(100,35, 3, 80, 0, 0, 0, 46, 0),  -- Klaasen      80 runs
(71, 35, 3,113, 0, 0, 0, 66, 0),  -- Kohli       113 runs
(72, 35, 3, 64, 0, 0, 0, 40, 0),  -- Faf du Plessis 64 runs
(73, 35, 3,  0, 0, 0, 0, 24, 2);  -- Siraj         2 wickets

-- Match 36 : LSG 176 vs CSK 179
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(106,36, 3, 72, 0, 0, 0, 48, 0),  -- KL Rahul     72 runs
(107,36, 3, 55, 0, 0, 0, 38, 0),  -- de Kock       55 runs
(67, 36, 3, 58, 0, 0, 0, 40, 0),  -- Gaikwad       58 runs
(70, 36, 3, 42, 0, 0, 0, 28, 0),  -- Conway        42 runs
(66, 36, 3, 22, 0, 0, 0, 12, 0);  -- Dhoni (finish) 22*

-- ---- Pro Kabaddi player stats (tournament 4) ----
-- goals_scored = raid points; special_stat = tackle points

-- Match 37 : Patna 35-28 Jaipur
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(111,37, 4, 13, 0, 0, 0, 40, 0),  -- Pardeep  13 raid pts
(114,37, 4,  9, 0, 0, 0, 40, 0),  -- Sachin T  9 raid pts
(113,37, 4,  0, 0, 0, 0, 40, 7),  -- Shadloui  7 tackle pts
(116,37, 4, 10, 0, 0, 0, 40, 0),  -- Arjun Deshwal 10 raid pts
(117,37, 4,  0, 0, 0, 0, 40, 6);  -- Ankush    6 tackle pts

-- Match 38 : U Mumba 32-36 Bengaluru
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(121,38, 4, 11, 0, 0, 0, 40, 0),  -- Abhishek  11 raid pts
(122,38, 4,  0, 0, 0, 0, 40, 6),  -- Rinku HC   6 tackle pts
(126,38, 4, 12, 0, 0, 0, 40, 0),  -- Bharat H  12 raid pts
(127,38, 4,  0, 0, 0, 0, 40, 8);  -- Saurabh N  8 tackle pts

-- Match 39 : Puneri 38-30 Tamil
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(131,39, 4, 14, 0, 0, 0, 40, 0),  -- Inamdar   14 raid pts
(132,39, 4,  0, 0, 0, 0, 40, 9),  -- Atrachali  9 tackle pts
(136,39, 4, 11, 0, 0, 0, 40, 0),  -- Narender  11 raid pts
(139,39, 4,  0, 0, 0, 0, 40, 5);  -- Himanshu   5 tackle pts

-- Match 40 : Telugu 28-35 Bengal
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(141,40, 4, 10, 0, 0, 0, 40, 0),  -- Monu Goyat 10 raid pts
(146,40, 4, 12, 0, 0, 0, 40, 0),  -- Maninder  12 raid pts
(148,40, 4,  0, 0, 0, 0, 40, 8);  -- Abozar     8 tackle pts

-- Match 41 : Haryana 42-38 Dabang
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(151,41, 4, 15, 0, 0, 0, 40, 0),  -- Meetu Sharma 15 raid pts
(152,41, 4,  0, 0, 0, 0, 40, 9),  -- Jaideep       9 tackle pts
(156,41, 4, 14, 0, 0, 0, 40, 0),  -- Naveen Kumar 14 raid pts
(157,41, 4,  0, 0, 0, 0, 40, 7);  -- Vijay Malik   7 tackle pts

-- Match 42 : UP Yoddhas 33-37 Gujarat Giants
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(161,42, 4, 12, 0, 0, 0, 40, 0),  -- Surender Gill 12 raid pts
(166,42, 4, 13, 0, 0, 0, 40, 0),  -- Rakesh Narwal 13 raid pts
(168,42, 4,  0, 0, 0, 0, 40, 7);  -- Chandran       7 tackle pts

-- Match 43 : Jaipur 39-35 Bengaluru
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(116,43, 4, 15, 0, 0, 0, 40, 0),  -- Arjun Deshwal 15 raid pts
(118,43, 4,  0, 0, 0, 0, 40, 8),  -- Nitin Rawal    8 tackle pts
(126,43, 4, 13, 0, 0, 0, 40, 0),  -- Bharat H      13 raid pts
(128,43, 4,  0, 0, 0, 0, 40, 6);  -- Aman Antil     6 tackle pts

-- Match 44 : Patna 40-32 U Mumba
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(111,44, 4, 16, 0, 0, 0, 40, 0),  -- Pardeep  16 raid pts
(112,44, 4,  0, 0, 0, 0, 40, 9),  -- Neeraj K  9 tackle pts
(121,44, 4, 12, 0, 0, 0, 40, 0),  -- Abhishek 12 raid pts
(123,44, 4,  0, 0, 0, 0, 40, 7);  -- Surinder  7 tackle pts

-- Match 45 : Tamil 30-30 Bengal (Draw)
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(136,45, 4, 11, 0, 0, 0, 40, 0),  -- Narender    11 raid pts
(138,45, 4,  0, 0, 0, 0, 40, 7),  -- Himanshu     7 tackle pts
(146,45, 4, 10, 0, 0, 0, 40, 0),  -- Maninder    10 raid pts
(149,45, 4,  0, 0, 0, 0, 40, 6);  -- Amit Kumar   6 tackle pts

-- Match 46 : Dabang 38-40 Puneri
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(156,46, 4, 15, 0, 0, 0, 40, 0),  -- Naveen Kumar 15 raid pts
(158,46, 4,  0, 0, 0, 0, 40, 8),  -- Sandeep N     8 tackle pts
(131,46, 4, 16, 0, 0, 0, 40, 0),  -- Inamdar      16 raid pts
(132,46, 4,  0, 0, 0, 0, 40, 8);  -- Atrachali     8 tackle pts

-- Match 47 : Gujarat Giants 35-38 Haryana
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(166,47, 4, 13, 0, 0, 0, 40, 0),  -- Rakesh N     13 raid pts
(167,47, 4,  0, 0, 0, 0, 40, 7),  -- Mahendra R    7 tackle pts
(151,47, 4, 14, 0, 0, 0, 40, 0),  -- Meetu Sharma 14 raid pts
(153,47, 4,  0, 0, 0, 0, 40, 9);  -- Rahul Sethpal  9 tackle pts

-- Match 48 : Bengaluru 41-36 UP Yoddhas
INSERT INTO player_stats (player_id, match_id, tournament_id, goals_scored, assists, yellow_cards, red_cards, minutes_played, special_stat) VALUES
(126,48, 4, 15, 0, 0, 0, 40, 0),  -- Bharat H     15 raid pts
(127,48, 4,  0, 0, 0, 0, 40, 9),  -- Saurabh N     9 tackle pts
(129,48, 4, 12, 0, 0, 0, 40, 0),  -- Neeraj N     12 raid pts
(161,48, 4, 14, 0, 0, 0, 40, 0),  -- Surender Gill 14 raid pts
(162,48, 4,  0, 0, 0, 0, 40, 6);  -- Rohit Tomar   6 tackle pts

-- ============================================================
-- Re-enable trigger logic for live operations
-- ============================================================
SET @DISABLE_TRIGGER = 0;

-- ============================================================
-- END OF SAMPLE DATA
-- ============================================================
