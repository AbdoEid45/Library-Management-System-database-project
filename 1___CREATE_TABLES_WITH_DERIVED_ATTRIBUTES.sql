-- Check if the database exists and drop it if it does (for testing purposes, remove in production)
IF DB_ID('LibraryManagement') IS NOT NULL
BEGIN
    ALTER DATABASE LibraryManagement SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE LibraryManagement;
END
GO

-- Create the database
CREATE DATABASE LibraryManagement;
GO

-- Use the database
USE LibraryManagement;
GO

-- Create independent tables first (no foreign key dependencies)
CREATE TABLE Author (
    ID INT PRIMARY KEY IDENTITY(1,1),
    name VARCHAR(100) NOT NULL,
    bio TEXT,
    nationality VARCHAR(50)
);
GO

CREATE TABLE Genre (
    Genre_ID INT PRIMARY KEY IDENTITY(1,1),
    GenreName VARCHAR(100) NOT NULL
);
GO

CREATE TABLE Publisher (
    PublisherID INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(100) NOT NULL,
    Address VARCHAR(200),
    Phone VARCHAR(20)
);
GO

-- Create Member table with computed column for ExpiryDate
CREATE TABLE Member (
    MemberID INT PRIMARY KEY IDENTITY(1,1),
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    Phone VARCHAR(20),
    Address VARCHAR(200),
    JoinDate DATE NOT NULL,
    SSN VARCHAR(20) UNIQUE,
    MembershipType VARCHAR(50) CHECK (MembershipType IN ('Student', 'Premium', 'Adult')),
    isActive BIT DEFAULT 1,
    ExpiryDate AS (DATEADD(YEAR, 1, JoinDate)) PERSISTED
);
GO

CREATE TABLE Staff (
    StaffID INT PRIMARY KEY IDENTITY(1,1),
    MemberID INT,
    Position VARCHAR(100),
    HireDate DATE,
    SalaryGrade VARCHAR(50),
    isManager BIT DEFAULT 0,
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID)
);
GO

-- Create tables with foreign key dependencies
CREATE TABLE Book (
    ISBN VARCHAR(13) PRIMARY KEY,
    Title VARCHAR(200) NOT NULL,
    Language VARCHAR(50),
    Genre_ID INT,
    PageCount INT,
    PublicationYear INT,
    isReferenceOnly BIT DEFAULT 0,
    PublisherID INT,
    FOREIGN KEY (Genre_ID) REFERENCES Genre(Genre_ID),
    FOREIGN KEY (PublisherID) REFERENCES Publisher(PublisherID)
);
GO

CREATE TABLE BookCopy (
    CopyID INT PRIMARY KEY IDENTITY(1,1),
    ISBN VARCHAR(13) NOT NULL,
    ArrivalDate DATE,
    Price DECIMAL(10, 2),
    Condition VARCHAR(50) CHECK (Condition IN ('Good', 'Worn', 'InRepair')),
    ShelfLocation VARCHAR(100),
    LastAuditDate DATE,
    Status VARCHAR(50) CHECK (Status IN ('Available', 'OnLoan', 'Lost')),
    FOREIGN KEY (ISBN) REFERENCES Book(ISBN)
);
GO

-- Create Reservation table with computed column for ExpiryDate
CREATE TABLE Reservation (
    ReservationID INT PRIMARY KEY IDENTITY(1,1),
    MemberID INT NOT NULL,
    ISBN VARCHAR(13) NOT NULL,
    RequestDate DATE NOT NULL,
    Status VARCHAR(50),
    ExpiryDate AS (DATEADD(DAY, 20, RequestDate)) PERSISTED,
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID),
    FOREIGN KEY (ISBN) REFERENCES Book(ISBN)
);
GO

-- Create Loan table with DueDate and FineAmount
CREATE TABLE Loan (
    LoanID INT PRIMARY KEY IDENTITY(1,1),
    CopyID INT NOT NULL,
    MemberID INT NOT NULL,
    StaffID INT,
    CheckoutTime DATETIME,
    DueDate DATE NULL,
    ReturnDate DATE,
    RenewalCount INT DEFAULT 0,
    LoanType VARCHAR(50) CHECK (LoanType IN ('InterLibrary', 'ShortLoan', 'Standard')),
    FineAmount DECIMAL(10, 2) NULL,
    FOREIGN KEY (CopyID) REFERENCES BookCopy(CopyID),
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID),
    FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)
);
GO

CREATE TABLE Event (
    EventID INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(100) NOT NULL,
    Type VARCHAR(50),
    StartTime DATETIME,
    EndTime DATETIME,
    MaxAttendance INT,
    HostedBy INT,
    FOREIGN KEY (HostedBy) REFERENCES Staff(StaffID)
);
GO

CREATE TABLE FinePayment (
    FinePaymentID INT PRIMARY KEY IDENTITY(1,1),
    MemberID INT NOT NULL,
    LoanID INT,
    StaffID INT,
    Amount DECIMAL(10, 2) NOT NULL,
    PaymentDate DATE,
    Method VARCHAR(50) CHECK (Method IN ('cash', 'visa')),
    ReceiptNumber VARCHAR(50) UNIQUE,
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID),
    FOREIGN KEY (LoanID) REFERENCES Loan(LoanID),
    FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)
);
GO

CREATE TABLE BookAuthor (
    BookISBN VARCHAR(13) NOT NULL,
    AuthorID INT NOT NULL,
    Role VARCHAR(100),
    PRIMARY KEY (BookISBN, AuthorID),
    FOREIGN KEY (BookISBN) REFERENCES Book(ISBN),
    FOREIGN KEY (AuthorID) REFERENCES Author(ID)
);
GO

-------------------------------------------------------
ALTER TABLE Loan DROP COLUMN FineAmount;

ALTER TABLE Loan
ADD FineAmount AS (
    CASE
        WHEN ReturnDate IS NULL THEN 0
        WHEN DATEDIFF(DAY, DueDate, ReturnDate) > 0 THEN
            CASE 
                WHEN DATEDIFF(DAY, DueDate, ReturnDate) * 10 > 200 THEN 200
                ELSE DATEDIFF(DAY, DueDate, ReturnDate) * 10
            END
        ELSE 0
    END
);

-------------------------------------------------------
-- Verify table creation
PRINT 'Database and tables created successfully with derived attributes.';
GO