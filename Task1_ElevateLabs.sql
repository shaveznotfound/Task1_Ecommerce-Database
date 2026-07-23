CREATE DATABASE MyDesiMartDB;
USE MyDesiMartDB;


-- Customers
CREATE TABLE Customers (
  CustomerID INT AUTO_INCREMENT PRIMARY KEY,
  FullName   VARCHAR(100) NOT NULL,
  Email      VARCHAR(100) UNIQUE NOT NULL,
  Phone      VARCHAR(10)  UNIQUE NOT NULL,
  -- NOTE: must store a bcrypt/argon2 HASH from the application layer,
  -- never plaintext. VARCHAR(255) already sized correctly for a hash.
  Password   VARCHAR(255) NOT NULL COMMENT 'Store a bcrypt/argon2 hash, never plaintext',
  CreatedAt  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT chk_customers_email  CHECK (Email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$'),
  CONSTRAINT chk_customers_phone  CHECK (Phone REGEXP '^[0-9]{10}$')
);

-- Categories
CREATE TABLE Categories (
  CategoryID   INT AUTO_INCREMENT PRIMARY KEY,
  CategoryName VARCHAR(50) UNIQUE NOT NULL,
  Description  VARCHAR(255)
);

-- Products
CREATE TABLE Products (
  ProductID   INT AUTO_INCREMENT PRIMARY KEY,
  CategoryID  INT NOT NULL,
  ProductName VARCHAR(150) NOT NULL,
  Brand       VARCHAR(100) NOT NULL,
  Description TEXT,
  CreatedAt   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_products_category FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ProductVariants
CREATE TABLE ProductVariants (
  VariantID   INT AUTO_INCREMENT PRIMARY KEY,
  ProductID   INT NOT NULL,
  VariantName VARCHAR(100) NOT NULL,
  Color       VARCHAR(30),
  Size        VARCHAR(20),
  Storage     VARCHAR(20),
  Price       DECIMAL(10,2) NOT NULL,
  Stock       INT DEFAULT 0,
  SKU         VARCHAR(40) UNIQUE,
  CONSTRAINT fk_variants_product FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT chk_variants_price CHECK (Price > 0),
  CONSTRAINT chk_variants_stock CHECK (Stock >= 0)
);

-- Addresses
CREATE TABLE Addresses (
  AddressID  INT AUTO_INCREMENT PRIMARY KEY,
  CustomerID INT NOT NULL,
  HouseNo    VARCHAR(20),
  Street     VARCHAR(150),
  City       VARCHAR(100),
  State      VARCHAR(100),
  Pincode    CHAR(6),
  CONSTRAINT fk_addresses_customer FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT chk_addresses_pincode CHECK (Pincode REGEXP '^[0-9]{6}$')
);

-- ShoppingCart
CREATE TABLE ShoppingCart (
  CartID     INT AUTO_INCREMENT PRIMARY KEY,
  CustomerID INT UNIQUE NOT NULL,
  CreatedAt  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_cart_customer FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
    ON DELETE CASCADE ON UPDATE CASCADE
);

-- CartItems
CREATE TABLE CartItems (
  CartItemID INT AUTO_INCREMENT PRIMARY KEY,
  CartID     INT NOT NULL,
  VariantID  INT NOT NULL,
  Quantity   INT DEFAULT 1,
  CONSTRAINT fk_cartitems_cart FOREIGN KEY (CartID) REFERENCES ShoppingCart(CartID)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_cartitems_variant FOREIGN KEY (VariantID) REFERENCES ProductVariants(VariantID)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT uq_cartitems_cart_variant UNIQUE (CartID, VariantID),
  CONSTRAINT chk_cartitems_qty CHECK (Quantity > 0)
);

-- Orders 
CREATE TABLE Orders (
  OrderID           INT AUTO_INCREMENT PRIMARY KEY,
  CustomerID        INT NOT NULL,
  ShippingAddressID INT NOT NULL,
  OrderDate         DATETIME DEFAULT CURRENT_TIMESTAMP,
  TotalAmount       DECIMAL(10,2) NOT NULL,
  OrderStatus       ENUM('Pending','Processing','Shipped','Delivered','Cancelled') DEFAULT 'Pending',
  CONSTRAINT fk_orders_customer FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_orders_address FOREIGN KEY (ShippingAddressID) REFERENCES Addresses(AddressID)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_orders_total CHECK (TotalAmount >= 0)
);

-- OrderItems
CREATE TABLE OrderItems (
  OrderItemID INT AUTO_INCREMENT PRIMARY KEY,
  OrderID     INT NOT NULL,
  VariantID   INT NOT NULL,
  Quantity    INT NOT NULL,
  UnitPrice   DECIMAL(10,2) NOT NULL,
  CONSTRAINT fk_orderitems_order FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_orderitems_variant FOREIGN KEY (VariantID) REFERENCES ProductVariants(VariantID)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_orderitems_qty CHECK (Quantity > 0),
  CONSTRAINT chk_orderitems_price CHECK (UnitPrice > 0)
);

-- Payments
CREATE TABLE Payments (
  PaymentID     INT AUTO_INCREMENT PRIMARY KEY,
  OrderID       INT UNIQUE NOT NULL,
  PaymentMethod ENUM('UPI','Debit Card','Credit Card','Net Banking','Cash on Delivery') NOT NULL,
  PaymentStatus ENUM('Pending','Completed','Failed','Refunded') DEFAULT 'Pending',
  PaymentDate   DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_payments_order FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
    ON DELETE CASCADE ON UPDATE CASCADE
);

-- Data
INSERT INTO Customers (FullName,Email,Phone,Password) VALUES
('Aarav Sharma','user1@bharatbazaar.com','9000000001','pass1'),
('Priya Verma','user2@bharatbazaar.com','9000000002','pass2'),
('Mohammed Ali','user3@bharatbazaar.com','9000000003','pass3'),
('Ananya Gupta','user4@bharatbazaar.com','9000000004','pass4'),
('Rohan Singh','user5@bharatbazaar.com','9000000005','pass5'),
('Neha Kapoor','user6@bharatbazaar.com','9000000006','pass6'),
('Vikram Mehta','user7@bharatbazaar.com','9000000007','pass7'),
('Sneha Iyer','user8@bharatbazaar.com','9000000008','pass8'),
('Karan Patel','user9@bharatbazaar.com','9000000009','pass9'),
('Aisha Khan','user10@bharatbazaar.com','9000000010','pass10');

INSERT INTO Categories (CategoryName,Description) VALUES
('Electronics','Electronic gadgets'),
('Fashion','Clothing'),
('Home & Kitchen','Home'),
('Beauty','Beauty'),
('Sports','Sports'),
('Grocery','Daily'),
('Books','Books'),
('Toys','Toys'),
('Furniture','Furniture'),
('Automotive','Vehicle');

INSERT INTO Products (CategoryID,ProductName,Brand,Description) VALUES
(1,'Product 1','Samsung','Description 1'),
(2,'Product 2','Apple','Description 2'),
(3,'Product 3','OnePlus','Description 3'),
(4,'Product 4','Redmi','Description 4'),
(5,'Product 5','HP','Description 5'),
(6,'Product 6','Dell','Description 6'),
(7,'Product 7','Sony','Description 7'),
(8,'Product 8','Boat','Description 8'),
(9,'Product 9','Nike','Description 9'),
(10,'Product 10','Adidas','Description 10'),
(1,'Product 11','Puma','Description 11'),
(2,'Product 12','Levis','Description 12'),
(3,'Product 13','Prestige','Description 13'),
(4,'Product 14','Philips','Description 14'),
(5,'Product 15','Milton','Description 15'),
(6,'Product 16','Cello','Description 16'),
(7,'Product 17','SG','Description 17'),
(8,'Product 18','Nivia','Description 18'),
(9,'Product 19','Yonex','Description 19'),
(10,'Product 20','Boldfit','Description 20'),
(1,'Product 21','Samsung','Description 21'),
(2,'Product 22','Apple','Description 22'),
(3,'Product 23','OnePlus','Description 23'),
(4,'Product 24','Redmi','Description 24'),
(5,'Product 25','HP','Description 25'),
(6,'Product 26','Dell','Description 26'),
(7,'Product 27','Sony','Description 27'),
(8,'Product 28','Boat','Description 28'),
(9,'Product 29','Nike','Description 29'),
(10,'Product 30','Adidas','Description 30'),
(1,'Product 31','Puma','Description 31'),
(2,'Product 32','Levis','Description 32'),
(3,'Product 33','Prestige','Description 33'),
(4,'Product 34','Philips','Description 34'),
(5,'Product 35','Milton','Description 35'),
(6,'Product 36','Cello','Description 36'),
(7,'Product 37','SG','Description 37'),
(8,'Product 38','Nivia','Description 38'),
(9,'Product 39','Yonex','Description 39'),
(10,'Product 40','Boldfit','Description 40');

INSERT INTO ProductVariants (ProductID,VariantName,Color,Size,Storage,Price,Stock,SKU) VALUES
(1,'128GB Black','Black',NULL,'128GB',5499,50,'SKU0001'),
(1,'256GB Blue','Blue',NULL,'256GB',6499,50,'SKU0002'),
(2,'128GB Black','Black',NULL,'128GB',5999,50,'SKU0003'),
(2,'256GB Blue','Blue',NULL,'256GB',6999,50,'SKU0004'),
(3,'128GB Black','Black',NULL,'128GB',6499,50,'SKU0005'),
(3,'256GB Blue','Blue',NULL,'256GB',7499,50,'SKU0006'),
(4,'128GB Black','Black',NULL,'128GB',6999,50,'SKU0007'),
(4,'256GB Blue','Blue',NULL,'256GB',7999,50,'SKU0008'),
(5,'128GB Black','Black',NULL,'128GB',7499,50,'SKU0009'),
(5,'256GB Blue','Blue',NULL,'256GB',8499,50,'SKU0010'),
(6,'128GB Black','Black',NULL,'128GB',7999,50,'SKU0011'),
(6,'256GB Blue','Blue',NULL,'256GB',8999,50,'SKU0012'),
(7,'128GB Black','Black',NULL,'128GB',8499,50,'SKU0013'),
(7,'256GB Blue','Blue',NULL,'256GB',9499,50,'SKU0014'),
(8,'128GB Black','Black',NULL,'128GB',8999,50,'SKU0015'),
(8,'256GB Blue','Blue',NULL,'256GB',9999,50,'SKU0016'),
(9,'128GB Black','Black',NULL,'128GB',9499,50,'SKU0017'),
(9,'256GB Blue','Blue',NULL,'256GB',10499,50,'SKU0018'),
(10,'128GB Black','Black',NULL,'128GB',9999,50,'SKU0019'),
(10,'256GB Blue','Blue',NULL,'256GB',10999,50,'SKU0020'),
(11,'128GB Black','Black',NULL,'128GB',10499,50,'SKU0021'),
(11,'256GB Blue','Blue',NULL,'256GB',11499,50,'SKU0022'),
(12,'128GB Black','Black',NULL,'128GB',10999,50,'SKU0023'),
(12,'256GB Blue','Blue',NULL,'256GB',11999,50,'SKU0024'),
(13,'128GB Black','Black',NULL,'128GB',11499,50,'SKU0025'),
(13,'256GB Blue','Blue',NULL,'256GB',12499,50,'SKU0026'),
(14,'128GB Black','Black',NULL,'128GB',11999,50,'SKU0027'),
(14,'256GB Blue','Blue',NULL,'256GB',12999,50,'SKU0028'),
(15,'128GB Black','Black',NULL,'128GB',12499,50,'SKU0029'),
(15,'256GB Blue','Blue',NULL,'256GB',13499,50,'SKU0030'),
(16,'128GB Black','Black',NULL,'128GB',12999,50,'SKU0031'),
(16,'256GB Blue','Blue',NULL,'256GB',13999,50,'SKU0032'),
(17,'128GB Black','Black',NULL,'128GB',13499,50,'SKU0033'),
(17,'256GB Blue','Blue',NULL,'256GB',14499,50,'SKU0034'),
(18,'128GB Black','Black',NULL,'128GB',13999,50,'SKU0035'),
(18,'256GB Blue','Blue',NULL,'256GB',14999,50,'SKU0036'),
(19,'128GB Black','Black',NULL,'128GB',14499,50,'SKU0037'),
(19,'256GB Blue','Blue',NULL,'256GB',15499,50,'SKU0038'),
(20,'128GB Black','Black',NULL,'128GB',14999,50,'SKU0039'),
(20,'256GB Blue','Blue',NULL,'256GB',15999,50,'SKU0040'),
(21,'128GB Black','Black',NULL,'128GB',15499,50,'SKU0041'),
(21,'256GB Blue','Blue',NULL,'256GB',16499,50,'SKU0042'),
(22,'128GB Black','Black',NULL,'128GB',15999,50,'SKU0043'),
(22,'256GB Blue','Blue',NULL,'256GB',16999,50,'SKU0044'),
(23,'128GB Black','Black',NULL,'128GB',16499,50,'SKU0045'),
(23,'256GB Blue','Blue',NULL,'256GB',17499,50,'SKU0046'),
(24,'128GB Black','Black',NULL,'128GB',16999,50,'SKU0047'),
(24,'256GB Blue','Blue',NULL,'256GB',17999,50,'SKU0048'),
(25,'128GB Black','Black',NULL,'128GB',17499,50,'SKU0049'),
(25,'256GB Blue','Blue',NULL,'256GB',18499,50,'SKU0050'),
(26,'128GB Black','Black',NULL,'128GB',17999,50,'SKU0051'),
(26,'256GB Blue','Blue',NULL,'256GB',18999,50,'SKU0052'),
(27,'128GB Black','Black',NULL,'128GB',18499,50,'SKU0053'),
(27,'256GB Blue','Blue',NULL,'256GB',19499,50,'SKU0054'),
(28,'128GB Black','Black',NULL,'128GB',18999,50,'SKU0055'),
(28,'256GB Blue','Blue',NULL,'256GB',19999,50,'SKU0056'),
(29,'128GB Black','Black',NULL,'128GB',19499,50,'SKU0057'),
(29,'256GB Blue','Blue',NULL,'256GB',20499,50,'SKU0058'),
(30,'128GB Black','Black',NULL,'128GB',19999,50,'SKU0059'),
(30,'256GB Blue','Blue',NULL,'256GB',20999,50,'SKU0060'),
(31,'128GB Black','Black',NULL,'128GB',20499,50,'SKU0061'),
(31,'256GB Blue','Blue',NULL,'256GB',21499,50,'SKU0062'),
(32,'128GB Black','Black',NULL,'128GB',20999,50,'SKU0063'),
(32,'256GB Blue','Blue',NULL,'256GB',21999,50,'SKU0064'),
(33,'128GB Black','Black',NULL,'128GB',21499,50,'SKU0065'),
(33,'256GB Blue','Blue',NULL,'256GB',22499,50,'SKU0066'),
(34,'128GB Black','Black',NULL,'128GB',21999,50,'SKU0067'),
(34,'256GB Blue','Blue',NULL,'256GB',22999,50,'SKU0068'),
(35,'128GB Black','Black',NULL,'128GB',22499,50,'SKU0069'),
(35,'256GB Blue','Blue',NULL,'256GB',23499,50,'SKU0070'),
(36,'128GB Black','Black',NULL,'128GB',22999,50,'SKU0071'),
(36,'256GB Blue','Blue',NULL,'256GB',23999,50,'SKU0072'),
(37,'128GB Black','Black',NULL,'128GB',23499,50,'SKU0073'),
(37,'256GB Blue','Blue',NULL,'256GB',24499,50,'SKU0074'),
(38,'128GB Black','Black',NULL,'128GB',23999,50,'SKU0075'),
(38,'256GB Blue','Blue',NULL,'256GB',24999,50,'SKU0076'),
(39,'128GB Black','Black',NULL,'128GB',24499,50,'SKU0077'),
(39,'256GB Blue','Blue',NULL,'256GB',25499,50,'SKU0078'),
(40,'128GB Black','Black',NULL,'128GB',24999,50,'SKU0079'),
(40,'256GB Blue','Blue',NULL,'256GB',25999,50,'SKU0080');

INSERT INTO Addresses (CustomerID,HouseNo,Street,City,State,Pincode) VALUES
(1,'H-1','Street 1','Noida','Uttar Pradesh','201301'),
(2,'H-2','Street 2','Delhi','Delhi','110001'),
(3,'H-3','Street 3','Gurugram','Haryana','122001'),
(4,'H-4','Street 4','Pune','Maharashtra','411001'),
(5,'H-5','Street 5','Bengaluru','Karnataka','560001'),
(6,'H-6','Street 6','Noida','Uttar Pradesh','201301'),
(7,'H-7','Street 7','Delhi','Delhi','110001'),
(8,'H-8','Street 8','Gurugram','Haryana','122001'),
(9,'H-9','Street 9','Pune','Maharashtra','411001'),
(10,'H-10','Street 10','Bengaluru','Karnataka','560001'),
(1,'H-11','Street 11','Noida','Uttar Pradesh','201301'),
(2,'H-12','Street 12','Delhi','Delhi','110001'),
(3,'H-13','Street 13','Gurugram','Haryana','122001'),
(4,'H-14','Street 14','Pune','Maharashtra','411001'),
(5,'H-15','Street 15','Bengaluru','Karnataka','560001');

INSERT INTO ShoppingCart (CustomerID) VALUES
(1),(2),(3),(4),(5),(6),(7),(8),(9),(10);

INSERT INTO CartItems (CartID,VariantID,Quantity) VALUES
(1,1,1),(2,2,2),(3,3,3),(4,4,1),(5,5,2),
(6,6,3),(7,7,1),(8,8,2),(9,9,3),(10,10,1),
(1,11,2),(2,12,3),(3,13,1),(4,14,2),(5,15,3),
(6,16,1),(7,17,2),(8,18,3),(9,19,1),(10,20,2),
(1,21,3),(2,22,1),(3,23,2),(4,24,3),(5,25,1),
(6,26,2),(7,27,3),(8,28,1),(9,29,2),(10,30,3),
(1,31,1),(2,32,2),(3,33,3),(4,34,1),(5,35,2);


INSERT INTO Orders (CustomerID,ShippingAddressID,TotalAmount,OrderStatus) VALUES
(1,1,31497,'Pending'),
(2,2,68994,'Processing'),
(3,3,32997,'Shipped'),
(4,4,71994,'Delivered'),
(5,5,34497,'Pending'),
(6,6,39996,'Processing'),
(7,7,18998,'Shipped'),
(8,8,41996,'Delivered'),
(9,9,19998,'Pending'),
(10,10,43996,'Processing'),
(1,11,20998,'Shipped'),
(2,12,45996,'Delivered'),
(3,13,21998,'Pending'),
(4,14,47996,'Processing'),
(5,15,22998,'Shipped'),
(6,6,49996,'Delivered'),
(7,7,23998,'Pending'),
(8,8,51996,'Processing'),
(9,9,24998,'Shipped'),
(10,10,53996,'Delivered');

INSERT INTO OrderItems (OrderID,VariantID,Quantity,UnitPrice) VALUES
(1,1,1,5499),
(2,2,2,6499),
(3,3,1,5999),
(4,4,2,6999),
(5,5,1,6499),
(6,6,2,7499),
(7,7,1,6999),
(8,8,2,7999),
(9,9,1,7499),
(10,10,2,8499),
(11,11,1,7999),
(12,12,2,8999),
(13,13,1,8499),
(14,14,2,9499),
(15,15,1,8999),
(16,16,2,9999),
(17,17,1,9499),
(18,18,2,10499),
(19,19,1,9999),
(20,20,2,10999),
(1,21,1,10499),
(2,22,2,11499),
(3,23,1,10999),
(4,24,2,11999),
(5,25,1,11499),
(6,26,2,12499),
(7,27,1,11999),
(8,28,2,12999),
(9,29,1,12499),
(10,30,2,13499),
(11,31,1,12999),
(12,32,2,13999),
(13,33,1,13499),
(14,34,2,14499),
(15,35,1,13999),
(16,36,2,14999),
(17,37,1,14499),
(18,38,2,15499),
(19,39,1,14999),
(20,40,2,15999),
(1,41,1,15499),
(2,42,2,16499),
(3,43,1,15999),
(4,44,2,16999),
(5,45,1,16499);

INSERT INTO Payments (OrderID,PaymentMethod,PaymentStatus) VALUES
(1,'UPI','Completed'),
(2,'Debit Card','Completed'),
(3,'Credit Card','Completed'),
(4,'Net Banking','Completed'),
(5,'Cash on Delivery','Pending'),
(6,'UPI','Completed'),
(7,'Debit Card','Completed'),
(8,'Credit Card','Completed'),
(9,'Net Banking','Completed'),
(10,'Cash on Delivery','Pending'),
(11,'UPI','Completed'),
(12,'Debit Card','Completed'),
(13,'Credit Card','Completed'),
(14,'Net Banking','Completed'),
(15,'Cash on Delivery','Pending'),
(16,'UPI','Completed'),
(17,'Debit Card','Completed'),
(18,'Credit Card','Completed'),
(19,'Net Banking','Completed'),
(20,'Cash on Delivery','Completed');

Select * from customers;
Select * from Categories;
Select * from Products;
Select * from ProductVariants;
Select * from ShoppingCart;
Select * from CartItems;
Select * from Orders;
Select * from OrderItems;
Select * from Payments;
Select * from Addresses;
