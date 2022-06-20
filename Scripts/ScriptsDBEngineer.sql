USE [master]
GO

/****** Object:  Database [DBEngineer]    Script Date: 6/20/2022 3:21:04 PM ******/
CREATE DATABASE [DBEngineer]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'DBEngineer', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\DBEngineer.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'DBEngineer_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\DBEngineer_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [DBEngineer].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

ALTER DATABASE [DBEngineer] SET ANSI_NULL_DEFAULT OFF 
GO

ALTER DATABASE [DBEngineer] SET ANSI_NULLS OFF 
GO

ALTER DATABASE [DBEngineer] SET ANSI_PADDING OFF 
GO

ALTER DATABASE [DBEngineer] SET ANSI_WARNINGS OFF 
GO

ALTER DATABASE [DBEngineer] SET ARITHABORT OFF 
GO

ALTER DATABASE [DBEngineer] SET AUTO_CLOSE OFF 
GO

ALTER DATABASE [DBEngineer] SET AUTO_SHRINK OFF 
GO

ALTER DATABASE [DBEngineer] SET AUTO_UPDATE_STATISTICS ON 
GO

ALTER DATABASE [DBEngineer] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO

ALTER DATABASE [DBEngineer] SET CURSOR_DEFAULT  GLOBAL 
GO

ALTER DATABASE [DBEngineer] SET CONCAT_NULL_YIELDS_NULL OFF 
GO

ALTER DATABASE [DBEngineer] SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [DBEngineer] SET QUOTED_IDENTIFIER OFF 
GO

ALTER DATABASE [DBEngineer] SET RECURSIVE_TRIGGERS OFF 
GO

ALTER DATABASE [DBEngineer] SET  DISABLE_BROKER 
GO

ALTER DATABASE [DBEngineer] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO

ALTER DATABASE [DBEngineer] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO

ALTER DATABASE [DBEngineer] SET TRUSTWORTHY OFF 
GO

ALTER DATABASE [DBEngineer] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO

ALTER DATABASE [DBEngineer] SET PARAMETERIZATION SIMPLE 
GO

ALTER DATABASE [DBEngineer] SET READ_COMMITTED_SNAPSHOT OFF 
GO

ALTER DATABASE [DBEngineer] SET HONOR_BROKER_PRIORITY OFF 
GO

ALTER DATABASE [DBEngineer] SET RECOVERY SIMPLE 
GO

ALTER DATABASE [DBEngineer] SET  MULTI_USER 
GO

ALTER DATABASE [DBEngineer] SET PAGE_VERIFY CHECKSUM  
GO

ALTER DATABASE [DBEngineer] SET DB_CHAINING OFF 
GO

ALTER DATABASE [DBEngineer] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO

ALTER DATABASE [DBEngineer] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO

ALTER DATABASE [DBEngineer] SET DELAYED_DURABILITY = DISABLED 
GO

ALTER DATABASE [DBEngineer] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO

ALTER DATABASE [DBEngineer] SET QUERY_STORE = OFF
GO

ALTER DATABASE [DBEngineer] SET  READ_WRITE 
GO

USE [DBEngineer]
GO

/****** Object:  Table [dbo].[TripsStaging]    Script Date: 6/20/2022 3:23:25 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TripsStaging]') AND type in (N'U'))
DROP TABLE [dbo].[TripsStaging]
GO

/****** Object:  Table [dbo].[TripsStaging]    Script Date: 6/20/2022 3:23:25 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TripsStaging](
	[Region] [nchar](10) NULL,
	[OriginCoord] [nchar](50) NULL,
	[DestinationCoord] [nchar](50) NULL,
	[DateTimeTrip] [datetime] NULL,
	[DataSource] [nchar](30) NULL
) ON [PRIMARY]
GO;


/****** Object:  Table [dbo].[Trips]    Script Date: 6/20/2022 3:22:22 PM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Trips]') AND type in (N'U'))
DROP TABLE [dbo].[Trips]
GO

/****** Object:  Table [dbo].[Trips]    Script Date: 6/20/2022 3:22:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Trips](
	[SkTrip] [int] IDENTITY(1,1) NOT NULL,
	[Region] [nchar](10) NOT NULL,
	[OriginCoord] [nchar](50) NOT NULL,
	[DestinationCoord] [nchar](50) NOT NULL,
	[DateTimeTrip] [datetime] NOT NULL,
	[DataSource] [nchar](30) NOT NULL,
	[CountTrips] [int] NOT NULL
) ON [PRIMARY]
GO;


/****** Object:  StoredProcedure [dbo].[usp_RegionWeeklyAvg]    Script Date: 6/20/2022 3:25:34 PM ******/
DROP PROCEDURE [dbo].[usp_RegionWeeklyAvg]
GO

/****** Object:  StoredProcedure [dbo].[usp_RegionWeeklyAvg]    Script Date: 6/20/2022 3:25:34 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Carlos Mejia
-- Create date: 2022-06-20
-- Description:	Proceure to obtain the weekly average number of trips for Region
-- =============================================
CREATE PROCEDURE [dbo].[usp_RegionWeeklyAvg]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT  Region,SUM(TotalTrips)/COUNT(Weeks) AS RegionWeeklyAvg
	FROM  (SELECT Region,DATEPART(WEEK,T.DateTimeTrip) AS Weeks, SUM(CountTrips) AS TotalTrips
		FROM Trips AS T WITH (NOLOCK)
		GROUP BY Region,DATEPART(WEEK,T.DateTimeTrip) ) AS Tbl
	GROUP BY Region


END
GO;

/****** Object:  StoredProcedure [dbo].[usp_loadTrip]    Script Date: 6/20/2022 3:24:24 PM ******/
DROP PROCEDURE [dbo].[usp_loadTrip]
GO

/****** Object:  StoredProcedure [dbo].[usp_loadTrip]    Script Date: 6/20/2022 3:24:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Carlos Mejia
-- Create date: 2022-06-20
-- Description:	Load data from TripsStaging to Trip table
-- =============================================
CREATE PROCEDURE [dbo].[usp_loadTrip]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Search if exists Trips with similar origin, destination, and time to be agrouped
	SELECT TF.SkTrip,TF.OriginCoord,TF.DestinationCoord,TF.DateTimeTrip
	INTO #ExistTrip 
	FROM dbo.TripsStaging AS TS
		INNER JOIN dbo.Trips AS TF ON TS.OriginCoord = TF.OriginCoord
								AND TS.DestinationCoord = TF.DestinationCoord
								AND TS.DateTimeTrip = TF.DateTimeTrip


	-- Group together similar Trips
	UPDATE T
	SET CountTrips = CountTrips+1
	FROM  dbo.Trips AS T
		INNER JOIN #ExistTrip AS ET ON T.SkTrip = ET.SkTrip

	-- Delete group Trips from staging table
	--SELECT *
	DELETE TS
	FROM dbo.TripsStaging AS TS
		INNER JOIN #ExistTrip AS ET ON TS.OriginCoord = ET.OriginCoord
								AND TS.DestinationCoord = ET.DestinationCoord
								AND TS.DateTimeTrip = ET.DateTimeTrip


    -- Insert to final table
	INSERT INTO dbo.Trips(Region
			,OriginCoord
			,DestinationCoord
			,DateTimeTrip
			,DataSource
			,CountTrips)
	SELECT COALESCE(Region,'NoRegion') 
			,COALESCE(OriginCoord,'NoOrigin')
			,COALESCE(DestinationCoord,'NoDestination')
			,COALESCE(DateTimeTrip,1900-01-01)
			,COALESCE(DataSource,'NoDataSource')
			,1
	FROM dbo.TripsStaging

END
GO






