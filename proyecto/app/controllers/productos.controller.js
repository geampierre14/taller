import { pool } from "../db.js";

/**
 * Tabla esperada:
 * Producto(ProductoID, Nombre, Precio, Stock)
 */

async function list(req, res) {
  try {
    const [rows] = await pool.query(
      "SELECT ProductoID, Nombre, Precio, Stock, CategoriaID, Imagen FROM Producto ORDER BY CategoriaID, ProductoID"
    );
    res.json(rows);
  } catch (err) {
    console.log("ERROR /api/productos:", err);
    res.status(500).json({ status: "Error", message: err.message });
  }
}


async function getById(req, res) {
  try {
    const { id } = req.params;

    const [rows] = await pool.query(
      "SELECT ProductoID, Nombre, Precio, Stock, CategoriaID, Imagen FROM Producto WHERE ProductoID = ?",
      [id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ status: "Error", message: "Producto no encontrado" });
    }

    res.json(rows[0]);
  } catch (err) {
    console.log("ERROR /api/productos/:id:", err);
    res.status(500).json({ status: "Error", message: err.message });
  }
}


function validarProducto({ nombre, precio, stock, categoriaId }) {
  const errores = [];

  if (!nombre || nombre.trim().length < 2) errores.push("Nombre inválido (mínimo 2 caracteres).");

  const precioNum = Number(precio);
  if (!Number.isFinite(precioNum) || precioNum <= 0) errores.push("Precio inválido (debe ser > 0).");

  const stockNum = Number(stock);
  if (!Number.isInteger(stockNum) || stockNum < 0) errores.push("Stock inválido (entero >= 0).");

  const categoriaNum = Number(categoriaId);
  if (!Number.isInteger(categoriaNum) || categoriaNum <= 0) errores.push("Categoría inválida (ID entero > 0).");

  return { ok: errores.length === 0, errores, precioNum, stockNum, categoriaNum };
}

async function create(req, res) {
  try {
    const { nombre, precio, stock, categoriaId } = req.body;

    const v = validarProducto({ nombre, precio, stock, categoriaId });
    if (!v.ok) return res.status(400).json({ status: "Error", message: v.errores.join(" ") });

    const [result] = await pool.query(
      "INSERT INTO Producto (Nombre, Precio, Stock, CategoriaID) VALUES (?, ?, ?, ?)",
      [nombre.trim(), v.precioNum, v.stockNum, v.categoriaNum]
    );

    res.status(201).json({ status: "ok", id: result.insertId });
  } catch (err) {
    console.log("ERROR create producto:", err);
    res.status(500).json({ status: "Error", message: err.message });
  }
}



async function update(req, res) {
  try {
    const { id } = req.params;
    const { nombre, precio, stock, categoriaId } = req.body;

    const v = validarProducto({ nombre, precio, stock, categoriaId });
    if (!v.ok) return res.status(400).json({ status: "Error", message: v.errores.join(" ") });

    await pool.query(
      "UPDATE Producto SET Nombre = ?, Precio = ?, Stock = ?, CategoriaID = ? WHERE ProductoID = ?",
      [nombre.trim(), v.precioNum, v.stockNum, v.categoriaNum, id]
    );

    res.json({ status: "ok" });
  } catch (err) {
    console.log("ERROR update producto:", err);
    res.status(500).json({ status: "Error", message: err.message });
  }
}



async function remove(req, res) {
  try {
    const { id } = req.params;

    const [result] = await pool.query(
      "DELETE FROM Producto WHERE ProductoID = ?",
      [id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ status: "Error", message: "Producto no encontrado" });
    }

    res.json({ status: "ok" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ status: "Error", message: "Error eliminando producto" });
  }
}

export const methods = { list, getById, create, update, remove };

function imageForProduct(p, idx = 0) {
  const raw = (p.Imagen || p.imagen || '').trim();
  if (raw) return `/img/${raw}`;
  return '/img/image1.jpg';
}
