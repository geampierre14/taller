console.log("LOGIN.JS CARGADO ✅");

document.getElementById("login-Form").addEventListener("submit", async (e) => {
  e.preventDefault();
  console.log("SUBMIT LOGIN ✅");

  const form = e.target;
  const email = form.elements.email.value;
  const password = form.elements.password.value;


  console.log("ENVIANDO:", { email, password });

  const res = await fetch("/api/login", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email, password }),
  });

  console.log("STATUS:", res.status);

  const data = await res.json();
  console.log("RESPUESTA:", data);

  if (!res.ok) return alert(data.message || "Error login");

  window.location.href = "/admin";
});
