-- =========================================================
-- 08_agregar_imagenes.sql
-- Agregar columna de imágenes a productos existentes
-- =========================================================
USE RestauranteDB;

-- Verificar si la columna ya existe, si no, agregarla
SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'RestauranteDB'
  AND TABLE_NAME = 'Producto'
  AND COLUMN_NAME = 'Imagen';

SET @query = IF(@col_exists = 0,
    'ALTER TABLE Producto ADD COLUMN Imagen VARCHAR(255) NULL AFTER CategoriaID',
    'SELECT "La columna Imagen ya existe" AS mensaje'
);

PREPARE stmt FROM @query;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Actualizar productos existentes con las imágenes
-- Desayunos (Productos 1-9)
UPDATE Producto SET Imagen = 'img/image1.jpg' WHERE ProductoID = 1 AND Imagen IS NULL;
UPDATE Producto SET Imagen = 'img/image2.jpg' WHERE ProductoID = 2 AND Imagen IS NULL;
UPDATE Producto SET Imagen = 'img/image3.jpg' WHERE ProductoID = 3 AND Imagen IS NULL;
UPDATE Producto SET Imagen = 'img/image4.jpg' WHERE ProductoID = 4 AND Imagen IS NULL;
UPDATE Producto SET Imagen = 'img/image5.jpg' WHERE ProductoID = 5 AND Imagen IS NULL;
UPDATE Producto SET Imagen = 'img/image6.jpg' WHERE ProductoID = 6 AND Imagen IS NULL;
UPDATE Producto SET Imagen = 'img/image7.jpg' WHERE ProductoID = 7 AND Imagen IS NULL;
UPDATE Producto SET Imagen = 'img/image8.jpg' WHERE ProductoID = 8 AND Imagen IS NULL;
UPDATE Producto SET Imagen = 'img/image9.jpg' WHERE ProductoID = 9 AND Imagen IS NULL;

-- Almuerzos (Productos 10-18)
UPDATE Producto SET Imagen = 'img/image10.jpg' WHERE ProductoID = 10 AND Imagen IS NULL;
UPDATE Producto SET Imagen = 'img/image11.jpg' WHERE ProductoID = 11 AND Imagen IS NULL;
UPDATE Producto SET Imagen = 'img/image12.jpg' WHERE ProductoID = 12 AND Imagen IS NULL;
UPDATE Producto SET Imagen = 'img/image13.jpg' WHERE ProductoID = 13 AND Imagen IS NULL;
UPDATE Producto SET Imagen = 'img/image14.jpg' WHERE ProductoID = 14 AND Imagen IS NULL;
UPDATE Producto SET Imagen = 'img/image15.jpg' WHERE ProductoID = 15 AND Imagen IS NULL;
UPDATE Producto SET Imagen = 'img/image17.jpg' WHERE ProductoID = 16 AND Imagen IS NULL;
UPDATE Producto SET Imagen = 'img/image18.jpg' WHERE ProductoID = 17 AND Imagen IS NULL;
UPDATE Producto SET Imagen = 'img/image19.jpg' WHERE ProductoID = 18 AND Imagen IS NULL;

-- Bebidas (Productos 19-24)
UPDATE Producto SET Imagen = 'img/image20.jpg' WHERE ProductoID = 19 AND Imagen IS NULL;
UPDATE Producto SET Imagen = 'img/image21.jpg' WHERE ProductoID = 20 AND Imagen IS NULL;
UPDATE Producto SET Imagen = 'img/image22.jpg' WHERE ProductoID = 21 AND Imagen IS NULL;
UPDATE Producto SET Imagen = 'img/image23.jpg' WHERE ProductoID = 22 AND Imagen IS NULL;
UPDATE Producto SET Imagen = 'img/image24.jpg' WHERE ProductoID = 23 AND Imagen IS NULL;
UPDATE Producto SET Imagen = 'img/image25.jpg' WHERE ProductoID = 24 AND Imagen IS NULL;

-- Mostrar resultado
SELECT 
    COUNT(*) as TotalProductos,
    SUM(CASE WHEN Imagen IS NOT NULL THEN 1 ELSE 0 END) as ProductosConImagen,
    SUM(CASE WHEN Imagen IS NULL THEN 1 ELSE 0 END) as ProductosSinImagen
FROM Producto;

SELECT 
    ProductoID,
    Nombre,
    Imagen,
    CategoriaID
FROM Producto
ORDER BY ProductoID;
