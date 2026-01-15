-- =========================================================
-- 02_inserts.sql
-- Datos de ejemplo para pruebas del frontend.
-- =========================================================
USE RestauranteDB;

-- Categorías base
INSERT INTO Categoria (Nombre) VALUES
 ('Desayunos'),
 ('Almuerzos'),
 ('Bebidas');

-- Clientes de ejemplo (PasswordHash se llena con el register)
INSERT INTO Cliente (Nombre, Email, Telefono) VALUES
 ('Admin', 'admin@correo.com', '0999999999'),
 ('Juan Perez', 'juan@correo.com', '0988888888');

-- Productos (IDs 1..24 para que coincida con /public/img/image1.jpg ... image24.jpg)
INSERT INTO Producto (Nombre, Precio, Stock, CategoriaID) VALUES
 ('Sanduche de Jamón', 2.50, 30, 1),
 ('Tostada con Queso', 1.75, 25, 1),
 ('Ensalada de Frutas', 2.20, 20, 1),
 ('Café Americano', 1.20, 50, 3),
 ('Café con Leche', 1.50, 45, 3),
 ('Jugo de Naranja', 1.80, 35, 3),
 ('Yogurt con Granola', 2.40, 15, 1),
 ('Huevos Revueltos', 2.80, 18, 1),
 ('Pan de Ajo', 1.60, 22, 1),

 ('Arroz con Pollo', 4.50, 20, 2),
 ('Seco de Carne', 5.25, 15, 2),
 ('Menestra con Carne', 4.80, 18, 2),
 ('Pasta Boloñesa', 4.90, 16, 2),
 ('Pollo a la Plancha', 5.10, 14, 2),
 ('Encebollado', 4.25, 20, 2),
 ('Ceviche', 4.75, 12, 2),
 ('Sopa de Lentejas', 3.60, 20, 2),
 ('Arroz Marinero', 5.90, 10, 2),

 ('Cola', 1.25, 60, 3),
 ('Agua', 1.00, 80, 3),
 ('Té Helado', 1.50, 40, 3),
 ('Limonada', 1.40, 45, 3),
 ('Batido de Fresa', 2.10, 25, 3),
 ('Batido de Mora', 2.10, 25, 3);
