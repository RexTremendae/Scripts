IF OBJECT_ID('dbo.BandMembers', 'U') IS NOT NULL 
  DROP TABLE dbo.[BandMembers];
IF OBJECT_ID('dbo.Albums', 'U') IS NOT NULL 
  DROP TABLE dbo.[Albums];
IF OBJECT_ID('dbo.Members', 'U') IS NOT NULL 
  DROP TABLE dbo.[Members];
IF OBJECT_ID('dbo.Bands', 'U') IS NOT NULL 
  DROP TABLE dbo.[Bands];
GO


CREATE TABLE dbo.[Members] (
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [text] NULL,
 CONSTRAINT [PK_Members] PRIMARY KEY CLUSTERED ([Id] ASC)
)
GO


CREATE TABLE dbo.[Bands] (
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [text] NULL,
 CONSTRAINT [PK_Bands] PRIMARY KEY CLUSTERED ([Id] ASC)
)
GO


CREATE TABLE dbo.[BandMembers] (
	[MemberId] [int] NOT NULL,
	[BandId] [int] NOT NULL,
	[StartYear] [int] NULL,
	[EndYear] [int] NULL
)
GO


ALTER TABLE dbo.[BandMembers] WITH CHECK ADD CONSTRAINT [FK_BandMembers_Members] FOREIGN KEY([MemberId])
REFERENCES dbo.[Members] ([Id])
GO

ALTER TABLE dbo.[BandMembers] WITH CHECK ADD CONSTRAINT [FK_BandMembers_Bands] FOREIGN KEY([BandId])
REFERENCES dbo.[Bands] ([Id])
GO



CREATE TABLE dbo.[Albums](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[BandId] [int] NOT NULL,
	[Title] [text] NOT NULL,
	[Year] [int] NULL,
 CONSTRAINT [PK_Albums] PRIMARY KEY CLUSTERED ([Id] ASC)
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE dbo.[Albums] WITH CHECK ADD CONSTRAINT [FK_Albums_Bands] FOREIGN KEY([BandId])
REFERENCES dbo.[Bands] ([Id])
GO


SET IDENTITY_INSERT dbo.[Bands] ON;
INSERT INTO dbo.[Bands] ([Id], [Name])
VALUES
( 1, N'Pain of Salvation'),
( 2, N'Dream Theater'),
( 3, N'Transatlantic'),
( 4, N'Metallica'),
( 5, N'Megadeth'),
( 6, N'AC/DC'),
( 7, N'the Beatles'),
( 8, N'Judas Priest'),
( 9, N'Queen'),
(10, N'Black Sabbath')
SET IDENTITY_INSERT dbo.[Bands] OFF;


SET IDENTITY_INSERT dbo.[Members] ON;
INSERT INTO dbo.[Members] ([Id], [Name])
VALUES
( 1, N'Daniel Gildenlöw'),
( 2, N'Ragnar Zolberg'),
( 3, N'Angus Young'),
( 4, N'Malcolm Young'),
( 5, N'Brian Johnsson'),
( 6, N'Mike Portnoy'),
( 7, N'James Hetfield'),
( 8, N'Dave Mustain'),
( 9, N'Cliff Burton'),
(10, N'Jason Newsted'),
(11, N'Robert Trujillo'),
(12, N'Bon Scott'),
(13, N'John Lennon'),
(14, N'Paul McCartney'),
(15, N'Ringo Starr'),
(16, N'George Harrison'),
(17, N'Rob Halford'),
(18, N'Glenn Tipton'),
(19, N'K.K. Downing'),
(20, N'Freddie Mercury'),
(21, N'Brian May'),
(22, N'John Deacon'),
(23, N'Roger Taylor'),
(24, N'Ozzy Osbourne'),
(25, N'Tony Iommi'),
(26, N'Ronnie James Dio'),
(27, N'Geezer Butler')
SET IDENTITY_INSERT dbo.[Members] OFF;


SET IDENTITY_INSERT dbo.[Albums] ON;
INSERT INTO dbo.[Albums] ([Id], [Title], [BandId], [Year])
VALUES
( 1, N'Panther', 1, 2020),
( 2, N'In the Passing Light of Day', 1, 2017),
( 3, N'One Hour by the Concrete Lake', 1, 1998),
( 4, N'Images and Words', 2, 1992),
( 5, N'Awake', 2, 1994),
( 6, N'Kill ''em All', 4, 1983),
( 7, N'Ride the Lightning', 4, 1984),
( 8, N'Master of Puppets', 4, 1986),
( 9, N'Bridge Across Forever', 3, 2001),
(10, N'Kaleidoscope', 3, 2014),
(11, N'Rust in Peace', 5, 1990),
(12, N'Youthanasia', 5, 1994),
(13, N'Higway to Hell', 6, 1979),
(14, N'Back in Black', 6, 1980),
(15, N'Revolver', 7, 1966),
(16, N'Sgt. Pepper''s Lonely Hearts Club Band', 7, 1967),
(17, N'Abbey Road', 7, 1969),
(18, N'Painkiller', 8, 1990),
(19, N'British Steel', 8, 1980),
(20, N'Sad Wings of Destiny', 8, 1980),
(21, N'Jazz', 9, 1978),
(22, N'Innuendo', 9, 1991),
(23, N'Made in Heaven', 9, 1995),
(24, N'Black Sabbath', 10, 1970),
(25, N'Sabbath Bloody Sabbath', 10, 1973),
(26, N'Heaven and Hell', 10, 1980)
SET IDENTITY_INSERT dbo.[Albums] OFF;



INSERT INTO dbo.[BandMembers] ([BandId], [MemberId], [StartYear], [EndYear])
VALUES
( 1,  1, 1984, NULL),
( 1,  2, 2013, 2017),
( 6,  3, 1973, NULL),
( 6,  4, 1973, 2010),
( 6,  5, 1980, NULL),
( 2,  6, 1985, 2011),
( 3,  6, 1999, 2002),
( 4,  7, 1981, NULL),
( 4,  8, 1981, 1983),
( 4,  9, 1982, 1986),
( 4, 10, 1986, 2001),
( 4, 11, 2003, NULL),
( 5,  8, 1983, 2002),
( 5,  8, 2004, NULL),
( 6, 12, 1974, 1980),
( 7, 13, 1960, 1969),
( 7, 14, 1960, 1970),
( 7, 15, 1960, 1970),
( 7, 16, 1960, 1970),
( 8, 17, 1973, 1992),
( 8, 17, 2003, NULL),
( 8, 18, 1974, NULL),
( 8, 19, 1970, 2011),
( 9, 20, 1970, 1991),
( 9, 21, 1970, NULL),
( 9, 22, 1971, 1997),
( 9, 23, 1970, NULL),
(10, 24, 1968, 1977),
(10, 24, 1978, 1979),
(10, 24, 1985, 1985),
(10, 24, 1992, 1992),
(10, 24, 1997, 2006),
(10, 24, 2011, 2017),
(10, 25, 1968, 2017),
(10, 26, 1979, 1982),
(10, 26, 1991, 1992),
(10, 26, 2006, 2010),
(10, 27, 1968, 1979),
(10, 27, 1979, 1985),
(10, 27, 1987, 1987),
(10, 27, 1990, 1994),
(10, 27, 1997, 2017)
GO



SELECT b.[Name] [Band], a.[Title] [Album], a.[Year]
FROM dbo.[Bands] b
LEFT JOIN dbo.[Albums] a ON a.BandId = b.Id


SELECT b.[Name] [Band], m.[Name], bm.[StartYear], bm.[EndYear]
FROM dbo.[Bands] b
LEFT JOIN dbo.[BandMembers] bm ON bm.[BandId] = b.[Id]
LEFT JOIN dbo.[Members] m ON bm.[MemberId] = m.[Id]

