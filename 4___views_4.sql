-- =============================================
-- VIEW: Monthly Genre Popularity by Membership Type
-- Shows genre popularity among different membership types in the last month
-- =============================================
GO
CREATE OR ALTER VIEW vw_MonthlyGenrePopularityByMembership AS
SELECT 
    m.MembershipType,
    g.GenreName,
    COUNT(l.LoanID) AS LoanCount
FROM Loan l
JOIN BookCopy bc ON l.CopyID = bc.CopyID
JOIN Book b ON bc.ISBN = b.ISBN
JOIN Genre g ON b.Genre_ID = g.Genre_ID
JOIN Member m ON l.MemberID = m.MemberID
WHERE l.CheckoutTime >= DATEADD(MONTH, -1, CONVERT(DATE, GETDATE()))
GROUP BY g.GenreName, m.MembershipType;
GO

-- Query the view
SELECT * FROM vw_MonthlyGenrePopularityByMembership
ORDER BY LoanCount DESC;
GO

-- =============================================
-- VIEW: Active Loans by Member
-- Shows current active loans with member details and loan limits
-- =============================================
GO
CREATE OR ALTER VIEW vw_ActiveLoansByMember AS
SELECT 
    m.FirstName,
    m.LastName,
    m.MembershipType,
    COUNT(l.LoanID) AS ActiveLoans,
    CASE 
        WHEN m.MembershipType = 'Student' THEN 6
        WHEN m.MembershipType = 'Premium' THEN 5
        WHEN m.MembershipType = 'Adult' THEN 3
    END AS LoanLimit
FROM Member m
LEFT JOIN Loan l ON m.MemberID = l.MemberID AND l.ReturnDate IS NULL
GROUP BY m.MemberID, m.FirstName, m.LastName, m.MembershipType
HAVING COUNT(l.LoanID) > 0;
GO

-- Query the view 
SELECT * FROM vw_ActiveLoansByMember

-- =============================================
-- TEST DATA: Active Loans
-- Adding sample active loans for testing
-- =============================================
-- Regular active loans
INSERT INTO Loan (CopyID, MemberID, StaffID, CheckoutTime, RenewalCount, LoanType, DueDate) VALUES
(11, 1, 1, '2025-07-25 10:00', 0, 'ShortLoan', '2025-08-08'),  -- Student with 1 active loan
(12, 2, 2, '2025-07-25 11:00', 1, 'Standard', '2025-08-15'),   -- Premium with 1 active loan
(13, 3, 3, '2025-07-25 12:00', 0, 'ShortLoan', '2025-08-08'),  -- Adult with 1 active loan
(14, 4, 4, '2025-07-25 13:00', 0, 'ShortLoan', '2025-08-08'),  -- Student with 1 active loan
(15, 5, 5, '2025-07-25 14:00', 1, 'Standard', '2025-08-15'),   -- Premium with 1 active loan
(16, 6, 1, '2025-07-25 15:00', 0, 'ShortLoan', '2025-08-08'),  -- Adult with 1 active loan
(17, 7, 2, '2025-07-25 16:00', 0, 'ShortLoan', '2025-08-08'),  -- Student with 1 active loan
(18, 8, 3, '2025-07-25 17:00', 1, 'Standard', '2025-08-15'),   -- Premium with 1 active loan
(19, 9, 4, '2025-07-25 18:00', 0, 'ShortLoan', '2025-08-08'),  -- Adult with 1 active loan
(20, 10, 5, '2025-07-25 19:00', 0, 'ShortLoan', '2025-08-08'); -- Student with 1 active loan

-- Student member who has exceeded loan limit (6 books)
INSERT INTO Loan (CopyID, MemberID, StaffID, CheckoutTime, RenewalCount, LoanType, DueDate) VALUES
(21, 1, 1, '2025-07-20 10:00', 0, 'ShortLoan', '2025-08-03'),  -- Student Alice Johnson
(22, 1, 1, '2025-07-21 11:00', 0, 'ShortLoan', '2025-08-04'),  -- (now has 3 active loans)
(23, 1, 1, '2025-07-22 12:00', 0, 'ShortLoan', '2025-08-05'),
(24, 1, 1, '2025-07-23 13:00', 0, 'ShortLoan', '2025-08-06'),
(25, 1, 1, '2025-07-24 14:00', 0, 'ShortLoan', '2025-08-07'),
(26, 1, 1, '2025-07-25 15:00', 0, 'ShortLoan', '2025-08-08');  -- 6th active loan (limit reached)
GO

-- =============================================
-- VIEW: Books Lost or Damaged
-- Shows books marked as lost or damaged with member info
-- =============================================
GO
CREATE OR ALTER VIEW vw_BooksLostOrDamaged AS
SELECT 
    b.Title,
    bc.Status,
    bc.LastAuditDate,
    m.FirstName,
    m.LastName
FROM BookCopy bc
JOIN Book b ON bc.ISBN = b.ISBN
LEFT JOIN Loan l ON bc.CopyID = l.CopyID AND l.ReturnDate IS NULL
LEFT JOIN Member m ON l.MemberID = m.MemberID
WHERE bc.Status IN ('Lost', 'Damaged');
GO

-- Query the view 
SELECT * FROM vw_BooksLostOrDamaged

-- =============================================
-- TEST DATA: Lost/Damaged Books
-- Updating status and creating associated loans
-- =============================================
-- Update book copies to Lost or Damaged status
UPDATE BookCopy SET Status = 'Lost', LastAuditDate = '2025-07-20' WHERE CopyID = 27;  -- Lord of the Rings

-- Create loans for these lost/damaged books that haven't been returned
INSERT INTO Loan (CopyID, MemberID, StaffID, CheckoutTime, RenewalCount, LoanType, DueDate) VALUES
(27, 11, 1, '2025-06-01 10:00', 0, 'Standard', '2025-06-22'),  -- Now marked as Lost
(28, 12, 2, '2025-06-15 11:00', 1, 'ShortLoan', '2025-06-29'); -- Now marked as Damaged
GO


-- =============================================
-- View: Summary of fine per loan 
-- =============================================

CREATE OR ALTER VIEW vw_LoanFinesSummary AS
SELECT 
    L.LoanID,

    -- Fine based on due and return dates
    CASE
        WHEN ReturnDate IS NULL THEN 0
        WHEN DATEDIFF(DAY, DueDate, ReturnDate) * 10 > 200 THEN 200
        WHEN DATEDIFF(DAY, DueDate, ReturnDate) > 0 THEN DATEDIFF(DAY, DueDate, ReturnDate) * 10
        ELSE 0
    END AS CalculatedFine,

    -- Total paid for this loan
    ISNULL(SUM(FP.Amount), 0) AS TotalPaid,

    -- Remaining fine after payments
    CASE
        WHEN 
            (CASE
                WHEN ReturnDate IS NULL THEN 0
                WHEN DATEDIFF(DAY, DueDate, ReturnDate) * 10 > 200 THEN 200
                WHEN DATEDIFF(DAY, DueDate, ReturnDate) > 0 THEN DATEDIFF(DAY, DueDate, ReturnDate) * 10
                ELSE 0
            END) - ISNULL(SUM(FP.Amount), 0) > 0
        THEN 
            (CASE
                WHEN ReturnDate IS NULL THEN 0
                WHEN DATEDIFF(DAY, DueDate, ReturnDate) * 10 > 200 THEN 200
                WHEN DATEDIFF(DAY, DueDate, ReturnDate) > 0 THEN DATEDIFF(DAY, DueDate, ReturnDate) * 10
                ELSE 0
            END) - ISNULL(SUM(FP.Amount), 0)
        ELSE 0
    END AS RemainingFine

FROM Loan L
LEFT JOIN FinePayment FP ON L.LoanID = FP.LoanID
GROUP BY L.LoanID, ReturnDate, DueDate;
GO

SELECT * FROM vw_LoanFinesSummary
