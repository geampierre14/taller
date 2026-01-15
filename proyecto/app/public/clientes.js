const tbody = document.getElementById("tbody");
const q = document.getElementById("q");
const btnNuevo = document.getElementById("btnNuevo");

// modal
const modalBg = document.getElementById("modalBg");
const modalTitle = document.getElementById("modalTitle");
const form = document.getElementById("formCliente");
const clienteId = document.getElementById("clienteId");
const nombre = document.getElementById("nombre");
const email = document.getElementById("email");
const telefono = document.getElementById("telefono");
const btnCancelar = document.getElementById("btnCancelar");

let clientes = [];

function rowHTML(c) {
  return `
    <tr>
      <td style="padding:10px; border-bottom:1px solid rgba(0,0,0,.08);">${c.ClienteID}</td>
      <td style="padding:10px; border-bottom:1px solid rgba(0,0,0,.08);">${c.Nombre}</td>
      <td style="padding:10px; border-bottom:1px solid rgba(0,0,0,.08);">${c.Email}</td>
      <td style="padding:10px; border-bottom:1px solid rgba(0,0,0,.08);">${c.Telefono ?? ""}</td>
      <td style="padding:10px; border-bottom:1px solid rgba(0,0,0,.08);">
        <button class="btn-mini edit" data-edit="${c.ClienteID}">Editar</button>
        <button class="btn-mini del" data-del="${c.ClienteID}">Eliminar</button>
      </td>
    </tr>
  `;
}

function render() {
  const term = (q.value || "").toLowerCase().trim();
  const list = term
    ? clientes.filter(c =>
        (c.Nombre || "").toLowerCase().includes(term) ||
        (c.Email || "").toLowerCase().includes(term)
      )
    : clientes;

  tbody.innerHTML = list.map(rowHTML).join("") || `<tr><td colspan="5" style="padding:12px; opacity:.7;">Sin datos</td></tr>`;
}

function abrirModal(modo, c = null) {
  modalBg.style.display = "flex";
  modalTitle.textContent = modo === "new" ? "Nuevo cliente" : "Editar cliente";

  if (modo === "new") {
    clienteId.value = "";
    form.reset();
  } else {
    clienteId.value = c.ClienteID;
    nombre.value = c.Nombre ?? "";
    email.value = c.Email ?? "";
    telefono.value = c.Telefono ?? "";
  }
}

function cerrarModal() {
  modalBg.style.display = "none";
}

async function cargar() {
  const res = await fetch("/api/clientes");
  const data = await res.json();
  clientes = Array.isArray(data) ? data : [];
  render();
}

tbody.addEventListener("click", async (e) => {
  const editId = e.target.dataset.edit;
  const delId = e.target.dataset.del;

  if (editId) {
    const c = clientes.find(x => String(x.ClienteID) === String(editId));
    if (c) abrirModal("edit", c);
  }

  if (delId) {
    if (!confirm("¿Eliminar este cliente?")) return;
    const res = await fetch(`/api/clientes/${delId}`, { method: "DELETE" });
    const out = await res.json();
    if (!res.ok) return alert(out?.message || "Error eliminando");
    await cargar();
  }
});

form.addEventListener("submit", async (e) => {
  e.preventDefault();

  const payload = {
    nombre: nombre.value.trim(),
    email: email.value.trim(),
    telefono: telefono.value.trim() || null,
  };

  if (!payload.nombre || payload.nombre.length < 2) return alert("Nombre inválido");
  if (!payload.email || !payload.email.includes("@")) return alert("Email inválido");

  const id = clienteId.value;

  const res = await fetch(id ? `/api/clientes/${id}` : "/api/clientes", {
    method: id ? "PUT" : "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });

  const out = await res.json();
  if (!res.ok) return alert(out?.message || "Error guardando");

  cerrarModal();
  await cargar();
});

q.addEventListener("input", render);
btnNuevo.addEventListener("click", () => abrirModal("new"));
btnCancelar.addEventListener("click", cerrarModal);
modalBg.addEventListener("click", (e) => { if (e.target === modalBg) cerrarModal(); });

cargar();
