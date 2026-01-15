export const addStockProducto = async (req, res) => {
  try {
    const { id } = req.params;
    const { cantidad } = req.body;

    const cant = Number(cantidad);
    if (!Number.isFinite(cant) || cant <= 0)
      return res.status(400).json({ message: "cantidad inválida" });

    const [result] = await pool.query(
      "UPDATE Producto SET Stock = Stock + ? WHERE IdProducto = ?",
      [cant, id]
    );

    if (result.affectedRows === 0)
      return res.status(404).json({ message: "Producto no encontrado" });

    const [rows] = await pool.query(
      "SELECT Stock FROM Producto WHERE IdProducto = ?",
      [id]
    );

    res.json({ id: Number(id), stock: rows[0].Stock });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
import { pool } from "../db.js";

async function list(req, res) {
  try {
    const [rows] = await pool.query(
      "SELECT CategoriaID, Nombre FROM Categoria ORDER BY CategoriaID DESC"
    );
    res.json(rows);
  } catch (err) {
    console.error("ERROR /api/categorias:", err);
    res.status(500).json({ status: "Error", message: err.message });
  }
}

async function getById(req, res) {
  try {
    const { id } = req.params;
    const [rows] = await pool.query(
      "SELECT CategoriaID, Nombre FROM Categoria WHERE CategoriaID = ?",
      [id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ status: "Error", message: "Categoría no encontrada" });
    }

    res.json(rows[0]);
  } catch (err) {
    console.error("ERROR /api/categorias/:id:", err);
    res.status(500).json({ status: "Error", message: err.message });
  }
}

async function create(req, res) {
  try {
    const { nombre } = req.body;
    if (!nombre || nombre.trim().length < 2) {
      return res.status(400).json({ status: "Error", message: "Nombre inválido" });
    }

    const [result] = await pool.query(
      "INSERT INTO Categoria (Nombre) VALUES (?)",
      [nombre.trim()]
    );

    res.status(201).json({ status: "ok", id: result.insertId });
  } catch (err) {
    console.error("ERROR create categoria:", err);
    res.status(500).json({ status: "Error", message: err.message });
  }
}

async function update(req, res) {
  try {
    const { id } = req.params;
    const { nombre } = req.body;
    if (!nombre || nombre.trim().length < 2) {
      return res.status(400).json({ status: "Error", message: "Nombre inválido" });
    }

    await pool.query(
      "UPDATE Categoria SET Nombre = ? WHERE CategoriaID = ?",
      [nombre.trim(), id]
    );

    res.json({ status: "ok" });
  } catch (err) {
    console.error("ERROR update categoria:", err);
    res.status(500).json({ status: "Error", message: err.message });
  }
}

async function remove(req, res) {
  try {
    const { id } = req.params;
    const [result] = await pool.query(
      "DELETE FROM Categoria WHERE CategoriaID = ?",
      [id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ status: "Error", message: "Categoría no encontrada" });
    }

    res.json({ status: "ok" });
  } catch (err) {
    console.error("ERROR delete categoria:", err);
    res.status(500).json({ status: "Error", message: "Error eliminando categoría" });
  }
}

export const methods = { list, getById, create, update, remove };
