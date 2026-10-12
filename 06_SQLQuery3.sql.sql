-- 07_TestQuery.sql
-- Test Query ระบบเช่าอุปกรณ์จัดงาน

USE EventRentalDB;
GO

-- ข้อ 1 แสดงชื่อคนเช่า เบอร์ เช่าอะไร เช่ากี่อัน เช่าวันไหน และราคาเท่าไหร่
SELECT
    c.CustomerName,
    c.Phone,
    r.StartDate,
    r.DueDate,
    e.EquipmentName,
    rd.Quantity,
    rd.UnitPrice,
    rd.Quantity * rd.UnitPrice AS SubTotal
FROM RentalOrder AS r
    JOIN Customer AS c ON r.CustomerID = c.CustomerID
    JOIN RentalDetail AS rd ON r.RentalID = rd.RentalID
    JOIN Equipment AS e ON rd.EquipmentID = e.EquipmentID
ORDER BY r.RentalID;

-- ข้อ 2 แสดงยอดเงินรวมของแต่ละใบเช่า
SELECT
    r.RentalID,
    c.CustomerName,
    SUM(rd.Quantity * rd.UnitPrice) AS TotalAmount
FROM RentalOrder AS r
    JOIN Customer AS c ON r.CustomerID = c.CustomerID
    JOIN RentalDetail AS rd ON r.RentalID = rd.RentalID
GROUP BY r.RentalID, c.CustomerName
ORDER BY r.RentalID;

-- ข้อ 3 แสดงรายการเช่าเฉพาะลูกค้าชื่อสมชาย
SELECT
    r.RentalID,
    c.CustomerName,
    e.EquipmentName,
    rd.Quantity,
    r.StartDate,
    r.DueDate
FROM RentalOrder AS r
    JOIN Customer AS c ON r.CustomerID = c.CustomerID
    JOIN RentalDetail AS rd ON r.RentalID = rd.RentalID
    JOIN Equipment AS e ON rd.EquipmentID = e.EquipmentID
WHERE c.CustomerName LIKE N'%สมชาย%';

-- ข้อ 4 แสดงว่าใครคืนอุปกรณ์อะไร คืนกี่อัน และสภาพอุปกรณ์เป็นอย่างไร
SELECT
    rr.ReturnID,
    c.CustomerName,
    rr.ReturnDate,
    e.EquipmentName,
    ret.ReturnQuantity,
    ret.EquipmentCondition
FROM ReturnRecord AS rr
    JOIN RentalOrder AS r ON rr.RentalID = r.RentalID
    JOIN Customer AS c ON r.CustomerID = c.CustomerID
    JOIN ReturnDetail AS ret ON rr.ReturnID = ret.ReturnID
    JOIN Equipment AS e ON ret.EquipmentID = e.EquipmentID
ORDER BY rr.ReturnID;

-- ข้อ 5 แสดงจำนวนที่เช่า คืนแล้ว และยังไม่คืน
SELECT
    rd.RentalID,
    c.CustomerName,
    e.EquipmentName,
    rd.Quantity AS RentedQty,
    ISNULL(SUM(ret.ReturnQuantity), 0) AS ReturnedQty,
    rd.Quantity - ISNULL(SUM(ret.ReturnQuantity), 0) AS NotReturnedQty
FROM RentalDetail AS rd
    JOIN RentalOrder AS r ON rd.RentalID = r.RentalID
    JOIN Customer AS c ON r.CustomerID = c.CustomerID
    JOIN Equipment AS e ON rd.EquipmentID = e.EquipmentID
    LEFT JOIN ReturnRecord AS rr ON rd.RentalID = rr.RentalID
    LEFT JOIN ReturnDetail AS ret ON rr.ReturnID = ret.ReturnID
        AND rd.EquipmentID = ret.EquipmentID
GROUP BY rd.RentalID, c.CustomerName, e.EquipmentName, rd.Quantity
ORDER BY rd.RentalID;

-- ข้อ 6 แสดงจำนวนสต็อกทั้งหมดและจำนวนคงเหลือของอุปกรณ์
SELECT
    EquipmentName,
    Category,
    StockQty,
    AvailableQty,
    RentalPricePerDay,
    Status
FROM Equipment
ORDER BY EquipmentID;

-- ข้อ 7 แสดงอุปกรณ์ที่ถูกเช่ามากที่สุด
SELECT
    e.EquipmentName,
    SUM(rd.Quantity) AS TotalRented
FROM Equipment AS e
    JOIN RentalDetail AS rd ON e.EquipmentID = rd.EquipmentID
GROUP BY e.EquipmentName
ORDER BY TotalRented DESC;

-- ข้อ 8 แสดงลูกค้าที่มียอดเช่ารวมมากที่สุด
SELECT
    c.CustomerName,
    SUM(rd.Quantity * rd.UnitPrice) AS TotalRentalAmount
FROM Customer AS c
    JOIN RentalOrder AS r ON c.CustomerID = r.CustomerID
    JOIN RentalDetail AS rd ON r.RentalID = rd.RentalID
GROUP BY c.CustomerName
ORDER BY TotalRentalAmount DESC;
GO