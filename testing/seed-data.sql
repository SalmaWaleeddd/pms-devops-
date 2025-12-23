-- PMS Sample/Test Data
-- This script populates the databases with sample data for testing

USE PMS_Site;
GO

-- Insert sample parking sites
INSERT INTO Sites (Id, Path, NameEn, NameAr, PricePerHour, IntegrationCode, NumberOfSolts, ParentId, IsLeaf)
VALUES
    (NEWID(), '/root', 'Downtown Parking', 'موقف وسط المدينة', 15.00, 'DT-001', 50, NULL, 0),
    (NEWID(), '/root/zone1', 'Zone A - Ground Floor', 'المنطقة أ - الطابق الأرضي', 10.00, 'ZA-GF', 25, NULL, 1),
    (NEWID(), '/root/zone2', 'Zone B - Upper Level', 'المنطقة ب - المستوى العلوي', 12.00, 'ZB-UL', 30, NULL, 1),
    (NEWID(), '/airport', 'Airport Long-Term', 'موقف المطار طويل الأمد', 8.00, 'AP-LT', 100, NULL, 1),
    (NEWID(), '/mall', 'Shopping Mall Parking', 'موقف المركز التجاري', 5.00, 'ML-001', 200, NULL, 1);
GO

PRINT 'Sample sites inserted into PMS_Site database';
GO

-- You can add more sample data for bookings and invoices if needed
-- USE PMS_Booking;
-- INSERT INTO Tickets...

-- USE PMS_Invoice;
-- INSERT INTO Invoices...
