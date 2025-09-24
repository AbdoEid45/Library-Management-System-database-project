-------------------------------------------------------
-- FUNCTION 1: Get Total Fines for Member
-------------------------------------------------------
CREATE OR ALTER FUNCTION fn_GetTotalFines (@MemberID INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN ISNULL((
        SELECT SUM(Amount) 
        FROM FinePayment 
        WHERE MemberID = @MemberID
    ), 0);
END;
GO

-------------------------------------------------------
-- FUNCTION 2: Get Available Book Copies
-------------------------------------------------------
CREATE OR ALTER FUNCTION fn_GetAvailableCopies (@ISBN VARCHAR(13))
RETURNS INT
AS
BEGIN
    RETURN ISNULL((
        SELECT COUNT(*) 
        FROM BookCopy 
        WHERE ISBN = @ISBN AND Status = 'Available'
    ), 0);
END;
GO

-------------------------------------------------------
-- FUNCTION 3: Get Member Full Name
-------------------------------------------------------
CREATE OR ALTER FUNCTION fn_MemberFullName (@MemberID INT)
RETURNS VARCHAR(200)
AS
BEGIN
    RETURN ISNULL((
        SELECT FirstName + ' ' + LastName 
        FROM Member 
        WHERE MemberID = @MemberID
    ), 'Unknown Member');
END;
GO

-------------------------------------------------------
-- FUNCTION 4: Get n Days Late 
-------------------------------------------------------
GO
CREATE OR ALTER FUNCTION fn_DaysOverdue (@ReturnDate DATE)
RETURNS INT
AS
BEGIN
    DECLARE @Days INT;

    SET @Days = 
        CASE 
            WHEN DATEDIFF(DAY, @ReturnDate, CAST(GETDATE() AS DATE)) > 0 
                THEN DATEDIFF(DAY, @ReturnDate, CAST(GETDATE() AS DATE))
            ELSE 0
        END;

    RETURN @Days;
END;
GO


-------------------------------------------------------
-- TEST DATA 
-------------------------------------------------------
INSERT INTO FinePayment (MemberID, LoanID, StaffID, Amount, PaymentDate, Method, ReceiptNumber)
VALUES
(1, 1, 1, 50.00, '2025-08-01', 'cash', 'R001'),
(1, 2, 1, 30.00, '2025-08-01', 'cash', 'R002'),
(2, 1, 1, 100.00, '2025-08-01', 'visa', 'R003');

INSERT INTO Book (ISBN, Title) VALUES ('1234567890123', 'Test Book');

INSERT INTO BookCopy (ISBN, Status) VALUES 
('1234567890123', 'Available'),
('1234567890123', 'Available'),
('1234567890123', 'OnLoan');

-------------------------------------------------------
-- FUNCTION TESTS 
-------------------------------------------------------

-- Test fn_GetTotalFines
SELECT 
    dbo.fn_GetTotalFines(1) AS [TOTAL FINE FOR M.ID = 1],
    dbo.fn_GetTotalFines(2) AS [TOTAL FINE FOR M.ID = 2];

-- Test fn_GetAvailableCopies 
SELECT dbo.fn_GetAvailableCopies('1234567890123') AS [Available Copies];
SELECT dbo.fn_GetAvailableCopies('0000000000000') AS [Available Copies];

-- Test fn_MemberFullName 
SELECT dbo.fn_MemberFullName(1) AS FullName;


-- Test fn_DaysOverdue
SELECT 
    LoanID, 
    MemberID, 
    ReturnDate,
    dbo.fn_DaysOverdue(ReturnDate) AS DaysOverdue
FROM Loan;

SELECT dbo.fn_DaysOverdue('2025-07-25') AS OverdueDays