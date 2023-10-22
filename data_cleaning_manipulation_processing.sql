ALTER TABLE tiktoksongs2020 
ALTER COLUMN duration_ms FLOAT;

UPDATE tiktoksongs2020 SET
duration_ms = ROUND(duration_ms / 60000,1)

-----Top 10 Artist -------
CREATE VIEW top_ten_artists_records AS
WITH tbl_artist_records AS (SELECT DISTINCT SUM(track_pop)
OVER (PARTITION BY artist_name) [total_trackpopulation],
SUM(artist_pop)
OVER (PARTITION BY artist_name) [total_artistpopulation],
artist_name [records_artist_name]
FROM tiktoksongs2020),
tbl_ranking AS(SELECT records_artist_name,RANK() OVER (ORDER BY total_trackpopulation DESC) AS track_ranking,
RANK() OVER (ORDER BY total_artistpopulation DESC) AS artist_ranking, 
total_trackpopulation, total_artistpopulation
FROM tbl_artist_records),
tbl_top_ten_records AS(SELECT records_artist_name,total_trackpopulation, total_artistpopulation
FROM tbl_ranking
WHERE track_ranking <= 10 OR artist_ranking <= 10)
SELECT records_artist_name,total_trackpopulation, total_artistpopulation, danceability,energy,loudness,
mode,key_node,speechiness,acousticness,instrumentalness,liveness,valence,tempo,time_signature,duration_ms
FROM tbl_top_ten_records tr, tiktoksongs2020 ts
WHERE tr.records_artist_name = ts.artist_name;

-----Top 10 Tracks -------
CREATE VIEW top_ten_tracks_records AS
WITH tbl_track_records AS (SELECT DISTINCT SUM(track_pop)
OVER (PARTITION BY track_name) [total_trackpopulation],
SUM(artist_pop)
OVER (PARTITION BY track_name) [total_artistpopulation],
track_name [records_track_name]
FROM tiktoksongs2020),
tbl_ranking AS(SELECT records_track_name,RANK() OVER (ORDER BY total_trackpopulation DESC) AS track_ranking,
RANK() OVER (ORDER BY total_artistpopulation DESC) AS artist_ranking, 
total_trackpopulation, total_artistpopulation
FROM tbl_track_records),
tbl_top_ten_records AS(SELECT records_track_name,total_trackpopulation, total_artistpopulation
FROM tbl_ranking
WHERE track_ranking <= 10 OR artist_ranking <= 10)
SELECT records_track_name,total_trackpopulation, total_artistpopulation, danceability,energy,loudness,
mode,key_node,speechiness,acousticness,instrumentalness,liveness,valence,tempo,time_signature,duration_ms
FROM tbl_top_ten_records tr, tiktoksongs2020 ts
WHERE tr.records_track_name = ts.track_name;

-----Danceability Chart-------
CREATE VIEW danceability AS
WITH tbl_danceability AS(
SELECT CASE WHEN danceability BETWEEN 0 AND 0.1 THEN 'low dance'
WHEN danceability BETWEEN 0.1 AND 0.5 THEN 'moderate dance'
ELSE 'high dance' END [danceability_new],track_pop,artist_pop
FROM tiktoksongs2020)
SELECT DISTINCT SUM(track_pop)
OVER (PARTITION BY danceability_new) [Track Population], 
SUM(artist_pop)
OVER (PARTITION BY danceability_new) [Artist Population], danceability_new [danceability]
FROM tbl_danceability;

-----Change Energy Value-----
CREATE VIEW energy AS
WITH tbl_energy AS (SELECT
CASE WHEN energy BETWEEN 0 AND  0.1 THEN 'classical music or some acoustic ballads'
WHEN energy BETWEEN 0.1 AND  0.5 THEN 'pop, rock, or jazz'
ELSE 'heavy metal, electronic dance music (EDM), or punk rock.' END [genre], track_pop, artist_pop
FROM tiktoksongs2020)
SELECT DISTINCT SUM(track_pop)
OVER (PARTITION BY genre) [Track Population], 
SUM(artist_pop)
OVER (PARTITION BY genre) [Artist Population], genre
FROM tbl_energy;

-----Change loudness Value-----
CREATE VIEW loudness AS
WITH tbl_loudness AS(SELECT
CASE WHEN loudness BETWEEN -2 AND -1 THEN -1
WHEN loudness BETWEEN -3 AND -2 THEN -2
WHEN loudness BETWEEN -4 AND -3 THEN -3
WHEN loudness BETWEEN -5 AND -4 THEN -4
WHEN loudness BETWEEN -6 AND -5 THEN -5
WHEN loudness BETWEEN -7 AND -6 THEN -6
WHEN loudness BETWEEN -8 AND -7 THEN -7
WHEN loudness BETWEEN -9 AND -8 THEN -8
ELSE 
-9 END [loudness],track_pop, artist_pop
FROM tiktoksongs2020)
SELECT DISTINCT SUM(track_pop)
OVER (PARTITION BY loudness) [Track Population], 
SUM(artist_pop)
OVER (PARTITION BY loudness) [Artist Population],
CONCAT(loudness,'dB') loudness
FROM tbl_loudness
;

/*
0: C
1: C♯ (or D♭)
2: D
3: D♯ (or E♭)
4: E
5: F
6: F♯ (or G♭)
7: G
8: G♯ (or A♭)
9: A
10: A♯ (or B♭)
11: B
*/
-----Key node chart-----
CREATE VIEW key_node AS
SELECT DISTINCT SUM(track_pop)
OVER (PARTITION BY key_node) [Track Population], 
SUM(artist_pop)
OVER (PARTITION BY key_node) [Artist Population],
CASE WHEN key_node = 0 THEN 'C'
WHEN key_node = 1 THEN 'C#'
WHEN key_node = 2 THEN 'D'
WHEN key_node = 3 THEN 'D#'
WHEN key_node = 4 THEN 'E'
WHEN key_node = 5 THEN 'F'
WHEN key_node = 6 THEN 'F#'
WHEN key_node = 7 THEN 'G'
WHEN key_node = 8 THEN 'G#'
WHEN key_node = 9 THEN 'A'
WHEN key_node = 10 THEN 'A#'
ELSE 'B' END [Key]
FROM tiktoksongs2020;

-------major minor -------
CREATE VIEW major_minor AS
SELECT DISTINCT SUM(track_pop)
OVER (PARTITION BY mode) [Track Population], 
SUM(artist_pop)
OVER (PARTITION BY mode) [Artist Population],
CASE WHEN mode = 0 THEN 'minor'
ELSE 'major' END [mode]
FROM tiktoksongs2020;

-----Speechiness Chart-----
CREATE VIEW speechiness AS
WITH tbl_speechiness AS(SELECT
CASE WHEN speechiness BETWEEN 0 AND 0.1 THEN 'low speechiness'
WHEN speechiness BETWEEN 0.1 AND 0.5 THEN 'moderate speechiness'
ELSE 'high speechiness'
END [speechiness],track_pop, artist_pop
FROM tiktoksongs2020)
SELECT DISTINCT SUM(track_pop)
OVER (PARTITION BY speechiness) [Track Population], 
SUM(artist_pop)
OVER (PARTITION BY speechiness) [Artist Population], 
[speechiness]
FROM tbl_speechiness;

-----Acousticness Chart-----
CREATE VIEW acousticness AS
WITH tbl_acousticness AS(SELECT
CASE WHEN acousticness BETWEEN 0 AND 0.1 THEN 'low acousticness'
WHEN acousticness BETWEEN 0.1 AND 0.5 THEN 'moderate acousticness'
ELSE 'high acousticness'
END [acousticness],track_pop,artist_pop FROM tiktoksongs2020)
SELECT DISTINCT SUM(track_pop)
OVER (PARTITION BY acousticness) [Track Population], 
SUM(artist_pop)
OVER (PARTITION BY acousticness) [Artist Population], 
acousticness
FROM tbl_acousticness;

-----Change data type int to varchar-----

ALTER TABLE tiktoksongs2020
ALTER COLUMN instrumentalness FLOAT;


-----Instrumentalness Chart-----
CREATE VIEW instrumentalness AS
WITH tbl_instrumentalness AS(SELECT
CASE WHEN instrumentalness BETWEEN 0 AND 0.1 THEN 'low instrumentalness'
WHEN instrumentalness BETWEEN 0.1 AND 0.5 THEN 'moderate instrumentalness'
ELSE 'high instrumentalness'
END [instrumentalness],track_pop, artist_pop
FROM tiktoksongs2020)
SELECT DISTINCT SUM(track_pop)
OVER (PARTITION BY instrumentalness) [Track Population], 
SUM(artist_pop)
OVER (PARTITION BY instrumentalness) [Artist Population], 
instrumentalness
FROM tbl_instrumentalness;

-----Change Valence Value-----
CREATE VIEW valence AS
WITH tbl_valence AS (SELECT
CASE WHEN valence BETWEEN 0 AND 0.1 THEN 'low valence'
WHEN valence BETWEEN 0.1 AND 0.5 THEN 'moderate valence'
ELSE 'high valence' END [valence],track_pop,artist_pop
FROM tiktoksongs2020
)
SELECT DISTINCT SUM(track_pop)
OVER (PARTITION BY valence) [Track Population], 
SUM(artist_pop)
OVER (PARTITION BY valence) [Artist Population], 
valence
FROM tbl_valence;

------Time Signature Chart------
CREATE VIEW time_signature AS
SELECT DISTINCT SUM(track_pop)
OVER (PARTITION BY time_signature) [Track Population], 
SUM(artist_pop)
OVER (PARTITION BY time_signature) [Artist Population], 
CASE WHEN time_signature = 1 THEN 'Simple Time'
WHEN time_signature = 2 THEN 'Duple Time'
WHEN time_signature = 3 THEN 'Triple Time'
WHEN time_signature = 4 THEN 'Quadruple Time'
ELSE 'Quintuple Time' END [Time Signature]
FROM tiktoksongs2020;



------Duration Chart------
CREATE VIEW duration AS
WITH duration_tbl(duration,track_pop,artist_pop) AS (SELECT  
CASE WHEN duration_ms BETWEEN 0.5 AND 1 THEN '-1'
WHEN duration_ms BETWEEN 1 AND 2 THEN '+1'
WHEN duration_ms BETWEEN 2 AND 3 THEN '+2'
WHEN duration_ms BETWEEN 3 AND 4 THEN '+3'
WHEN duration_ms BETWEEN 4 AND 5 THEN '+4'
WHEN duration_ms BETWEEN 5 AND 6 THEN '+5'
WHEN duration_ms BETWEEN 6 AND 7 THEN '+6'
ELSE '+8' END [Duration], track_pop, artist_pop
FROM tiktoksongs2020)
SELECT DISTINCT SUM(duration_tbl.track_pop) 
OVER (PARTITION BY duration_tbl.duration) [Track Population],
SUM(duration_tbl.artist_pop) 
OVER (PARTITION BY duration_tbl.duration) [Artist Population], 
duration_tbl.duration 
FROM duration_tbl;

/*
Adagio: 66-76 BPM
Andante: 76-108 BPM
Moderato: 108-120 BPM
Allegro: 120-168 BPM
Vivace: 168-176 BPM
Presto: 168-200 BPM
Prestissimo: Over 200 BPM
*/
-------Tempo Chart------
CREATE VIEW tempo AS
WITH tempo_tbl(tempo,track_pop,artist_pop) AS (SELECT  
CASE WHEN tempo BETWEEN 76 AND 108 THEN 'Andate'
WHEN tempo BETWEEN 108 AND 120 THEN 'Moderato'
WHEN tempo BETWEEN 120 AND 168 THEN 'Allegro'
WHEN tempo BETWEEN 168 AND 176 THEN 'Vivace'
WHEN tempo BETWEEN 176 AND 200 THEN 'Presto'
ELSE 'Prestissimo' END [tempo], track_pop, artist_pop
FROM tiktoksongs2020)
SELECT DISTINCT SUM(tempo_tbl.track_pop) 
OVER (PARTITION BY tempo_tbl.tempo) [Track Population],
SUM(tempo_tbl.artist_pop) 
OVER (PARTITION BY tempo_tbl.tempo) [Artist Population], 
tempo_tbl.tempo
FROM tempo_tbl;

