const rail = document.getElementById("rail");
const q = document.getElementById("q");

const prev = document.getElementById("prev");
const next = document.getElementById("next");

const btnNuevo = document.getElementById("btnNuevo");

// modal
const modalBg = document.getElementById("modalBg");
const modalTitle = document.getElementById("modalTitle");
const form = document.getElementById("formProducto");

const productoId = document.getElementById("productoId");
const nombre = document.getElementById("nombre");
const precio = document.getElementById("precio");
const stock = document.getElementById("stock");
const categoriaId = document.getElementById("categoriaId");

const btnCancelar = document.getElementById("btnCancelar");

let productos = [];
let activeGrid = null; // para mover el carrusel en la sección activa

function imageForProduct(p) {
  // Si el producto tiene imagen en la BD, úsala
  if (p.Imagen) {
    return `/${p.Imagen}`;
  }

  // Si no, usa imagen por defecto
  return '/img/image1.jpg';
}


function renderCard(p, idx = 0) {
  const img = imageForProduct(p);

  return `
    <div class="card">
      <div class="product-img-wrap">
        <img class="product-img" src="${img}" alt="${p.Nombre || "Producto"}"
          onerror="this.onerror=null; this.src='/img/image1.jpg';" />
      </div>

      <div class="name">${p.Nombre ?? ""}</div>
      <div class="meta">Stock: ${p.Stock ?? 0} | CatID: ${p.CategoriaID ?? ""}</div>
      <div class="price">$${Number(p.Precio ?? 0).toFixed(2)}</div>

      <div class="actions">
        <button class="btn-mini edit" data-edit="${p.ProductoID}">Editar</button>
        <button class="btn-mini stock" data-stock="${p.ProductoID}">Stock +</button>
        <button class="btn-mini del" data-del="${p.ProductoID}">Eliminar</button>
      </div>
    </div>
  `;
}

function render(list) {
  // ejemplo: separar en 2 secciones para tu catálogo
  const desayunos = list.filter((p) => Number(p.ProductoID) >= 1 && Number(p.ProductoID) <= 9);
  const almuerzos = list.filter((p) => Number(p.ProductoID) >= 10);

  rail.innerHTML = `
    <section class="section">
      <h2 class="categoria-title">🥐 Desayunos</h2>
      <div class="grid" id="gridDesayunos">
        ${desayunos.map(renderCard).join("")}
      </div>
    </section>

    <section class="section">
      <h2 class="categoria-title">🍛 Almuerzos</h2>
      <div class="grid" id="gridAlmuerzos">
        ${almuerzos.map(renderCard).join("")}
      </div>
    </section>
  `;

  bindCarousel();
}

function bindCarousel() {
  const grids = document.querySelectorAll(".grid");
  activeGrid = grids[0] || null;

  grids.forEach((g) => {
    g.addEventListener("mouseenter", () => (activeGrid = g));
    g.addEventListener("touchstart", () => (activeGrid = g), { passive: true });
  });
}

function aplicarFiltro() {
  const term = (q.value || "").toLowerCase().trim();
  const list = term
    ? productos.filter((p) => (p.Nombre || "").toLowerCase().includes(term))
    : productos;
  render(list);
}

function abrirModal(modo, p = null) {
  modalBg.style.display = "flex";
  modalTitle.textContent = modo === "new" ? "Nuevo producto" : "Editar producto";

  if (modo === "new") {
    productoId.value = "";
    form.reset();
  } else {
    productoId.value = p.ProductoID;
    nombre.value = p.Nombre ?? "";
    precio.value = p.Precio ?? "";
    stock.value = p.Stock ?? 0;
    categoriaId.value = p.CategoriaID ?? "";
  }
}

function cerrarModal() {
  modalBg.style.display = "none";
}

function validarPayload(payload) {
  const errores = [];
  if (!payload.nombre || payload.nombre.trim().length < 2) errores.push("Nombre inválido.");
  if (!Number.isFinite(payload.precio) || payload.precio <= 0) errores.push("Precio inválido.");
  if (!Number.isInteger(payload.stock) || payload.stock < 0) errores.push("Stock inválido.");
  if (!Number.isInteger(payload.categoriaId) || payload.categoriaId <= 0) errores.push("Categoría inválida.");
  return errores;
}

async function cargarProductos() {
  try {
    const res = await fetch("/api/productos");
    const data = await res.json();
    productos = Array.isArray(data) ? data : [];
    aplicarFiltro();
  } catch (err) {
    console.error("Error cargando productos:", err);
    productos = [];
    render([]);
    alert("No se pudo conectar con /api/productos.");
  }
}

// eventos catálogo
rail.addEventListener("click", async (e) => {
  const editId = e.target.dataset.edit;
  const stockId = e.target.dataset.stock;
  const delId = e.target.dataset.del;

  if (editId) {
    const p = productos.find((x) => String(x.ProductoID) === String(editId));
    if (p) abrirModal("edit", p);
  }


  if (stockId) {
    const incStr = prompt("¿Cuánto deseas aumentar el stock? (ej: 5)", "1");
    if (incStr === null) return;

    const cantidad = Number(incStr);
    if (!Number.isFinite(cantidad) || !Number.isInteger(cantidad) || cantidad <= 0) {
      return alert("Ingresa un entero positivo (ej: 1, 5, 10)");
    }

    const res = await fetch(`/api/productos/${stockId}/stock`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ cantidad }),
    });

    const out = await res.json();
    if (!res.ok) return alert(out?.message || "Error actualizando stock");

    await cargar();
    return;
  }

  if (delId) {
    if (!confirm("¿Eliminar este producto?")) return;

    const res = await fetch(`/api/productos/${delId}`, { method: "DELETE" });
    const out = await res.json();

    if (!res.ok) {
      alert(out?.message || "Error eliminando");
      return;
    }
    await cargarProductos();
  }
});

form.addEventListener("submit", async (e) => {
  e.preventDefault();

  const payload = {
    nombre: nombre.value.trim(),
    precio: Number(precio.value),
    stock: Number(stock.value),
    categoriaId: Number(categoriaId.value),
  };

  const errores = validarPayload(payload);
  if (errores.length) return alert(errores.join(" "));

  const id = productoId.value;

  const res = await fetch(id ? `/api/productos/${id}` : "/api/productos", {
    method: id ? "PUT" : "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });

  const out = await res.json();
  if (!res.ok) return alert(out?.message || "Error guardando");

  cerrarModal();
  await cargarProductos();
});

q.addEventListener("input", aplicarFiltro);
btnNuevo.addEventListener("click", () => abrirModal("new"));
btnCancelar.addEventListener("click", cerrarModal);
modalBg.addEventListener("click", (e) => {
  if (e.target === modalBg) cerrarModal();
});

// flechas carrusel: mueve la sección activa
prev.addEventListener("click", () => {
  if (!activeGrid) return;
  activeGrid.scrollBy({ left: -320, behavior: "smooth" });
});
next.addEventListener("click", () => {
  if (!activeGrid) return;
  activeGrid.scrollBy({ left: 320, behavior: "smooth" });
});

// init
cargarProductos();

function imageForProduct(p, idx = 0) {
  const raw = (p.imagen || p.Imagen || p.image || '').trim();
  if (raw) {
    const file = raw.replace(/^\/?img\//, '').replace(/^\/+/, '');
    return `/img/${file}`;
  }
  const n = (idx % 18) + 1;
  return `/img/image${n}.jpg`;
}

function renderCard(p, idx = 0) {
  const img = imageForProduct(p);

  // colores distintos por tarjeta
  const colors = ['#6EC1FF', '#B9A6FF', '#40E0D0', '#F5D547', '#FFB6C1'];
  const c = colors[idx % colors.length];

  return `
    <div class="food-card">
      <div class="bubble" style="background:${c}">
        <div class="img-box">
          <img class="food-img" src="${img}" alt="${p.Nombre || 'Producto'}"
            onerror="this.onerror=null; this.src='/img/image1.jpg';" />
        </div>
      </div>

      <div class="food-name">${p.Nombre ?? ''}</div>
      <div class="food-stock">Stock: ${p.Stock ?? 0}</div>
      <div class="food-price">$${Number(p.Precio ?? 0).toFixed(2)}</div>

      <div class="food-actions">
        <button class="btn-edit" data-edit="${p.ProductoID}">Editar</button>
        <button class="btn-del" data-del="${p.ProductoID}">Eliminar</button>
      </div>
    </div>
  `;
}


async function cargarProductos() {
  const res = await fetch('/api/productos');
  const data = await res.json();
  console.log('Productos:', data);

  if (!rail) {
    console.error('No existe el contenedor #rail en productos.html');
    return;
  }

  // Verificar que data sea un array
  if (!Array.isArray(data)) {
    console.error('La respuesta no es un array:', data);
    rail.innerHTML = '<div style="text-align:center; padding:40px;">Error al cargar productos</div>';
    return;
  }

  // Asignar a la variable global
  productos = data;

  rail.innerHTML = data.map((p, i) => renderCard(p, i)).join('');
}

cargarProductos();
