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
(1, N'Pain of Salvation'),
(2, N'Dream Theater'),
(3, N'Transatlantic'),
(4, N'Metallica'),
(5, N'Megadeth'),
(6, N'AC/DC')
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
(11, N'Robert Trujillo')
SET IDENTITY_INSERT dbo.[Members] OFF;


SET IDENTITY_INSERT dbo.[Albums] ON;
INSERT INTO dbo.[Albums] ([Id], [Title], [BandId], [Year])
VALUES
(1, N'Panther', 1, 2020),
(2, N'In the Passing Light of Day', 1, 2017),
(3, N'One Hour by the Concrete Lake', 1, 1998),
(4, N'Images and Words', 2, 1992),
(5, N'Awake', 2, 1994),
(6, N'Kill ''em All', 4, 1983),
(7, N'Ride the Lightning', 4, 1984),
(8, N'Master of Puppets', 4, 1986)
SET IDENTITY_INSERT dbo.[Albums] OFF;



INSERT INTO dbo.[BandMembers] ([BandId], [MemberId], [StartYear], [EndYear])
VALUES
( 1,  1, 1984, NULL),
( 1,  2, 2013, 2017),
( 6,  3, NULL, NULL),
( 6,  4, NULL, NULL),
( 6,  5, NULL, NULL),
( 2,  6, 1985, 2011),
( 3,  6, 1999, 2002),
( 4,  7, 1981, NULL),
( 4,  8, 1981, 1983),
( 4,  9, 1982, 1986),
( 4, 10, 1986, 2001),
( 4, 11, 2003, NULL),
( 5,  8, 1983, 2002)


GO



SELECT b.[Name] [Band], a.[Title] [Album], a.[Year]
FROM dbo.[Bands] b
LEFT JOIN dbo.[Albums] a ON a.BandId = b.Id


SELECT b.[Name] [Band], m.[Name], bm.[StartYear], bm.[EndYear]
FROM dbo.[Bands] b
LEFT JOIN dbo.[BandMembers] bm ON bm.[BandId] = b.[Id]
LEFT JOIN dbo.[Members] m ON bm.[MemberId] = m.[Id]

