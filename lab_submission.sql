-- (i) A Procedure called PROC_LAB5
DELIMITER //

CREATE PROCEDURE PROC_LAB5(IN p_year INT)
BEGIN
    SELECT 
        c.customerNumber,
        c.customerName,
        COUNT(o.orderNumber) AS total_orders,
        SUM(od.quantityOrdered * od.priceEach) AS total_sales,
        AVG(od.quantityOrdered * od.priceEach) AS avg_order_value
    FROM 
        customers c
    JOIN orders o ON c.customerNumber = o.customerNumber
    JOIN orderdetails od ON o.orderNumber = od.orderNumber
    WHERE 
        YEAR(o.orderDate) = p_year
    GROUP BY 
        c.customerNumber, c.customerName
    ORDER BY 
        total_sales DESC;
END //

DELIMITER ;

-- CALL PROC_LAB5(2004); to execute the procedure

-- (ii) A Function called FUNC_LAB5
DELIMITER //

CREATE FUNCTION FUNC_LAB5(p_productLine VARCHAR(50), p_year INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total_revenue DECIMAL(10,2);
    
    SELECT 
        SUM(od.quantityOrdered * od.priceEach) INTO total_revenue
    FROM 
        products p
    JOIN orderdetails od ON p.productCode = od.productCode
    JOIN orders o ON od.orderNumber = o.orderNumber
    WHERE 
        p.productLine = CONVERT(p_productLine USING utf8mb4) COLLATE utf8mb4_general_ci
        AND YEAR(o.orderDate) = p_year;
    
    RETURN IFNULL(total_revenue, 0);
END //

DELIMITER ;

-- SELECT FUNC_LAB5('Classic Cars', 2004) AS classic_cars_revenue; to execute the function
-- (iii) A View called VIEW_LAB5
CREATE VIEW VIEW_LAB5 AS
SELECT 
    p.productCode,
    p.productName,
    p.productLine,
    SUM(od.quantityOrdered) AS total_quantity_sold,
    SUM(od.quantityOrdered * od.priceEach) AS total_sales,
    CONCAT(e.firstName, ' ', e.lastName) AS sales_rep_name
FROM 
    products p
JOIN orderdetails od ON p.productCode = od.productCode
JOIN orders o ON od.orderNumber = o.orderNumber
JOIN customers c ON o.customerNumber = c.customerNumber
JOIN employees e ON c.salesRepEmployeeNumber = e.employeeNumber
GROUP BY 
    p.productCode, p.productName, p.productLine, e.employeeNumber
ORDER BY 
    total_sales DESC
LIMIT 10;

-- SELECT * FROM VIEW_LAB5; to view the top 10 products sold