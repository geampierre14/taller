import { pool } from "../db.js";

async function list(req, res) {
  try {
    const [rows] = await pool.query(
      "SELECT ClienteID, Nombre, Email, Telefono FROM Cliente ORDER BY ClienteID DESC"
    );
    res.json(rows);
  } catch (err) {
    console.error("ERROR /api/clientes:", err);
    res.status(500).json({ status: "Error", message: err.message });
  }
}

async function getById(req, res) {
  try {
    const { id } = req.params;
    const [rows] = await pool.query(
      "SELECT ClienteID, Nombre, Email, Telefono FROM Cliente WHERE ClienteID = ?",
      [id]
    );
    if (rows.length === 0) {
      return res.status(404).json({ status: "Error", message: "Cliente no encontrado" });
    }
    res.json(rows[0]);
  } catch (err) {
    console.error("ERROR /api/clientes/:id:", err);
    res.status(500).json({ status: "Error", message: err.message });
  }
}

async function create(req, res) {
    console.log(req.body);

  try {
    const { nombre, email, telefono } = req.body;
    if (!nombre || !email) {
      return res.status(400).json({ status: "Error", message: "Nombre y Email son obligatorios" });
    }

    const [result] = await pool.query(
      "INSERT INTO Cliente (Nombre, Email, Telefono) VALUES (?, ?, ?)",
      [nombre.trim(), email.trim(), telefono || null]
    );

    res.status(201).json({ status: "ok", id: result.insertId });
  } catch (err) {
    console.error("ERROR create cliente:", err);
    res.status(500).json({ status: "Error", message: err.message });
  }
}

async function update(req, res) {
  try {
    const { id } = req.params;
    const { nombre, email, telefono } = req.body;

    await pool.query(
      "UPDATE Cliente SET Nombre = ?, Email = ?, Telefono = ? WHERE ClienteID = ?",
      [nombre?.trim() ?? "", email?.trim() ?? "", telefono || null, id]
    );

    res.json({ status: "ok" });
  } catch (err) {
    console.error("ERROR update cliente:", err);
    res.status(500).json({ status: "Error", message: err.message });
  }
}

async function remove(req, res) {
  try {
    const { id } = req.params;
    const [result] = await pool.query("DELETE FROM Cliente WHERE ClienteID = ?", [id]);
    if (result.affectedRows === 0) {
      return res.status(404).json({ status: "Error", message: "Cliente no encontrado" });
    }
    res.json({ status: "ok" });
  } catch (err) {
    console.error("ERROR delete cliente:", err);
    res.status(500).json({ status: "Error", message: err.message });
  }
}

export const methods = { list, getById, create, update, remove };