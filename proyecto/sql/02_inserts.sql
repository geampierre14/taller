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

-- Productos (IDs 1..24 para que coincida con /public/img/image1.jpg ... image25.jpg)
INSERT INTO Producto (Nombre, Precio, Stock, CategoriaID, Imagen) VALUES
 ('Sanduche de Jamón', 2.50, 30, 1, 'img/image1.jpg'),
 ('Tostada con Queso', 1.75, 25, 1, 'img/image2.jpg'),
 ('Ensalada de Frutas', 2.20, 20, 1, 'img/image3.jpg'),
 ('Café Americano', 1.20, 50, 3, 'img/image4.jpg'),
 ('Café con Leche', 1.50, 45, 3, 'img/image5.jpg'),
 ('Jugo de Naranja', 1.80, 35, 3, 'img/image6.jpg'),
 ('Yogurt con Granola', 2.40, 15, 1, 'img/image7.jpg'),
 ('Huevos Revueltos', 2.80, 18, 1, 'img/image8.jpg'),
 ('Pan de Ajo', 1.60, 22, 1, 'img/image9.jpg'),

 ('Arroz con Pollo', 4.50, 20, 2, 'img/image10.jpg'),
 ('Seco de Carne', 5.25, 15, 2, 'img/image11.jpg'),
 ('Menestra con Carne', 4.80, 18, 2, 'img/image12.jpg'),
 ('Pasta Boloñesa', 4.90, 16, 2, 'img/image13.jpg'),
 ('Pollo a la Plancha', 5.10, 14, 2, 'img/image14.jpg'),
 ('Encebollado', 4.25, 20, 2, 'img/image15.jpg'),
 ('Ceviche', 4.75, 12, 2, 'img/image17.jpg'),
 ('Sopa de Lentejas', 3.60, 20, 2, 'img/image18.jpg'),
 ('Arroz Marinero', 5.90, 10, 2, 'img/image19.jpg'),

 ('Cola', 1.25, 60, 3, 'img/image20.jpg'),
 ('Agua', 1.00, 80, 3, 'img/image21.jpg'),
 ('Té Helado', 1.50, 40, 3, 'img/image22.jpg'),
 ('Limonada', 1.40, 45, 3, 'img/image23.jpg'),
 ('Batido de Fresa', 2.10, 25, 3, 'img/image24.jpg'),
 ('Batido de Mora', 2.10, 25, 3, 'img/image25.jpg');
