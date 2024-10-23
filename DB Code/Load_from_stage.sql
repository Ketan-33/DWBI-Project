CREATE OR REPLACE FILE FORMAT CSV_SOURCE_FILE_FORMAT
TYPE = 'CSV'
SKIP_HEADER = 1
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
DATE_FORMAT = 'YYYY-MM-DD';

CREATE OR REPLACE STAGE STAGING_AREA;


COPY INTO DimLoyaltyProgram
from @DWBI.DWBI_SCHEMA.STAGING_AREA/DimLoyaltyInfo/DimLoyaltyInfo.csv
FILE_FORMAT = (FORMAT_NAME = 'CSV_SOURCE_FILE_FORMAT');

select * from DimLoyaltyProgram;

COPY INTO DimCustomer
FROM @DWBI.DWBI_SCHEMA.staging_area/DimCusomerData/DimCustomerData.csv
FILE_FORMAT = (FORMAT_NAME = 'CSV_SOURCE_FILE_FORMAT')
ON_ERROR = 'CONTINUE';

LIST @DWBI.DWBI_SCHEMA.STAGING_AREA;

select * from DimCustomer;

COPY INTO DimProduct(ProductName, Category, Brand, UnitPrice)
from @DWBI.DWBI_SCHEMA.STAGING_AREA/DimProductData/DimProductData.csv
FILE_FORMAT = (FORMAT_NAME = 'CSV_SOURCE_FILE_FORMAT');

select * from DimProduct;

COPY INTO DimDate(DateID, Date, DayOfWeek, Month, Quarter, Year, IsWeekend)
FROM @DWBI.DWBI_SCHEMA.STAGING_AREA/DimDate/DimDate.csv
FILE_FORMAT = (FORMAT_NAME = 'CSV_SOURCE_FILE_FORMAT');

SELECT * FROM DimDate;

COPY INTO DimStore(StoreName, StoreType, StoreOpeningDate, Address, City, State, Country, Region, ManagerName)
FROM @DWBI.DWBI_SCHEMA.STAGING_AREA/DimStoreData/DimStoreData.csv
FILE_FORMAT = (FORMAT_NAME = 'CSV_SOURCE_FILE_FORMAT');

SELECT * FROM DimStore;

COPY INTO FactOrders(DateID, CustomerID, ProductID, StoreID, QuantityOrdered, OrderAmount, DiscountAmount, ShippingCost, TotalAmount)
FROM @DWBI.DWBI_SCHEMA.STAGING_AREA/factorders/factorders.csv
FILE_FORMAT = (FORMAT_NAME = 'CSV_SOURCE_FILE_FORMAT');

SELECT * FROM FactOrders LIMIT 100;

COPY INTO FactOrders(DateID, CustomerID, ProductID, StoreID, QuantityOrdered, OrderAmount, DiscountAmount, ShippingCost, TotalAmount)
FROM @DWBI.DWBI_SCHEMA.STAGING_AREA/Landing_Directory/
FILE_FORMAT = (FORMAT_NAME = 'CSV_SOURCE_FILE_FORMAT');

SELECT * FROM FactOrders LIMIT 100;



CREATE OR REPLACE USER PowerBI_User
PASSWORD = 'PowerBI_User'
LOGIN_NAME = 'PowerBI User'
DEFAULT_ROLE = 'ACCOUNTADMIN'
DEFAULT_WAREHOUSE = 'COMPUTE_WH'
MUST_CHANGE_PASSWORD = TRUE;

-- grant it accountadmin access
GRANT ROLE accountadmin TO USER PowerBI_User;
