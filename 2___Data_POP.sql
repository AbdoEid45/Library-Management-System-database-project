-- Insert into Genre (10 rows)
INSERT INTO Genre (GenreName) VALUES
('Fiction'), ('Non-Fiction'), ('Mystery'), ('Science Fiction'), ('Fantasy'),
('Romance'), ('Biography'), ('History'), ('Thriller'), ('Children');

-- Insert into Publisher (10 rows)
INSERT INTO Publisher (Name, Address, Phone) VALUES
('Penguin Books', 'London, UK', '+44-20-1234-5678'), ('HarperCollins', 'New York, USA', '+1-212-987-6543'),
('Random House', 'Berlin, Germany', '+49-30-555-1234'), ('Hachette', 'Paris, France', '+33-1-444-5555'),
('Simon & Schuster', 'New York, USA', '+1-212-698-7410'), ('Macmillan', 'London, UK', '+44-20-8765-4321'),
('Scholastic', 'New York, USA', '+1-212-369-2580'), ('Bloomsbury', 'London, UK', '+44-20-7432-1098'),
('Springer', 'Berlin, Germany', '+49-30-827-3645'), ('Elsevier', 'Amsterdam, Netherlands', '+31-20-485-1111');

-- Insert into Author (50 rows)
INSERT INTO Author (name, bio, nationality) VALUES
('John Smith', 'Renowned fiction writer', 'UK'), ('Jane Doe', 'Mystery novelist', 'USA'), ('Michael Brown', 'Sci-Fi author', 'Canada'),
('Sarah Davis', 'Fantasy storyteller', 'Australia'), ('Robert Wilson', 'Non-Fiction expert', 'UK'), ('Emily Taylor', 'Romance writer', 'USA'),
('David Anderson', 'Historian', 'Germany'), ('Lisa Martinez', 'Thriller author', 'Spain'), ('James Garcia', 'Children''s book writer', 'Mexico'),
('Mary Lopez', 'Biographer', 'Argentina'), ('William Hernandez', 'Fiction writer', 'USA'), ('Patricia Gonzalez', 'Mystery author', 'Spain'),
('Charles Perez', 'Sci-Fi novelist', 'France'), ('Barbara Sanchez', 'Fantasy creator', 'Italy'), ('Thomas Ramirez', 'Non-Fiction writer', 'UK'),
('Linda Torres', 'Romance novelist', 'USA'), ('Christopher Flores', 'Historian', 'Germany'), ('Elizabeth Rivera', 'Thriller writer', 'Spain'),
('Daniel Gomez', 'Children''s author', 'Mexico'), ('Jennifer Diaz', 'Biographer', 'Argentina'), ('Matthew Cruz', 'Fiction writer', 'USA'),
('Susan Morales', 'Mystery novelist', 'Spain'), ('Andrew Ortiz', 'Sci-Fi author', 'France'), ('Margaret Gutierrez', 'Fantasy writer', 'Italy'),
('Mark Chavez', 'Non-Fiction expert', 'UK'), ('Karen Reyes', 'Romance author', 'USA'), ('Steven Jimenez', 'Historian', 'Germany'),
('Nancy Ruiz', 'Thriller writer', 'Spain'), ('Paul Alvarez', 'Children''s book author', 'Mexico'), ('Betty Mendoza', 'Biographer', 'Argentina'),
('George Castillo', 'Fiction writer', 'USA'), ('Dorothy Munoz', 'Mystery author', 'Spain'), ('Richard Herrera', 'Sci-Fi novelist', 'France'),
('Helen Moreno', 'Fantasy creator', 'Italy'), ('Joseph Delgado', 'Non-Fiction writer', 'UK'), ('Ruth Vargas', 'Romance novelist', 'USA'),
('Donald Romero', 'Historian', 'Germany'), ('Sharon Soto', 'Thriller author', 'Spain'), ('Kenneth Ortega', 'Children''s writer', 'Mexico'),
('Carol Silva', 'Biographer', 'Argentina'), ('Edward-register', 'Fiction writer', 'USA'), ('Joyce Nunez', 'Mystery novelist', 'Spain'),
('Ronald Molina', 'Sci-Fi author', 'France'), ('Deborah Leon', 'Fantasy writer', 'Italy'), ('Anthony Rojas', 'Non-Fiction expert', 'UK'),
('Virginia Fernandez', 'Romance author', 'USA'), ('Kevin Ibarra', 'Historian', 'Germany'), ('Brenda Salazar', 'Thriller writer', 'Spain');

-- Insert into Book (50 rows)
INSERT INTO Book (ISBN, Title, Language, Genre_ID, PageCount, PublicationYear, isReferenceOnly, PublisherID) VALUES
('9780141036144', 'The Silent Patient', 'English', 3, 352, 2019, 0, 1), ('9780451524935', '1984', 'English', 4, 328, 1949, 0, 2),
('9780141439518', 'Pride and Prejudice', 'English', 6, 432, 1813, 0, 3), ('9780547928227', 'The Hobbit', 'English', 5, 310, 1937, 0, 4),
('9780062316097', 'Sapiens', 'English', 2, 464, 2011, 0, 5), ('9780307588371', 'Gone Girl', 'English', 3, 432, 2012, 0, 6),
('9780441172719', 'Dune', 'English', 4, 412, 1965, 0, 7), ('9781250080400', 'The Nightingale', 'English', 1, 448, 2015, 0, 8),
('9780399590504', 'Educated', 'English', 7, 352, 2018, 0, 9), ('9780307474278', 'The Da Vinci Code', 'English', 9, 489, 2003, 0, 10),
('9780735219090', 'Where the Crawdads Sing', 'English', 1, 384, 2018, 0, 1), ('9780446310789', 'To Kill a Mockingbird', 'English', 1, 281, 1960, 0, 2),
('9780743273565', 'The Great Gatsby', 'English', 1, 180, 1925, 0, 3), ('9780747532743', 'Harry Potter', 'English', 5, 309, 1997, 0, 4),
('9781524763138', 'Becoming', 'English', 7, 464, 2018, 0, 5), ('9780061122415', 'The Alchemist', 'English', 1, 208, 1988, 0, 6),
('9781476733019', 'A Man Called Ove', 'English', 1, 337, 2012, 0, 7), ('9780307387899', 'The Road', 'English', 1, 287, 2006, 0, 8),
('9780735211292', 'Atomic Habits', 'English', 2, 320, 2018, 0, 9), ('9780553418026', 'The Martian', 'English', 4, 387, 2011, 0, 10),
('9780143105894', 'Little Women', 'English', 1, 449, 1868, 0, 1), ('9780060850524', 'Brave New World', 'English', 4, 268, 1932, 0, 2),
('9780316769488', 'The Catcher in the Rye', 'English', 1, 234, 1951, 0, 3), ('9780064400558', 'Charlotte''s Web', 'English', 10, 192, 1952, 0, 4),
('9780062457714', 'The Subtle Art of Not Giving', 'English', 2, 224, 2016, 0, 5), ('9780316055437', 'The Goldfinch', 'English', 1, 771, 2013, 0, 6),
('9780618640157', 'Lord of the Rings', 'English', 5, 1178, 1954, 0, 7), ('9780142407332', 'The Outsiders', 'English', 1, 180, 1967, 0, 8),
('9780374533557', 'Thinking, Fast and Slow', 'English', 2, 499, 2011, 0, 9), ('9781594633669', 'The Girl on the Train', 'English', 3, 336, 2015, 0, 10);

-- Insert into BookAuthor (50 rows)
INSERT INTO BookAuthor (BookISBN, AuthorID, Role) VALUES
('9780141036144', 1, 'Author'), ('9780451524935', 2, 'Author'), ('9780141439518', 3, 'Author'),
('9780547928227', 4, 'Author'), ('9780062316097', 5, 'Author'), ('9780307588371', 6, 'Author'),
('9780441172719', 7, 'Author'), ('9781250080400', 8, 'Author'), ('9780399590504', 9, 'Author'),
('9780307474278', 10, 'Author'), ('9780735219090', 11, 'Author'), ('9780446310789', 12, 'Author'),
('9780743273565', 13, 'Author'), ('9780747532743', 14, 'Author'), ('9781524763138', 15, 'Author'),
('9780061122415', 16, 'Author'), ('9781476733019', 17, 'Author'), ('9780307387899', 18, 'Author'),
('9780735211292', 19, 'Author'), ('9780553418026', 20, 'Author'), ('9780143105894', 21, 'Author'),
('9780060850524', 22, 'Author'), ('9780316769488', 23, 'Author'), ('9780064400558', 24, 'Author'),
('9780062457714', 25, 'Author'), ('9780316055437', 26, 'Author'), ('9780618640157', 27, 'Author'),
('9780142407332', 28, 'Author'), ('9780374533557', 29, 'Author'), ('9781594633669', 30, 'Author'),
('9780141036144', 31, 'Co-Author'), ('9780451524935', 32, 'Co-Author'), ('9780141439518', 33, 'Co-Author'),
('9780547928227', 34, 'Co-Author'), ('9780062316097', 35, 'Co-Author'), ('9780307588371', 36, 'Co-Author'),
('9780441172719', 37, 'Co-Author'), ('9781250080400', 38, 'Co-Author'), ('9780399590504', 39, 'Co-Author'),
('9780307474278', 40, 'Co-Author'), ('9780735219090', 41, 'Co-Author'), ('9780446310789', 42, 'Co-Author'),
('9780743273565', 43, 'Co-Author'), ('9780747532743', 44, 'Co-Author'), ('9781524763138', 45, 'Co-Author'),
('9780061122415', 46, 'Co-Author'), ('9781476733019', 47, 'Co-Author'), ('9780307387899', 48, 'Co-Author');

-- Insert into BookCopy (50 rows)
INSERT INTO BookCopy (ISBN, ArrivalDate, Price, Condition, ShelfLocation, LastAuditDate, Status) VALUES
('9780141036144', '2023-01-15', 12.99, 'Good', 'A1-12', '2025-07-01', 'Available'), -- CopyID 1
('9780451524935', '2022-06-10', 9.99, 'Good', 'A2-05', '2025-06-15', 'Available'), -- CopyID 2 (returned)
('9780141439518', '2021-03-22', 8.99, 'Worn', 'B1-09', '2025-07-01', 'Available'), -- CopyID 3
('9780547928227', '2020-11-18', 11.99, 'Good', 'B2-14', '2025-06-20', 'Available'), -- CopyID 4
('9780062316097', '2023-04-05', 15.99, 'Good', 'C1-03', '2025-07-01', 'Available'), -- CopyID 5
('9780307588371', '2022-09-30', 13.99, 'Good', 'C2-07', '2025-06-25', 'Available'), -- CopyID 6
('9780441172719', '2021-07-12', 14.99, 'Worn', 'D1-11', '2025-07-01', 'Available'), -- CopyID 7
('9781250080400', '2023-02-14', 10.99, 'Good', 'D2-06', '2025-06-30', 'Available'), -- CopyID 8
('9780399590504', '2022-08-20', 16.99, 'Good', 'E1-04', '2025-07-01', 'Available'), -- CopyID 9
('9780307474278', '2021-05-25', 12.99, 'Good', 'E2-10', '2025-06-15', 'Available'), -- CopyID 10
('9780735219090', '2023-03-10', 13.99, 'Good', 'F1-08', '2025-07-01', 'Available'), -- CopyID 11
('9780446310789', '2022-12-05', 9.99, 'Worn', 'F2-13', '2025-06-20', 'Available'), -- CopyID 12
('9780743273565', '2021-10-15', 8.99, 'Good', 'G1-02', '2025-07-01', 'Available'), -- CopyID 13
('9780747532743', '2023-01-30', 11.99, 'Good', 'G2-07', '2025-06-25', 'Available'), -- CopyID 14
('9781524763138', '2022-07-18', 15.99, 'Good', 'H1-05', '2025-07-01', 'Available'), -- CopyID 15
('9780061122415', '2021-04-22', 10.99, 'Good', 'H2-11', '2025-06-30', 'Available'), -- CopyID 16
('9781476733019', '2023-06-10', 12.99, 'Worn', 'I1-09', '2025-07-01', 'Available'), -- CopyID 17
('9780307387899', '2022-11-25', 11.99, 'Good', 'I2-04', '2025-06-15', 'Available'), -- CopyID 18
('9780735211292', '2021-09-05', 14.99, 'Good', 'J1-03', '2025-07-01', 'Available'), -- CopyID 19
('9780553418026', '2023-03-15', 13.99, 'Good', 'J2-08', '2025-06-20', 'Available'), -- CopyID 20
('9780143105894', '2022-05-20', 9.99, 'Worn', 'A1-06', '2025-07-01', 'Available'), -- CopyID 21
('9780060850524', '2021-08-10', 10.99, 'Good', 'A2-12', '2025-06-25', 'Available'), -- CopyID 22
('9780316769488', '2023-02-05', 8.99, 'Good', 'B1-07', '2025-07-01', 'Available'), -- CopyID 23
('9780064400558', '2022-10-15', 7.99, 'Good', 'B2-03', '2025-06-30', 'Available'), -- CopyID 24
('9780062457714', '2021-06-30', 14.99, 'Worn', 'C1-10', '2025-07-01', 'Available'), -- CopyID 25
('9780316055437', '2023-04-20', 15.99, 'Good', 'C2-05', '2025-06-15', 'Available'), -- CopyID 26
('9780618640157', '2022-07-25', 12.99, 'Good', 'D1-09', '2025-07-01', 'Available'), -- CopyID 27
('9780142407332', '2021-03-10', 9.99, 'Good', 'D2-11', '2025-06-20', 'Available'), -- CopyID 28
('9780374533557', '2023-01-15', 16.99, 'Worn', 'E1-04', '2025-07-01', 'Available'), -- CopyID 29
('9781594633669', '2022-09-30', 13.99, 'Good', 'E2-08', '2025-06-25', 'Available'), -- CopyID 30
('9780141036144', '2021-11-05', 12.99, 'Good', 'F1-12', '2025-07-01', 'Available'), -- CopyID 31
('9780451524935', '2023-03-20', 9.99, 'Worn', 'F2-06', '2025-06-30', 'Available'), -- CopyID 32
('9780141439518', '2022-06-10', 8.99, 'Good', 'G1-03', '2025-07-01', 'Available'), -- CopyID 33
('9780547928227', '2021-04-15', 11.99, 'Good', 'G2-09', '2025-06-15', 'Available'), -- CopyID 34
('9780062316097', '2023-02-25', 15.99, 'Good', 'H1-07', '2025-07-01', 'Available'), -- CopyID 35
('9780307588371', '2022-08-05', 13.99, 'Worn', 'H2-11', '2025-06-20', 'Available'), -- CopyID 36
('9780441172719', '2021-07-10', 14.99, 'Good', 'I1-05', '2025-07-01', 'Available'), -- CopyID 37
('9781250080400', '2023-05-15', 10.99, 'Good', 'I2-10', '2025-06-25', 'Available'), -- CopyID 38
('9780399590504', '2022-10-20', 16.99, 'Good', 'J1-08', '2025-07-01', 'Available'), -- CopyID 39
('9780307474278', '2021-06-30', 12.99, 'Worn', 'J2-04', '2025-06-30', 'Available'); -- CopyID 40

-- Insert into Member (20 rows)
INSERT INTO Member (FirstName, LastName, Email, Phone, Address, JoinDate, SSN, MembershipType, IsActive) VALUES
('Alice', 'Johnson', 'alice.j@example.com', '+1-555-123-4567', '123 Main St', '2023-01-15', '123-45-6789', 'Student', 1),
('Bob', 'Smith', 'bob.s@example.com', '+1-555-234-5678', '456 Oak Ave', '2022-06-10', '234-56-7890', 'Premium', 1),
('Charlie', 'Brown', 'charlie.b@example.com', '+1-555-345-6789', '789 Pine Rd', '2021-03-22', '345-67-8901', 'Adult', 1),
('Diana', 'Davis', 'diana.d@example.com', '+1-555-456-7890', '101 Elm St', '2020-11-18', '456-78-9012', 'Student', 1),
('Eve', 'Wilson', 'eve.w@example.com', '+1-555-567-8901', '202 Maple Dr', '2023-04-05', '567-89-0123', 'Premium', 1),
('Frank', 'Taylor', 'frank.t@example.com', '+1-555-678-9012', '303 Birch Ln', '2022-09-30', '678-90-1234', 'Adult', 1),
('Grace', 'Anderson', 'grace.a@example.com', '+1-555-789-0123', '404 Cedar Ct', '2021-07-12', '789-01-2345', 'Student', 1),
('Hank', 'Martinez', 'hank.m@example.com', '+1-555-890-1234', '505 Spruce Ave', '2023-02-14', '890-12-3456', 'Premium', 1),
('Ivy', 'Garcia', 'ivy.g@example.com', '+1-555-901-2345', '606 Pine St', '2022-08-20', '901-23-4567', 'Adult', 1),
('Jack', 'Lopez', 'jack.l@example.com', '+1-555-012-3456', '707 Oak Rd', '2021-05-25', '012-34-5678', 'Student', 1),
('Kelly', 'Hernandez', 'kelly.h@example.com', '+1-555-123-4568', '808 Elm Dr', '2023-03-10', '123-45-6790', 'Premium', 1),
('Liam', 'Perez', 'liam.p@example.com', '+1-555-234-5679', '909 Pine Ln', '2022-12-05', '234-56-7901', 'Adult', 1),
('Mia', 'Sanchez', 'mia.s@example.com', '+1-555-345-6790', '1010 Oak St', '2021-10-15', '345-67-9012', 'Student', 1),
('Noah', 'Ramirez', 'noah.r@example.com', '+1-555-456-7901', '1111 Maple Ave', '2023-01-30', '456-78-9123', 'Premium', 1),
('Olivia', 'Torres', 'olivia.t@example.com', '+1-555-567-9012', '1212 Birch Rd', '2022-07-18', '567-89-1234', 'Adult', 1);
-- Insert into Staff (5 rows)
INSERT INTO Staff (MemberID, Position, HireDate, SalaryGrade, isManager) VALUES
(1, 'Librarian', '2023-01-15', 'Grade A', 0), (2, 'Assistant', '2022-06-10', 'Grade B', 0),
(3, 'Manager', '2021-03-22', 'Grade C', 1), (4, 'Clerk', '2020-11-18', 'Grade A', 0),
(5, 'Supervisor', '2023-04-05', 'Grade B', 0);

-- Insert into Reservation (10 rows)
INSERT INTO Reservation (MemberID, ISBN, RequestDate, Status) VALUES
(1, '9780141036144', '2025-07-15', 'Pending'), (2, '9780451524935', '2025-07-16', 'Approved'),
(3, '9780141439518', '2025-07-17', 'Pending'), (4, '9780547928227', '2025-07-18', 'Approved'),
(5, '9780062316097', '2025-07-19', 'Pending'), (6, '9780307588371', '2025-07-20', 'Approved'),
(7, '9780441172719', '2025-07-21', 'Pending'), (8, '9781250080400', '2025-07-22', 'Approved'),
(9, '9780399590504', '2025-07-23', 'Pending'), (10, '9780307474278', '2025-07-24', 'Approved');

-- Insert into Loan (10 rows)
INSERT INTO Loan (CopyID, MemberID, StaffID, CheckoutTime, ReturnDate, RenewalCount, LoanType, DueDate) VALUES
(1, 1, 1, '2025-07-15 10:00', '2025-08-15', 0, 'ShortLoan', '2025-07-29'), -- Student, 14 days
(2, 2, 2, '2025-07-16 11:00', '2025-08-16', 1, 'Standard', '2025-08-06'), -- Premium, 21 days
(3, 3, 3, '2025-07-17 12:00', '2025-08-17', 0, 'ShortLoan', '2025-07-31'), -- Adult, 14 days
(4, 4, 4, '2025-07-18 13:00', '2025-08-18', 0, 'ShortLoan', '2025-08-01'), -- Student, 14 days
(5, 5, 5, '2025-07-19 14:00', '2025-08-19', 1, 'Standard', '2025-08-09'), -- Premium, 21 days
(6, 6, 1, '2025-07-20 15:00', '2025-08-20', 0, 'ShortLoan', '2025-08-03'), -- Adult, 14 days
(7, 7, 2, '2025-07-21 16:00', '2025-08-21', 0, 'ShortLoan', '2025-08-04'), -- Student, 14 days
(8, 8, 3, '2025-07-22 17:00', '2025-08-22', 1, 'Standard', '2025-08-12'), -- Premium, 21 days
(9, 9, 4, '2025-07-23 18:00', '2025-08-23', 0, 'ShortLoan', '2025-08-06'), -- Adult, 14 days
(10, 10, 5, '2025-07-24 19:00', '2025-08-24', 0, 'ShortLoan', '2025-08-07'); -- Student, 14 days

-- Insert into Event (5 rows)
INSERT INTO Event (Name, Type, StartTime, EndTime, MaxAttendance, HostedBy) VALUES
('Book Fair', 'Community', '2025-08-01 10:00', '2025-08-01 16:00', 100, 3),
('Author Talk', 'Educational', '2025-08-05 14:00', '2025-08-05 16:00', 50, 3),
('Reading Session', 'Kids', '2025-08-10 11:00', '2025-08-10 12:30', 30, 1),
('Workshop', 'Skill', '2025-08-15 13:00', '2025-08-15 15:00', 40, 5),
('Library Tour', 'Community', '2025-08-20 10:00', '2025-08-20 11:30', 25, 2);

-- Insert into FinePayment (5 rows)
INSERT INTO FinePayment (MemberID, LoanID, StaffID, Amount, PaymentDate, Method, ReceiptNumber) VALUES
(1, 1, 1, 0.00, '2025-07-20', 'cash', 'FP001'), -- No fine, returned on time
(2, 2, 2, 0.00, '2025-07-21', 'visa', 'FP002'), -- No fine, returned on time
(3, 3, 3, 0.00, '2025-07-22', 'cash', 'FP003'), -- No fine, returned on time
(4, 4, 4, 0.00, '2025-07-23', 'visa', 'FP004'), -- No fine, returned on time
(5, 5, 5, 0.00, '2025-07-24', 'cash', 'FP005'); -- No fine, returned on time