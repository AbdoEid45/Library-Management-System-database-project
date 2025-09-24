
-- =============================================================================
-- Table Creation: ReorderRequest
-- =============================================================================
-- Purpose: Stores requests to reorder lost or damaged books
-- Functionality: Defines ReorderRequest table with ReorderID, ISBN, CopyID, MemberID, RequestDate, Status
-- Impact: Required for AutoSetBookStatusToLost trigger
CREATE TABLE ReorderRequest (
    ReorderID INT PRIMARY KEY IDENTITY(1,1),
    ISBN VARCHAR(13) NOT NULL,
    CopyID INT NOT NULL,
    MemberID INT NOT NULL,
    RequestDate DATETIME DEFAULT GETDATE(),
    Status VARCHAR(50) CHECK (Status IN ('Pending', 'Ordered', 'Received')),
    FOREIGN KEY (ISBN) REFERENCES Book(ISBN),
    FOREIGN KEY (CopyID) REFERENCES BookCopy(CopyID),
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID)
);
GO

-- =============================================================================
-- Table Creation: AuditLog
-- =============================================================================
-- Purpose: Logs actions related to book status changes (e.g., Lost, Damaged)
-- Functionality: Defines AuditLog table with AuditLogID, CopyID, Status, MemberID, StaffID, ActionDate, ActionDescription
-- Impact: Required for MarkBookAsLostOrDamaged procedure
CREATE TABLE AuditLog (
    AuditLogID INT PRIMARY KEY IDENTITY(1,1),
    CopyID INT NOT NULL,
    Status VARCHAR(50) NOT NULL,
    MemberID INT NOT NULL,
    StaffID INT NOT NULL,
    ActionDate DATETIME DEFAULT GETDATE(),
    ActionDescription VARCHAR(200),
    FOREIGN KEY (CopyID) REFERENCES BookCopy(CopyID),
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID),
    FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)
);
GO

-- =============================================================================
-- Table Alteration: Add DueDate to Loan
-- =============================================================================
-- Purpose: Adds DueDate column to Loan table for tracking loan deadlines
-- Functionality: Adds DATE column and sets default DueDate as CheckoutTime + 30 days for existing records
-- Impact: Required for triggers and procedures handling due dates

-- ALTER TABLE Loan ADD DueDate DATE;

select * from Loan
UPDATE Loan
SET DueDate = DATEADD(day, 30, CheckoutTime);
GO

-- =============================================================================
-- Function: CalculateFine
-- =============================================================================
-- Purpose: Calculates fine for an overdue loan based on DueDate
-- Functionality:
--   - Takes DueDate as input
--   - Returns 0 if DueDate >= current date
--   - Else, calculates fine as days overdue * $10, capped at $200
-- Impact: Used by BlockMembersWithOverdueFines and trg_CalculateFine
CREATE FUNCTION dbo.CalculateFine(@DueDate DATE)
RETURNS INT
AS
BEGIN
    DECLARE @Fine INT;

    IF @DueDate >= GETDATE()
        SET @Fine = 0;
    ELSE
        SET @Fine = DATEDIFF(DAY, @DueDate, GETDATE()) * 10;

    IF @Fine > 200
        SET @Fine = 200;

    RETURN @Fine;
END;
GO

-- Test Command for CalculateFine
-- Description: Test fine calculation for an overdue and non-overdue date
-- Setup: None required (function is standalone)
-- Expected Outcome: Fine=160 for 2025-06-15 (46 days overdue); Fine=0 for 2025-08-01
SELECT dbo.CalculateFine('2025-06-15') AS Fine1, dbo.CalculateFine('2025-08-01') AS Fine2;
GO

-- =============================================================================
-- Trigger 1: trg_SetDueDate
-- =============================================================================
-- Purpose: Automatically sets DueDate based on LoanType for new or updated loans
-- Functionality:
--   - Executes after INSERT or UPDATE on Loan
--   - Sets DueDate: Standard (30 days), ShortLoan (7 days), InterLibrary (1 day), else NULL
--   - Joins Loan with inserted to update affected records
-- Impact: Ensures consistent due dates but may conflict with ProcessBookCheckout
CREATE OR ALTER TRIGGER trg_SetDueDate
ON Loan
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE L
    SET L.DueDate = 
        CASE 
            WHEN L.LoanType = 'Standard' THEN DATEADD(DAY, 30, L.CheckoutTime)
            WHEN L.LoanType = 'ShortLoan' THEN DATEADD(DAY, 7, L.CheckoutTime)
            WHEN L.LoanType = 'InterLibrary' THEN DATEADD(DAY, 1, L.CheckoutTime)
            ELSE NULL
        END
    FROM Loan L
    INNER JOIN inserted I ON L.LoanID = I.LoanID;
END;
GO

-- Test Command for trg_SetDueDate
-- Description: Insert a ShortLoan and verify DueDate is set to CheckoutTime + 7 days
-- Setup: Ensure CopyID=1, MemberID=1, StaffID=1 exist; BookCopy.Status='Available' for CopyID=1
-- Expected Outcome: DueDate='2025-08-07' for CheckoutTime='2025-07-31 20:25:00'
INSERT INTO Loan (CopyID, MemberID, StaffID, CheckoutTime, ReturnDate, RenewalCount, LoanType, DueDate)
VALUES (1, 1, 1, '2025-07-31 20:25:00', NULL, 0, 'ShortLoan', NULL);
SELECT LoanID, CheckoutTime, LoanType, DueDate FROM Loan WHERE CopyID = 1 AND CheckoutTime = '2025-07-31 20:25:00';
GO

-- =============================================================================
-- Trigger 2: AutoSetBookStatusToLost
-- =============================================================================
-- Purpose: Marks BookCopy as 'Lost' and creates ReorderRequest for loans overdue >60 days past CheckoutTime + 30 days
-- Functionality:
--   - Executes after UPDATE on Loan
--   - Checks if DATEDIFF(day, DATEADD(day, 30, CheckoutTime), GETDATE()) > 60 and ReturnDate IS NULL
--   - Updates BookCopy.Status to 'Lost'
--   - Inserts ReorderRequest with 'Pending' status
-- Impact: Automates lost book handling and reordering
CREATE OR ALTER TRIGGER AutoSetBookStatusToLost
ON Loan
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE bc
    SET Status = 'Lost'
    FROM BookCopy bc
    JOIN inserted i ON bc.CopyID = i.CopyID
    JOIN Loan l ON l.CopyID = i.CopyID
    WHERE DATEDIFF(day, DATEADD(day, 30, l.CheckoutTime), GETDATE()) > 60
    AND l.ReturnDate IS NULL;

    INSERT INTO ReorderRequest (ISBN, CopyID, MemberID, Status)
    SELECT b.ISBN, bc.CopyID, l.MemberID, 'Pending'
    FROM BookCopy bc
    JOIN inserted i ON bc.CopyID = i.CopyID
    JOIN Loan l ON l.CopyID = i.CopyID
    JOIN Book b ON b.ISBN = bc.ISBN
    WHERE DATEDIFF(day, DATEADD(day, 30, l.CheckoutTime), GETDATE()) > 60
    AND l.ReturnDate IS NULL;
END;
GO

-- Test Command for AutoSetBookStatusToLost
-- Description: Simulate an overdue loan and verify BookCopy and ReorderRequest updates
-- Setup: Ensure CopyID=2, MemberID=2, StaffID=1, Book.ISBN='9780451524935' exist; BookCopy.Status='OnLoan'
-- Expected Outcome: BookCopy.Status='Lost'; ReorderRequest with Status='Pending' for CopyID=2
INSERT INTO Loan (CopyID, MemberID, StaffID, CheckoutTime, ReturnDate, RenewalCount, LoanType, DueDate)
VALUES (2, 2, 1, '2025-04-01 20:25:00', NULL, 0, 'Standard', '2025-05-01');
UPDATE Loan SET CheckoutTime = '2025-04-01 20:25:00' WHERE CopyID = 2;
SELECT CopyID, Status FROM BookCopy WHERE CopyID = 2;
SELECT ReorderID, CopyID, Status FROM ReorderRequest WHERE CopyID = 2;
GO

-- =============================================================================
-- Trigger 3: trg_CalculateFine
-- =============================================================================
-- Purpose: Calls BlockMembersWithOverdueFines after loan inserts or updates
-- Functionality:
--   - Executes after INSERT or UPDATE on Loan
--   - Runs BlockMembersWithOverdueFines to deactivate members with unpaid fines > $100
-- Impact: Ensures members with overdue fines are deactivated

CREATE PROCEDURE dbo.BlockMembersWithOverdueFines
AS
BEGIN
    UPDATE M
    SET M.IsActive = 0
    FROM Member M
    WHERE M.MemberID IN (
        SELECT L.MemberID
        FROM Loan L
        WHERE L.ReturnDate IS NULL AND L.DueDate < GETDATE()
        GROUP BY L.MemberID
        HAVING 
            SUM(dbo.CalculateFine(L.DueDate)) 
            - ISNULL((
                SELECT SUM(FP2.Amount)
                FROM FinePayment FP2
                WHERE FP2.MemberID = L.MemberID
            ), 0) > 100
    );
END;

CREATE or alter TRIGGER trg_CalculateFine
ON Loan
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.BlockMembersWithOverdueFines;
END;
GO

-- Test Command for trg_CalculateFine
-- Description: Insert an overdue loan and verify member deactivation
-- Setup: Ensure CopyID=3, MemberID=3, StaffID=1 exist; Member.IsActive=1 for MemberID=3
-- Expected Outcome: Member.IsActive=0 for MemberID=3 (fine=$160 for 16 days overdue)
INSERT INTO Loan (CopyID, MemberID, StaffID, CheckoutTime, ReturnDate, RenewalCount, LoanType, DueDate)
VALUES (3, 3, 1, '2025-07-01 20:25:00', NULL, 0, 'Standard', '2025-07-15');
SELECT MemberID, IsActive FROM Member WHERE MemberID = 3;
GO

-- =============================================================================
-- Trigger 4: PreventReferenceBookLoans
-- =============================================================================
-- Purpose: Prevents loans for reference-only books
-- Functionality:
--   - Executes after INSERT on Loan
--   - Checks if Book.isReferenceOnly = 1 via BookCopy and Book
--   - Raises error and rolls back if true
-- Impact: Enforces library policy on reference materials
CREATE TRIGGER PreventReferenceBookLoans
ON Loan
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN BookCopy bc ON i.CopyID = bc.CopyID
        JOIN Book b ON bc.ISBN = b.ISBN
        WHERE b.isReferenceOnly = 1
    )
    BEGIN
        RAISERROR ('Cannot loan a reference-only book.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

-- Test Command for PreventReferenceBookLoans
-- Description: Attempt to loan a reference-only book and verify rollback
-- Setup: Ensure CopyID=1, MemberID=1, StaffID=1, ISBN='9780141036144' exist
-- Expected Outcome: Error message; no loan record created
UPDATE Book SET isReferenceOnly = 1 WHERE ISBN = '9780141036144';
BEGIN TRY
    INSERT INTO Loan (CopyID, MemberID, StaffID, CheckoutTime, ReturnDate, RenewalCount, LoanType)
    VALUES (1, 1, 1, '2025-07-31 20:25:00', NULL, 0, 'Standard');
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
SELECT * FROM Loan WHERE CopyID = 1 AND CheckoutTime = '2025-07-31 20:25:00';
UPDATE Book SET isReferenceOnly = 0 WHERE ISBN = '9780141036144';
GO

-- =============================================================================
-- Procedure 1: ProcessBookCheckout
-- =============================================================================
-- Purpose: Manages book checkout with eligibility checks
-- Functionality:
--   - Validates member: IsActive=1, fines < $100, loan limits (Student: 6, Premium: 5, Adult: 3)
--   - Validates book: BookCopy.Status='Available', Book.isReferenceOnly=0
--   - Updates BookCopy.Status to 'OnLoan'
--   - Sets DueDate (Premium: 21 days, others: 14 days) and LoanType
--   - Inserts Loan record
-- Impact: Ensures valid checkouts and updates tables
CREATE PROCEDURE ProcessBookCheckout
    @MemberID INT,
    @CopyID INT,
    @StaffID INT
AS
BEGIN
    DECLARE @Fines DECIMAL(10,2)
    DECLARE @LoanCount INT
    DECLARE @MembershipType VARCHAR(50)
    DECLARE @DueDate DATE
    DECLARE @LoanType VARCHAR(50)
    DECLARE @IsReferenceOnly BIT
    DECLARE @Status VARCHAR(50)
    DECLARE @ISBN VARCHAR(13)

    SELECT @Fines = SUM(Amount) 
    FROM FinePayment 
    WHERE MemberID = @MemberID

    SELECT @LoanCount = COUNT(*) 
    FROM Loan 
    WHERE MemberID = @MemberID AND ReturnDate IS NULL

    SELECT @MembershipType = MembershipType 
    FROM Member 
    WHERE MemberID = @MemberID AND isActive = 1

    IF @MembershipType IS NULL OR @Fines >= 100 OR
       (@MembershipType = 'Student' AND @LoanCount >= 6) OR
       (@MembershipType = 'Premium' AND @LoanCount >= 5) OR
       (@MembershipType = 'Adult' AND @LoanCount >= 3)
        RETURN

    SELECT @ISBN = B.ISBN, @IsReferenceOnly = B.IsReferenceOnly, @Status = BC.Status
    FROM BookCopy BC
    JOIN Book B ON BC.ISBN = B.ISBN
    WHERE BC.CopyID = @CopyID

    IF @Status != 'Available' OR @IsReferenceOnly = 1
        RETURN

    UPDATE BookCopy SET Status = 'OnLoan' WHERE CopyID = @CopyID

    SET @DueDate = DATEADD(DAY, CASE 
        WHEN @MembershipType = 'Premium' THEN 21 
        ELSE 14 
    END, GETDATE())

    SET @LoanType = CASE 
        WHEN @MembershipType = 'Premium' THEN 'Standard'
        ELSE 'ShortLoan'
    END

    INSERT INTO Loan (CopyID, MemberID, StaffID, CheckoutTime, ReturnDate, RenewalCount, LoanType)
    VALUES (@CopyID, @MemberID, @StaffID, GETDATE(), NULL, 0, @LoanType)
END;
GO

-- Test Command for ProcessBookCheckout
-- Description: Execute checkout for a valid member and book copy
-- Setup: Ensure MemberID=4 (Student, IsActive=1, no fines), CopyID=4 (Status='Available', ISBN='9780747532743'), StaffID=1 exist
-- Expected Outcome: New Loan with LoanType='ShortLoan', DueDate='2025-08-14'; BookCopy.Status='OnLoan'
EXEC ProcessBookCheckout @MemberID = 4, @CopyID = 4, @StaffID = 1;
SELECT LoanID, CopyID, MemberID, LoanType, CheckoutTime, DueDate FROM Loan WHERE CopyID = 4 AND MemberID = 4 AND ReturnDate IS NULL;
SELECT CopyID, Status FROM BookCopy WHERE CopyID = 4;
GO

-- =============================================================================
-- Procedure 2: ProcessBookReturn
-- =============================================================================
-- Purpose: Processes book returns, calculates fines, and deactivates members if needed
-- Functionality:
--   - Finds latest active loan for CopyID
--   - Updates Loan.ReturnDate and BookCopy.Status to 'Available'
--   - Calculates fine (days overdue * $10, max $200) if overdue
--   - Inserts FinePayment; deactivates member if total fines >= $100
-- Impact: Manages returns and enforces financial policies
CREATE PROCEDURE ProcessBookReturn
    @CopyID INT,
    @StaffID INT
AS
BEGIN
    DECLARE @LoanID INT
    DECLARE @DueDate DATE
    DECLARE @ReturnDate DATE = GETDATE()
    DECLARE @MemberID INT
    DECLARE @Fine DECIMAL(10,2) = 0

    SELECT TOP 1 @LoanID = LoanID, @DueDate = DATEADD(DAY, CASE 
        WHEN M.MembershipType = 'Premium' THEN 21 
        ELSE 14 
    END, L.CheckoutTime), @MemberID = L.MemberID
    FROM Loan L
    JOIN Member M ON L.MemberID = M.MemberID
    WHERE CopyID = @CopyID AND ReturnDate IS NULL
    ORDER BY CheckoutTime DESC

    IF @LoanID IS NULL RETURN

    UPDATE Loan SET ReturnDate = @ReturnDate WHERE LoanID = @LoanID
    UPDATE BookCopy SET Status = 'Available' WHERE CopyID = @CopyID

    IF @ReturnDate > @DueDate
    BEGIN
        SET @Fine = DATEDIFF(DAY, @DueDate, @ReturnDate) * 10
        IF @Fine > 200 SET @Fine = 200

        INSERT INTO FinePayment (MemberID, LoanID, StaffID, Amount, PaymentDate, Method, ReceiptNumber)
        VALUES (@MemberID, @LoanID, @StaffID, @Fine, @ReturnDate, 'cash', CONCAT('FP-', NEWID()))

        IF (SELECT SUM(Amount) FROM FinePayment WHERE MemberID = @MemberID) >= 100
        BEGIN
            UPDATE Member SET isActive = 0 WHERE MemberID = @MemberID
        END
    END
END;
GO

-- Test Command for ProcessBookReturn
-- Description: Return an overdue book and verify updates
-- Setup: Insert overdue loan for CopyID=5, MemberID=5 (Premium), StaffID=2; No prior fines
-- Expected Outcome: Loan.ReturnDate='2025-07-31'; BookCopy.Status='Available'; FinePayment.Amount=$160; Member.IsActive=0
INSERT INTO Loan (CopyID, MemberID, StaffID, CheckoutTime, ReturnDate, RenewalCount, LoanType, DueDate)
VALUES (5, 5, 2, '2025-07-01 20:25:00', NULL, 0, 'Standard', '2025-07-15');
EXEC ProcessBookReturn @CopyID = 5, @StaffID = 2;
SELECT LoanID, CopyID, ReturnDate FROM Loan WHERE CopyID = 5 AND MemberID = 5;
SELECT CopyID, Status FROM BookCopy WHERE CopyID = 5;
SELECT MemberID, LoanID, Amount FROM FinePayment WHERE MemberID = 5;
SELECT MemberID, IsActive FROM Member WHERE MemberID = 5;
GO

-- =============================================================================
-- Procedure 3: GenerateMonthlyGenrePopularityReport
-- =============================================================================
-- Purpose: Reports loan counts by genre and membership type for a date range
-- Functionality:
--   - Joins Loan, BookCopy, Book, Genre, Member
--   - Filters CheckoutTime between StartDate and EndDate
--   - Groups by GenreName, MembershipType; counts loans
-- Impact: Provides borrowing trend insights
CREATE PROCEDURE GenerateMonthlyGenrePopularityReport
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SELECT 
        G.GenreName,
        M.MembershipType,
        COUNT(*) AS BorrowCount
    FROM Loan L
    JOIN BookCopy BC ON L.CopyID = BC.CopyID
    JOIN Book B ON BC.ISBN = B.ISBN
    JOIN Genre G ON B.Genre_ID = G.Genre_ID
    JOIN Member M ON L.MemberID = M.MemberID
    WHERE L.CheckoutTime BETWEEN @StartDate AND @EndDate
    GROUP BY G.GenreName, M.MembershipType
    ORDER BY BorrowCount DESC
END;
GO

-- Test Command for GenerateMonthlyGenrePopularityReport
-- Description: Generate report for July 2025
-- Setup: Ensure loans exist in July 2025 (e.g., from Data Population.sql or prior tests)
-- Expected Outcome: Counts by genre and membership (e.g., Fiction/Student=2)
EXEC GenerateMonthlyGenrePopularityReport @StartDate = '2025-07-01', @EndDate = '2025-07-31';
GO


-- =============================================================================
-- Procedure 4: MarkBookAsLostOrDamaged
-- =============================================================================
-- Purpose: Marks a book as Lost or Damaged, records fine, and logs action
-- Functionality:
--   - Validates inputs: CopyID, Status ('Lost'/'Damaged'), MemberID, StaffID
--   - Updates BookCopy.Status and LastAuditDate
--   - Uses BookCopy.Price as fine amount
--   - Inserts FinePayment for active loan
--   - Logs action in AuditLog
-- Impact: Manages inventory and financial accountability
CREATE PROCEDURE MarkBookAsLostOrDamaged
    @CopyID INT,
    @Status VARCHAR(50),
    @MemberID INT,
    @StaffID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM BookCopy WHERE CopyID = @CopyID)
            THROW 50001, 'Invalid CopyID.', 1;
        IF @Status NOT IN ('Lost', 'Damaged')
            THROW 50002, 'Status must be ''Lost'' or ''Damaged''.', 1;
        IF NOT EXISTS (SELECT 1 FROM Member WHERE MemberID = @MemberID)
            THROW 50003, 'Invalid MemberID.', 1;
        IF NOT EXISTS (SELECT 1 FROM Staff WHERE StaffID = @StaffID)
            THROW 50004, 'Invalid StaffID.', 1;

        DECLARE @ReplacementCost DECIMAL(10, 2);
        DECLARE @LoanID INT;

        UPDATE BookCopy
        SET Status = @Status,
            LastAuditDate = GETDATE()
        WHERE CopyID = @CopyID;

        SELECT @ReplacementCost = Price
        FROM BookCopy
        WHERE CopyID = @CopyID;

        SELECT @LoanID = LoanID
        FROM Loan
        WHERE CopyID = @CopyID AND ReturnDate IS NULL;

        IF @LoanID IS NOT NULL
        BEGIN
            INSERT INTO FinePayment (MemberID, LoanID, StaffID, Amount, PaymentDate, Method, ReceiptNumber)
            VALUES (@MemberID, @LoanID, @StaffID, @ReplacementCost, GETDATE(), 'cash', 'FP' + CAST((SELECT COUNT(*) + 1 FROM FinePayment) AS VARCHAR(10)));
        END
        ELSE
            THROW 50005, 'No active loan found for the specified CopyID.', 1;

        INSERT INTO AuditLog (CopyID, Status, MemberID, StaffID, ActionDescription)
        VALUES (@CopyID, @Status, @MemberID, @StaffID, 
                'Book marked as ' + @Status + ' with fine payment of ' + CAST(@ReplacementCost AS VARCHAR(10)));
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

-- Test Command for MarkBookAsLostOrDamaged
-- Description: Mark a book as Lost and verify updates
-- Setup: Insert active loan for CopyID=7, MemberID=7, StaffID=1; BookCopy.Price=11.99
-- Expected Outcome: BookCopy.Status='Lost'; FinePayment.Amount=11.99; AuditLog entry
INSERT INTO Loan (CopyID, MemberID, StaffID, CheckoutTime, ReturnDate, RenewalCount, LoanType, DueDate)
VALUES (7, 7, 1, '2025-07-30 20:25:00', NULL, 0, 'ShortLoan', '2025-08-06');
EXEC MarkBookAsLostOrDamaged @CopyID = 7, @Status = 'Lost', @MemberID = 7, @StaffID = 1;
SELECT CopyID, Status, LastAuditDate FROM BookCopy WHERE CopyID = 7;
SELECT MemberID, LoanID, Amount FROM FinePayment WHERE MemberID = 7;
SELECT AuditLogID, CopyID, ActionDescription FROM AuditLog WHERE CopyID = 7;
GO

-- Cleanup for Test Data
-- Description: Remove test data to prevent conflicts
-- Execute after all tests
DELETE FROM Loan WHERE CheckoutTime >= '2025-07-01';
DELETE FROM FinePayment WHERE ReceiptNumber LIKE 'FP%';
DELETE FROM ReorderRequest WHERE CopyID IN (2);
DELETE FROM AuditLog WHERE CopyID IN (7);
UPDATE Member SET IsActive = 1 WHERE MemberID IN (3, 5, 6);
UPDATE BookCopy SET Status = 'Available' WHERE CopyID IN (4, 5);
GO

