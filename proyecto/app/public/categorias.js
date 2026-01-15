const tbody = document.getElementById("tbody");
const q = document.getElementById("q");
const btnNuevo = document.getElementById("btnNuevo");

// modal
const modalBg = document.getElementById("modalBg");
const modalTitle = document.getElementById("modalTitle");
const form = document.getElementById("formCategoria");
const categoriaId = document.getElementById("categoriaId");
const nombre = document.getElementById("nombre");
const btnCancelar = document.getElementById("btnCancelar");

let categorias = [];

function rowHTML(c) {
  return `
    <tr>
      <td style="padding:10px; border-bottom:1px solid rgba(0,0,0,.08);">${c.CategoriaID}</td>
      <td style="padding:10px; border-bottom:1px solid rgba(0,0,0,.08);">${c.Nombre}</td>
      <td style="padding:10px; border-bottom:1px solid rgba(0,0,0,.08);">
        <button class="btn-mini edit" data-edit="${c.CategoriaID}">Editar</button>
        <button class="btn-mini del" data-del="${c.CategoriaID}">Eliminar</button>
      </td>
    </tr>
  `;
}

function render() {
  const term = (q.value || "").toLowerCase().trim();
  const list = term ? categorias.filter(c => (c.Nombre || "").toLowerCase().includes(term)) : categorias;
  tbody.innerHTML = list.map(rowHTML).join("") || `<tr><td colspan="3" style="padding:12px; opacity:.7;">Sin datos</td></tr>`;
}

function abrirModal(modo, c = null) {
  modalBg.style.display = "flex";
  modalTitle.textContent = modo === "new" ? "Nueva categoría" : "Editar categoría";
  if (modo === "new") {
    categoriaId.value = "";
    form.reset();
  } else {
    categoriaId.value = c.CategoriaID;
    nombre.value = c.Nombre ?? "";
  }
}

function cerrarModal() {
  modalBg.style.display = "none";
}

async function cargar() {
  const res = await fetch("/api/categorias");
  const data = await res.json();
  categorias = Array.isArray(data) ? data : [];
  render();
}

tbody.addEventListener("click", async (e) => {
  const editId = e.target.dataset.edit;
  const delId = e.target.dataset.del;

  if (editId) {
    const c = categorias.find(x => String(x.CategoriaID) === String(editId));
    if (c) abrirModal("edit", c);
  }

  if (delId) {
    if (!confirm("¿Eliminar esta categoría?")) return;
    const res = await fetch(`/api/categorias/${delId}`, { method: "DELETE" });
    const out = await res.json();
    if (!res.ok) return alert(out?.message || "Error eliminando");
    await cargar();
  }
});

form.addEventListener("submit", async (e) => {
  e.preventDefault();
  const payload = { nombre: nombre.value.trim() };
  if (payload.nombre.length < 2) return alert("Nombre inválido");

  const id = categoriaId.value;
  const res = await fetch(id ? `/api/categorias/${id}` : "/api/categorias", {
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
