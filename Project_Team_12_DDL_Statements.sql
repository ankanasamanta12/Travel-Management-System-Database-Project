/* Query to Create Database */

GO
CREATE DATABASE Project_Team_12_AroundTheWorld;
GO

/* Query to use the created Database */

USE Project_Team_12_AroundTheWorld;

/* Query to Create a Function */

CREATE FUNCTION CheckGender(@CustomerGender VARCHAR(10))
RETURNS SMALLINT
AS
BEGIN
DECLARE @Count SMALLINT=0
SELECT @Count=COUNT(CustGender)
FROM Customer
WHERE CustGender=@CustomerGender
AND CustGender NOT IN('Male','Female','Other')
RETURN @Count;
END;

/* Query to Create a Customer Entity */

CREATE TABLE Customer
(
CustID INT NOT NULL PRIMARY KEY IDENTITY(1, 1),
CustFirstName VARCHAR(50) NOT NULL,
CustLastName VARCHAR(50) NOT NULL,
CustBirthDate DATE NOT NULL,
CustPhoneNo VARCHAR(50) NOT NULL,
CustStreetName VARCHAR(50) NOT NULL,
CustZipCode VARCHAR(10) NOT NULL,
CustEmail VARCHAR(50) NOT NULL,
CustPassword VARBINARY(250) NOT NULL,
CustGender VARCHAR(10) NOT NULL CONSTRAINT GenderCheck CHECK(dbo.CheckGender(CustGender)=0)
);

--Query to create the computed column for CustAge

ALTER TABLE Customer
ADD CustAge AS DATEDIFF(hour,CustBirthDate,GETDATE())/8766;

/* Query to Create a Function */

CREATE FUNCTION CheckDesignation(@EmployeeDesignation VARCHAR(10))
RETURNS SMALLINT
AS
BEGIN
DECLARE @Count SMALLINT=0
SELECT @Count=COUNT(EmpDesignation)
FROM Employee
WHERE EmpDesignation=@EmployeeDesignation
AND EmpDesignation NOT IN('Sales Executive', 'Associate Executive', 'Travel Manager', 'Senior Sales Executive')
RETURN @Count;
END;

CREATE FUNCTION EmpSalaryCheck(@EmployeeSalary MONEY)
RETURNS SMALLINT
AS
BEGIN
DECLARE @Count SMALLINT=0
SELECT @Count=COUNT(EmpSalary)
FROM Employee
WHERE EmpSalary=@EmployeeSalary
AND EmpSalary < 40000
RETURN @Count;
END;

/* Query to Create Employee Entity */

CREATE TABLE Employee
(
EmployeeID INT NOT NULL PRIMARY KEY IDENTITY(1, 1),
EmpFirstName VARCHAR(50) NOT NULL,
EmpLastName VARCHAR(50) NOT NULL,
EmpPhoneNumber VARCHAR(50) NOT NULL,
EmpEmailAddress VARCHAR(50) NOT NULL,
EmpUsername VARCHAR(50) NOT NULL,
EmpPassword VARBINARY(250) NOT NULL,
EmpDesignation VARCHAR(50) NOT NULL CONSTRAINT EmployeeDesignationCheck CHECK(dbo.CheckDesignation(EmpDesignation)=0),
EmpSalary MONEY NOT NULL CONSTRAINT EmployeeSalaryCheck CHECK(dbo.EmpSalaryCheck(EmpSalary)=0),
EmpAvgRating FLOAT
);

/* Query to Create CustomerPreference Entity */

CREATE TABLE CustomerPreference
(
CustPrefID INT NOT NULL PRIMARY KEY IDENTITY(1, 1),
CustID INT NOT NULL FOREIGN KEY REFERENCES Customer(CustID),
CustBudget MONEY NOT NULL,
PrefPackageType VARCHAR(50) NOT NULL
);

/* Query to Create Country Entity */

CREATE TABLE Country
(
CountryID INT PRIMARY KEY IDENTITY(1, 1),
CountryName VARCHAR(50) NOT NULL
);

/* Query to Create City Entity */

CREATE TABLE City
(
CityID INT NOT NULL PRIMARY KEY IDENTITY(1, 1),
CountryID INT NOT NULL FOREIGN KEY REFERENCES Country(CountryID),
CityName VARCHAR(50) NOT NULL
);

/* Query to Create Visa Entity */

CREATE TABLE Visa
(
VisaID INT NOT NULL PRIMARY KEY IDENTITY(1, 1),
CountryID INT NOT NULL FOREIGN KEY REFERENCES Country(CountryID),
IsVisaRequired BIT NOT NULL,
VisaCost MONEY
);

/* Query to Create a Function */

CREATE FUNCTION VisaStatusCheck(@VisaResult VARCHAR(45))
RETURNS SMALLINT
AS
BEGIN
DECLARE @Count SMALLINT=0
SELECT @Count=COUNT(VisaOutcome)
FROM VisaStatus
WHERE VisaOutcome=@VisaResult
AND VisaOutcome NOT IN('Accepted','Rejected')
RETURN @Count;
END;

/* Query to Create VisaStatus Entity */

CREATE TABLE VisaStatus
(
VisaStatusID INT NOT NULL PRIMARY KEY IDENTITY(1, 1),
CustID INT NOT NULL FOREIGN KEY REFERENCES Customer(CustID),
VisaID INT NOT NULL FOREIGN KEY REFERENCES Visa(VisaID),
VisaOutcome VARCHAR(50) CONSTRAINT VisaResultCheck CHECK(dbo.VisaStatusCheck(VisaOutcome)=0),
RejectedReason VARCHAR(255),
VisaDate DATE NOT NULL DEFAULT GETDATE()
);

/* Query to Create Package Entity */

CREATE TABLE Package
(
PackageID INT NOT NULL PRIMARY KEY IDENTITY(1, 1),
PackageType VARCHAR(50) NOT NULL,
TotalPackagePrice MONEY,
TotalNumberOfDays INT NOT NULL,
);

/* Query to Create Accommodation Entity */

CREATE TABLE Accommodation
(
AccommodationID INT NOT NULL PRIMARY KEY IDENTITY(1, 1),
AccommodationType VARCHAR(50) NOT NULL,
AccommodationName VARCHAR(50) NOT NULL,
AccommodationPrice MONEY NOT NULL,
AccommodationRating INT,
AccommodationStreetName VARCHAR(50) NOT NULL,
AccommodationZipCode VARCHAR(10) NOT NULL
);

/* Query to Create Attraction Entity */

CREATE TABLE Attraction
(
AttractionID INT NOT NULL PRIMARY KEY IDENTITY(1, 1),
AttractionName VARCHAR(50) NOT NULL,
AttractionPrice MONEY NOT NULL
);

/* Query to Create Transport Entity */

CREATE TABLE Transport
(
TransportID INT NOT NULL PRIMARY KEY IDENTITY(1, 1),
ArrivalCityID INT NOT NULL FOREIGN KEY REFERENCES City(CityID),
DepartureCityID INT NOT NULL FOREIGN KEY REFERENCES City(CityID),
TravelMode VARCHAR(50) NOT NULL,
TransportPrice MONEY,
);

/* Query to Create Flight Entity */

CREATE TABLE Flight
(
TransportID INT FOREIGN KEY REFERENCES Transport(TransportID),
IsLatest BIT,
FlightPrice MONEY,
LastUpdated DATETIME
);

/* Query to Create PackageDetails Entity */

CREATE TABLE PackageDetails
(
PackageID INT NOT NULL FOREIGN KEY REFERENCES Package(PackageID),
AttractionID INT NOT NULL FOREIGN KEY REFERENCES Attraction(AttractionID),
AccommodationID INT NOT NULL FOREIGN KEY REFERENCES Accommodation(AccommodationID),
TransportID INT NOT NULL FOREIGN KEY REFERENCES Transport(TransportID),
CityID INT NOT NULL FOREIGN KEY REFERENCES City(CityID)
CONSTRAINT PKPackageDetails PRIMARY KEY CLUSTERED
(PackageID, AttractionID, AccommodationID, TransportID, CityID)
);

/* Query to Create CustPreferredCity Entity */

CREATE TABLE CustPreferredCity 
(
CustPrefID INT NOT NULL FOREIGN KEY REFERENCES CustomerPreference(CustPrefID),
CityID INT NOT NULL FOREIGN KEY REFERENCES City(CityID)
CONSTRAINT PKCustPreferredCity PRIMARY KEY CLUSTERED
(CustPrefID, CityID)
);

/* Query to Create Booking Entity */

CREATE TABLE Booking
(
BookingID INT NOT NULL PRIMARY KEY IDENTITY(1, 1),
PackageID INT NOT NULL FOREIGN KEY REFERENCES Package(PackageID),
EmployeeID INT NOT NULL FOREIGN KEY REFERENCES Employee(EmployeeID),
CustID INT NOT NULL FOREIGN KEY REFERENCES Customer(CustID),
IsLatest BIT NOT NULL,
BookingStatus VARCHAR(15),
TripStartDate DATE NOT NULL,
TripEndDate DATE NOT NULL
);

/* Query to create the computed column FinalBookingAmount
The final booking amount in the booking amount will not be computed for a customer unless a visaID is assigned to him, 
because the FinalBookingAmount = TotalPackagePrice + VisaCost */

CREATE FUNCTION fn_FinalBookingAmt(@BookingID INT)
RETURNS MONEY
AS
   BEGIN
      DECLARE @FinalBookingAmount MONEY =
         (SELECT SUM(p.TotalPackagePrice + v.VisaCost)
          FROM Booking b JOIN Package p ON b.PackageID = p.PackageID JOIN Customer c 
		  ON c.CustID = b.CustID JOIN VisaStatus vs ON vs.CustID = c.CustID JOIN Visa v ON v.VisaID = vs.VisaID
          WHERE BookingID =@BookingID);
      SET @FinalBookingAmount = ISNULL(@FinalBookingAmount, 0);
      RETURN @FinalBookingAmount;
END;

ALTER TABLE Booking
ADD FinalBookingAmount AS (dbo.fn_FinalBookingAmt(BookingID));

/* Query to Create Payment Entity */

CREATE TABLE Payment
(
PaymentID INT NOT NULL PRIMARY KEY IDENTITY(1, 1),
BookingID INT NOT NULL FOREIGN KEY REFERENCES Booking(BookingID),
Discount MONEY,
FinalAmount MONEY,
PaymentStatus BIT NOT NULL,
PaymentDate DATETIME NOT NULL
);

/* Query to Create CustomerFeedback Entity */

CREATE TABLE CustomerFeedback
(
BookingID INT NOT NULL FOREIGN KEY REFERENCES Booking(BookingID),
CustomerRating INT,
FeedbackDescription VARCHAR(255)
CONSTRAINT PKCustomerFeedback PRIMARY KEY CLUSTERED
(BookingID)
);

/* Creating a master key encryption */

CREATE MASTER KEY ENCRYPTION BY   
PASSWORD = 'info6210'; 

/* Creating a cartificate for encryption  */

CREATE CERTIFICATE PasswordEncryption  
WITH SUBJECT = 'Password Encryption';  

/* Creating a symmetric key using AES_256 using the created Password encryption certificate */  

CREATE SYMMETRIC KEY Password_Encryption_Key  
WITH ALGORITHM = AES_256  
ENCRYPTION BY CERTIFICATE PasswordEncryption;

-- Trigger to update the employee average rating

CREATE TRIGGER EmpAverageRating
ON CustomerFeedback
AFTER INSERT
AS
BEGIN
UPDATE Employee set EmpAvgRating = (SELECT temp.avgRating
FROM (SELECT AVG(CAST(CustomerRating as float)) as avgRating  FROM CustomerFeedback c
JOIN Booking b
ON c.BookingID = b.Bookingid
JOIN Employee e
ON b.EmployeeID = e.EmployeeID ) temp)
WHERE EmployeeID = (SELECT e.EmployeeID
FROM CustomerFeedback c
JOIN Booking b
on c.Bookingid = b.Bookingid
JOIN Employee e
ON b.Employeeid = e.Employeeid WHERE c.BookingID = (SELECT BookingID FROM Inserted))
END;

-- View to create a temporary Flight Details table from the Transport table

CREATE VIEW FlightTransportDetails AS 
SELECT  RANK() OVER (ORDER BY TransportID) as FlightID, TransportID
FROM            dbo.Transport
WHERE        (TravelMode = 'Flight')

-- Procedure to update the status of the latest flight prices

CREATE PROCEDURE FlightSP
 @InTransportID INT,
  @InPrice INT
AS
BEGIN
update Flight
set isLatest=0
where TransportID=@InTransportID and isLatest=1;
INSERT into Flight (TransportID,IsLatest,FlightPrice,LastUpdated) values (@InTransportID,1,@InPrice,SYSDATETIME());
END;

/* Procedure to calculate random flight prices
To update the fluctuating price, we need to click the "Refresh Flight Prices" button on the front-end.*/

Create PROCEDURE FlightWrappingSP
AS BEGIN
DECLARE @TransportID INT = 1;
DECLARE @InPrice INT;
DECLARE @CountTotalRows INT = (select count(FlightID) from FlightTransportDetails);
DECLARE @cnt INT = 0;
WHILE @cnt < @CountTotalRows
 BEGIN
 SELECT TOP 1 @TransportID = TransportID FROM FlightTransportDetails WHERE TransportID >= @TransportID ORDER BY TransportID;

 SET @InPrice=(select FLOOR(RAND()*(2500) + 100));
	 EXEC FlightSP @TransportID, @InPrice;
  SET @TransportID = @TransportID + 1;
  SET @cnt = @cnt + 1;
 END
END;

--Trigger to update the TransportPrice when FlightPrice is updated

CREATE TRIGGER FlightChanged
   ON dbo.Flight
   AFTER INSERT
AS   
IF UPDATE(FlightPrice)
    BEGIN
    UPDATE dbo.TRANSPORT
	SET TransportPrice=(Select i.FlightPrice from inserted as i)
	WHERE TravelMode='Flight' and TransportID IN (Select i.TransportID from inserted as i where isLatest=1);
    END

--Procedure to calculate the TotalPackagePrice

CREATE PROCEDURE PackagePriceAmount
@packageID INT
AS
	BEGIN
    SET @packageID = 1
    WHILE @packageID < 32
	BEGIN
	UPDATE Package
	SET TotalPackagePrice = (
	SELECT sum(at.price + ac.price + t.transportprice) from
	(select pd.PackageID, sum(at.Attractionprice ) price
	from PackageDetails PD JOIN Attraction at on PD.AttractionID=AT.AttractionID where PD.PackageID=@packageID group by pd.PackageID) at
	left join
	(select pd.PackageID,sum(ac.Accommodationprice ) price
	from PackageDetails PD join Accommodation ac on PD.AccommodationID=ac.AccommodationID
where PD.PackageID=@packageID group by pd.PackageID) ac on at.PackageID=ac.PackageID
	left join
	(select distinct pd.PackageID, sum(t.Transportprice ) transportprice
	from (select distinct packageID, transportID from PackageDetails) PD join Transport t on PD.TransportID=t.TransportID
where PD.PackageID=@packageID  group by pd.PackageID) t on at.PackageID=t.PackageID)
where PackageID = @packageID;
SET @packageID +=1;
END
END;

-- Trigger to update the TotalPackagePrice when the TransportPrice is updated

CREATE TRIGGER TransportPriceUpdatedON TransportAFTER UPDATEAS IF UPDATE (TransportPrice)BEGINDECLARE @PackageID INT;
EXEC PackagePriceAmount @packageID
END;

--Trigger to update the BookingStatus to 'In Progress' when the VisaOutcome is 'Accepted'

CREATE TRIGGER VisaStatusChanged    
ON dbo.VisaStatus    
AFTER UPDATE AS   
IF UPDATE(VisaOutcome)     
IF EXISTS(Select CustID from dbo.Booking)     
BEGIN     
UPDATE dbo.Booking     
SET BookingStatus='In Progress'     
WHERE BookingStatus='New' and CustID IN (Select i.CustID from inserted as i where (VisaOutcome)='Accepted') and IsLatest='1';     
END;

--Trigger to identify the latest booking for a customer

CREATE TRIGGER IsLatestBooking
ON Booking
AFTER INSERT
AS IF exists(Select CustID from Booking where CustID=(Select CustID from Inserted) and TripStartDate < (Select TripStartDate From Inserted ))
BEGIN
UPDATE Booking Set IsLatest =0 where CustID=(Select CustID from Inserted) 
and TripStartDate < (Select TripStartDate From Inserted );
END;

--Trigger to start a payment when the BookingStatus is 'In Progress'

CREATE TRIGGER PaymentInitiated
ON Booking
AFTER UPDATE
AS 
IF exists(select BookingStatus from Inserted where BookingStatus='In Progress' and TripStartDate=(Select MAX(TripStartDate) from Inserted)) 
BEGIN 
INSERT INTO Payment (BookingID,PaymentStatus,PaymentDate) VALUES ((select BookingID from inserted),0,GETDATE());
END;

--Trigger to calculate the dicsount in Payment table

CREATE TRIGGER DiscountApplied
ON Payment
AFTER INSERT
AS  
BEGIN UPDATE Payment 
SET Discount = ( SELECT CASE WHEN Booking.FinalBookingAmount Between 0 and 3000 then 300
						 WHEN Booking.FinalBookingAmount Between 3001 and 5000 then 500
						 WHEN Booking.FinalBookingAmount Between 5001 and 9000 then 700
						 else 1000
						 end
					 	from Booking where BookingID=(Select DISTINCT BookingID From Inserted))
						
WHERE PaymentID= (Select DISTINCT PaymentID FROM INSERTED)
END;

--Trigger to calculate the FinalAmount in the Payment table after applying the discount

CREATE TRIGGER PaymentAmount
ON Payment
AFTER UPDATE
AS if update(Discount)
BEGIN UPDATE Payment 
SET FinalAmount =( SELECT DISTINCT FinalBookingAmount - Discount from Booking B inner join Inserted P on B.BookingID=P.BookingID 
WHERE B.BookingID=(Select DISTINCT I.BookingID From Inserted I ) )
WHERE PaymentID= (Select DISTINCT PaymentID FROM INSERTED);
END;

--Trigger to update the BookingStatus to 'Completed' after Payment is successfulCREATE TRIGGER ChangeBookingStatusOncePaymentDone   ON dbo.Payment   AFTER UPDATEAS       	IF UPDATE(PaymentStatus)	BEGIN    UPDATE dbo.Booking 	SET BookingStatus='Completed'	WHERE BookingID IN (Select i.BookingID from inserted as i WHERE i.PaymentStatus=1) and isLatest=1;    END
/* View to check the Package details */

CREATE VIEW vwPackages
 AS
 select  distinct PD.PackageID, C.cityName,at.AttractionName,at.AttractionPrice  , ac.AccommodationName,ac.accommodationprice, p.TotalNumberOfDays
 from 
PackageDetails PD join Attraction at on PD.AttractionID=AT.AttractionID
join Accommodation ac on PD.AccommodationID=ac.AccommodationID
join City C on pd.cityID=C.cityID join Package p on p.PackageID = PD.PackageID;/* View to report details of customer with decrypted password*/

OPEN SYMMETRIC KEY Password_Encryption_Key  
DECRYPTION BY CERTIFICATE PasswordEncryption;

GO
CREATE VIEW decryptedCustPasswordDetails AS 
SELECT  
Cust.CustID,
Cust.CustFirstName,
Cust.CustEmail,
Convert(VarChar,DecryptByKey(Cust.CustPassword)) AS 'Decrypted Password' FROM customer AS Cust;

/* View for city wise rank of the accomodations as per their ratings*/

DROP VIEW BestRatedAccomodation
GO
CREATE VIEW BestRatedAccomodation AS 
WITH Temp AS
(SELECT        
RANK() OVER (PARTITION BY City.CityName ORDER BY Accommodation.AccommodationRating DESC) as [Rank],
City.CityName, Accommodation.AccommodationName, Accommodation.AccommodationRating
FROM            dbo.Accommodation AS Accommodation INNER JOIN
                         dbo.PackageDetails AS Package ON Accommodation.AccommodationID = Package.AccommodationID INNER JOIN
                         dbo.City AS City ON Package.CityID = City.CityID)						 
SELECT DISTINCT Temp.CityName AS City, Temp.AccommodationName AS 'Best Accommodation', Temp.AccommodationRating AS 'Accommodation Rating'
FROM Temp
WHERE [Rank]=1;;

/* View to show best performing employees*/
GO
CREATE VIEW BestPerformingEmployee AS 
SELECT Top 1 with Ties EmployeeID,EmpFirstName AS 'Employee Name',EmpDesignation AS Designation,EmpAvgRating AS Rating
FROM            dbo.Employee
ORDER BY EmpAvgRating DESC

/* View to show highest salaried employees*/

GO
CREATE VIEW HighSalariedRanking AS 
WITH Temp AS
(SELECT   DENSE_RANK() OVER (PARTITION BY EmpDesignation ORDER BY EmpSalary Desc) as [Rank],
EmployeeID,EmpFirstName,EmpDesignation,EmpSalary
FROM            dbo.Employee)
SELECT Temp.EmployeeID,Temp.EmpFirstName AS 'Employee Name',Temp.EmpDesignation AS Designation,Temp.EmpSalary AS Salary
FROM
Temp
WHERE [Rank]=1;

-- View to check the latest flight prices

CREATE VIEW LatestFlightPrices AS
select a.CityName as ArrivalCity, d.CityName as DepartureCity, a.TransportPrice 
from (SELECT CityName, t.TransportID, t.TransportPrice from City c join 
Transport t on t.ArrivalCityID = c.CityID where TravelMode = 'Flight') a join 
(SELECT CityName, t.TransportID from City c join 
Transport t on t.DepartureCityID = c.CityID where TravelMode = 'Flight') d on a.TransportID = d.TransportID

