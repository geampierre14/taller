import express from 'express';
import path from 'path';
import { fileURLToPath } from 'url';

import { methods as authentication } from './controllers/authentication.controller.js';
import { methods as productos } from './controllers/productos.controller.js';
import { methods as categorias } from './controllers/categorias.controller.js';
import { methods as clientes } from './controllers/clientes.controller.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();

// 🔴 ESTO VA ANTES DE TODAS LAS RUTAS
app.use(express.static(path.join(__dirname, 'public')));

// configuración
app.set('port', 4001);
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// rutas
app.get('/', (req, res) =>
  res.sendFile(path.join(__dirname, 'pages/login.html'))
);

app.get('/register', (req, res) =>
  res.sendFile(path.join(__dirname, 'pages/register.html'))
);

app.get('/admin', (req, res) =>
  res.sendFile(path.join(__dirname, 'pages/admin/admin.html'))
);

app.get('/admin-productos', (req, res) =>
  res.sendFile(path.join(__dirname, 'pages/admin/productos.html'))
);
app.get('/admin-categorias', (req, res) =>
  res.sendFile(path.join(__dirname, 'pages/admin/categorias.html'))
);

app.get('/admin-clientes', (req, res) =>
  res.sendFile(path.join(__dirname, 'pages/admin/clientes.html'))
);

// API
app.post('/api/login', authentication.login);
app.post('/api/register', authentication.register);
app.get('/api/productos', productos.list);
app.get('/api/productos/:id', productos.getById);
app.post('/api/productos', productos.create);
app.put('/api/productos/:id', productos.update);
app.delete('/api/productos/:id', productos.remove);
// CRUD Categorías
app.get('/api/categorias', categorias.list);
app.get('/api/categorias/:id', categorias.getById);
app.post('/api/categorias', categorias.create);
app.put('/api/categorias/:id', categorias.update);
app.delete('/api/categorias/:id', categorias.remove);

// CRUD Clientes
app.get('/api/clientes', clientes.list);
app.get('/api/clientes/:id', clientes.getById);
app.post('/api/clientes', clientes.create);
app.put('/api/clientes/:id', clientes.update);
app.delete('/api/clientes/:id', clientes.remove);

app.listen(app.get('port'), () => {
  console.log('Server on port', app.get('port'));
});