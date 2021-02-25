--*************************************************************************--
-- Title: Assignment06
-- Author: Nariman_Tehrani
-- Desc: This file demonstrates how to use Views
-- Change Log: 2021-02-20, Nariman_Tehrani, Created file and database
-- Change Log: 2021-02-20, Nariman_Tehrani, Created tables
-- Change Log: 2021-02-20, Nariman_Tehrani, Added constraints
-- Change Log: 2021-02-20, Nariman_Tehrani, Added data
-- Change Log: 2021-02-20, Nariman_Tehrani, Created Views
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_Nariman_Tehrani')
	 Begin 
	  Alter Database [Assignment06DB_Nariman_Tehrani] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_Nariman_Tehrani;
	 End
	Create Database Assignment06DB_Nariman_Tehrani;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_Nariman_Tehrani;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
/*
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'
*/
-- Question 1 (5 pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

go
Create 
	View vCategories
	WITH SCHEMABINDING
		AS
		Select
			CategoryID = Categories.CategoryID,
			CategoryName = Categories.CategoryName
		From
			dbo.Categories;
go
Select * from vCategories
go


go
Create 
	View vProducts
	WITH SCHEMABINDING
		AS
		Select
			ProductID = Products.ProductID,
			ProductName = Products.ProductName,
			CategoryID = Products.CategoryID,
			UnitPrice = Products.UnitPrice
		From
			dbo.Products;
go
Select * from vProducts
go

go
Create 
	View vEmployees
	WITH SCHEMABINDING
		AS
		Select
			EmployeeID = Employees.EmployeeID,
			EmployeeFirstName = Employees.EmployeeFirstName,
			EmployeeLastName = Employees.EmployeeLastName,
			ManagerID = Employees.ManagerID
		From
			dbo.Employees;
go
Select * from vEmployees
go

go
Create 
	View vInventories
	WITH SCHEMABINDING
		AS
		Select
			InventoryID = Inventories.InventoryID,
			InventoryDate = Inventories.InventoryDate,
			EmployeeID = Inventories.EmployeeID,
			ProductID = Inventories.ProductID,
			Count = Inventories.Count
		From
			dbo.Inventories;
go
Select * from vInventories
go

-- Question 2 (5 pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

go
Deny Select on Categories to Public
Grant Select on vCategories to Public
go


go
Deny Select on Products to Public
Grant Select on vProducts to Public
go


go
Deny Select on Employees to Public
Grant Select on vEmployees to Public
go


go
Deny Select on Inventories to Public
Grant Select on vInventories to Public
go

-- Question 3 (10 pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

go
Create 
	View vCatName_ProdName_Price
	AS
		Select 
			TOP 1000000
			CategoryName = vCategories.CategoryName,
			ProductName = vProducts.ProductName,
			UnitPrice = vProducts.UnitPrice
		From
			vCategories Left Join vProducts on vCategories.CategoryID = vProducts.CategoryID
		Order By 1,2
go
Select * 
from vCatName_ProdName_Price
go

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00

-- Question 4 (10 pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

go
Create
	View vProdName_InvDate_InvCount
	AS
		Select 
			TOP 1000000
			ProductName = vProducts.ProductName,
			InventoryDate = vInventories.InventoryDate,
			InventoryCount = vInventories.Count
		From
			vProducts Left Join vInventories on vProducts.ProductID = vInventories.ProductID
		Order by 1,2,3
go
Select * 
From vProdName_InvDate_InvCount
go

-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83

-- Question 5 (10 pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

go
Create
	View vInvDate_EMPName
	AS
		Select
			TOP 1000000
			InventoryDate = vInventories.InventoryDate,
			EmployeeName = CONCAT(vEmployees.EmployeeFirstName, ' ', vEmployees.EmployeeLastName)
		From
			vInventories Left Join vEmployees on vInventories.EmployeeID = vEmployees.EmployeeID
		Group by 
			vInventories.InventoryDate,
			CONCAT(vEmployees.EmployeeFirstName, ' ', vEmployees.EmployeeLastName)
		Order by 1
go
Select * 
From vInvDate_EMPName
go

-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth

-- Question 6 (10 pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

go
Create
	View vCat_Prod_InvDate_Count
	AS
		Select
			TOP 1000000
			Categories = vCategories.CategoryName,
			Products = vProducts.ProductName,
			InventoryDate = vInventories.InventoryDate,
			Count = vInventories.Count
		From
			vCategories Left Join vProducts on vCategories.CategoryID = vProducts.CategoryID
						Left Join vInventories on vProducts.ProductID = vInventories.ProductID
		Order by 1,2,3,4
go
Select * 
From vCat_Prod_InvDate_Count
go

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54

-- Question 7 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

go
Create
	View vCat_Prod_InvDate_Count_EMP
	AS
		Select 
			TOP 1000000
			Categories = vCategories.CategoryName,
			Products = vProducts.ProductName,
			InventoryDate = vInventories.InventoryDate,
			Count = vInventories.Count,
			Employee = CONCAT(vEmployees.EmployeeFirstName, ' ', vEmployees.EmployeeLastName)
		From
			vCategories Left Join vProducts on vCategories.CategoryID = vProducts.CategoryID
						Left Join vInventories on vProducts.ProductID = vInventories.ProductID
						Left Join vEmployees on vInventories.EmployeeID = vEmployees.EmployeeID
		Order by 3,1,2,5
go
Select * 
From vCat_Prod_InvDate_Count_EMP
go

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan

-- Question 8 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

go
Create
	View vChai_Chang_Cat_InvDate_Count_EMP
	AS
		Select 
			Categories = vCategories.CategoryName,
			Products = vProducts.ProductName,
			InventoryDate = vInventories.InventoryDate,
			Count = vInventories.Count,
			Employee = CONCAT(vEmployees.EmployeeFirstName, ' ', vEmployees.EmployeeLastName)
		From
			vCategories Left Join vProducts on vCategories.CategoryID = vProducts.CategoryID
						Left Join vInventories on vProducts.ProductID = vInventories.ProductID
						Left Join vEmployees on vInventories.EmployeeID = vEmployees.EmployeeID
		Where 
			vProducts.ProductName In ('Chai', 'Chang')
go
Select * 
From vChai_Chang_Cat_InvDate_Count_EMP
go

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King

-- Question 9 (10 pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

go
Create
	View vEMP_MGR
	AS
		Select
			TOP 1000000
			Manager = CONCAT(a.EmployeeFirstName, ' ', a.EmployeeLastName),
			Employee = CONCAT(b.EmployeeFirstName, ' ', b.EmployeeLastName)
		From
			vEmployees a, vEmployees b
		Where
			a.EmployeeID = b.ManagerID
		Order by 1
go
Select *
From vEMP_MGR
go

-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan

-- Question 10 (10 pts): How can you create one view to show all the data from all four 
-- BASIC Views?

go
Create
	View vCat_Prod_Inv_EMP_ALL
	AS
		Select 
			CategoryID = vCategories.CategoryID,
			CategoryName = vCategories.CategoryName,
			ProductID = vProducts.ProductID,
			ProductName = vProducts.ProductName,
			UnitPrice = vProducts.UnitPrice,
			EmployeeID = vEmployees.EmployeeID,
			EmployeeFirstName = vEmployees.EmployeeFirstName,
			EmployeeLastName = vEmployees.EmployeeLastName,
			ManagerID = vEmployees.ManagerID,
			InventoryID = vInventories.InventoryID,
			InventoryDate = vInventories.InventoryDate,
			Count = vInventories.Count	   			 		  		  		 	   
		From
			vCategories Left Join vProducts on vCategories.CategoryID = vProducts.CategoryID
						Left Join vInventories on vProducts.ProductID = vInventories.ProductID
						Left Join vEmployees on vInventories.EmployeeID = vEmployees.EmployeeID
go
Select * 
From vCat_Prod_Inv_EMP_ALL
go

-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan

-- Test your Views (NOTE: You must change the names to match yours as needed!)
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vCatName_ProdName_Price]
Select * From [dbo].[vProdName_InvDate_InvCount]
Select * From [dbo].[vInvDate_EMPName]
Select * From [dbo].[vCat_Prod_InvDate_Count]
Select * From [dbo].[vCat_Prod_InvDate_Count_EMP]
Select * From [dbo].[vChai_Chang_Cat_InvDate_Count_EMP]
Select * From [dbo].[vEMP_MGR]
Select * From [dbo].[vCat_Prod_Inv_EMP_ALL]
/***************************************************************************************/