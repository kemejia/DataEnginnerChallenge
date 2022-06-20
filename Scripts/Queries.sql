-- From the two most commonly appearing regions, which is the latest datasource?
;WITH Last_CTE(Region,MaxDateTrip)
AS (
SELECT T.Region, MAX(DateTimeTrip) AS MaxDateTrip
FROM Trips AS T
INNER JOIN (SELECT TOP 2 Region, COUNT(1) AS Appeared
			FROM Trips
			GROUP BY Region
			ORDER BY 2 DESC) AS TblCommonly ON  T.Region = TblCommonly.Region
GROUP BY T.Region
)

SELECT T.Region, DateTimeTrip, DataSource
FROM Last_CTE AS C
INNER JOIN Trips T ON C.Region = T.Region AND C.MaxDateTrip = T.DateTimeTrip

--What regions has the "cheap_mobile" datasource appeared in?
SELECT DISTINCT Region
FROM Trips WITH (NOLOCK)
WHERE DataSource='cheap_mobile'

--Develop a way to obtain the weekly average number of trips for an area, defined by a bounding box (given by coordinates) or by a region.
SELECT  Region,SUM(TotalTrips)/COUNT(Weeks) AS RegionWeeklyAvg
FROM  (SELECT Region,DATEPART(WEEK,T.DateTimeTrip) AS Weeks, SUM(CountTrips) AS TotalTrips
	FROM Trips AS T WITH (NOLOCK)
	GROUP BY Region,DATEPART(WEEK,T.DateTimeTrip) ) AS Tbl
GROUP BY Region
























