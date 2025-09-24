-- =============================================
-- BOOK-RELATED QUERIES
-- =============================================

-- 1. Find all books published after 2010
SELECT 
    Title, 
    PublicationYear 
FROM Book 
WHERE PublicationYear > 2010 
ORDER BY PublicationYear DESC;

-- 2. Count books by genre
SELECT 
    g.GenreName, 
    COUNT(b.ISBN) AS BookCount
FROM Book b
JOIN Genre g ON b.Genre_ID = g.Genre_ID
GROUP BY g.GenreName
ORDER BY BookCount DESC;

-- 3. Show number of books published by each publisher
SELECT 
    p.Name, 
    COUNT(b.ISBN) AS BooksPublished
FROM Book b
JOIN Publisher p ON b.PublisherID = p.PublisherID
GROUP BY p.Name
ORDER BY BooksPublished DESC;

-- 4. Find all book copies and their shelf locations
SELECT 
    b.Title, 
    bc.ShelfLocation, 
    bc.Condition, 
    bc.Status
FROM BookCopy bc
JOIN Book b ON bc.ISBN = b.ISBN
ORDER BY bc.ShelfLocation;

-- 5. Report on book copy conditions
SELECT 
    Condition, 
    COUNT(*) AS Count
FROM BookCopy
GROUP BY Condition
ORDER BY Count DESC;

-- =============================================
-- MEMBER-RELATED QUERIES
-- =============================================

-- 6. Count members by membership type
SELECT 
    MembershipType, 
    COUNT(*) AS MemberCount
FROM Member
WHERE IsActive = 1
GROUP BY MembershipType
ORDER BY MemberCount DESC;

-- 7. Show loan history for a specific member (e.g., Alice Johnson)
SELECT 
    b.Title, 
    l.CheckoutTime, 
    l.ReturnDate
FROM Loan l
JOIN BookCopy bc ON l.CopyID = bc.CopyID
JOIN Book b ON bc.ISBN = b.ISBN
WHERE l.MemberID = 1
ORDER BY l.CheckoutTime DESC;

-- 8. Check current reservations
SELECT 
    b.Title, 
    m.FirstName, 
    m.LastName, 
    r.RequestDate, 
    r.Status
FROM Reservation r
JOIN Book b ON r.ISBN = b.ISBN
JOIN Member m ON r.MemberID = m.MemberID
WHERE r.Status != 'Completed'
ORDER BY r.RequestDate;

-- =============================================
-- STAFF & OPERATIONAL QUERIES
-- =============================================

-- 9. List all staff members with their positions
SELECT 
    m.FirstName, 
    m.LastName, 
    s.Position, 
    s.HireDate, 
    s.SalaryGrade
FROM Staff s
JOIN Member m ON s.MemberID = m.MemberID
ORDER BY s.HireDate DESC;

-- 10. Show total fines collected by payment method
SELECT 
    Method, 
    SUM(Amount) AS TotalAmount
FROM FinePayment
GROUP BY Method
ORDER BY TotalAmount DESC;

-- 11. Show upcoming library events
SELECT 
    Name, 
    Type, 
    StartTime, 
    EndTime 
FROM Event 
WHERE StartTime > GETDATE()
ORDER BY StartTime;