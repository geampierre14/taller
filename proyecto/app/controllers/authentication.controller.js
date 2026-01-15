import bcrypt from "bcrypt";
import { pool } from "../db.js";

async function login(req, res) {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ status: "Error", message: "Faltan datos" });
    }

    const [rows] = await pool.query(
      "SELECT ClienteID, Nombre, Email, PasswordHash FROM Cliente WHERE Email = ?",
      [email]
    );

    if (rows.length === 0) {
      return res.status(401).json({ status: "Error", message: "Credenciales inválidas" });
    }

    const cliente = rows[0];
    const ok = await bcrypt.compare(password, cliente.PasswordHash);

    if (!ok) {
      return res.status(401).json({ status: "Error", message: "Credenciales inválidas" });
    }

    return res.json({
      status: "ok",
      message: "Login correcto",
      user: { id: cliente.ClienteID, nombre: cliente.Nombre, email: cliente.Email },
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ status: "Error", message: "Error del servidor" });
  }
}

async function register(req, res) {
  try {
    // OJO: tu frontend manda username/email/password
    const { username, email, password } = req.body;

    if (!username || !email || !password) {
      return res.status(400).json({ status: "Error", message: "Faltan datos" });
    }

    // email único
    const [exists] = await pool.query(
      "SELECT ClienteID FROM Cliente WHERE Email = ?",
      [email]
    );

    if (exists.length > 0) {
      return res.status(409).json({ status: "Error", message: "Email ya registrado" });
    }

    const hash = await bcrypt.hash(password, 10);

    // En tu tabla: Nombre, Email, PasswordHash (Telefono puede ser NULL)
    await pool.query(
      "INSERT INTO Cliente (Nombre, Email, PasswordHash) VALUES (?, ?, ?)",
      [username, email, hash]
    );

    return res.status(201).json({ status: "ok", message: "Registro exitoso" });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ status: "Error", message: "Error del servidor" });
  }
}

export const methods = {
  login,
  register,
};


