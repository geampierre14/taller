console.log("REGISTER.JS CARGADO ✅");
document.getElementById("register-Form").addEventListener("submit", async (e) => {
  e.preventDefault();

  const form = e.target;

  const username = form.elements.user.value;
  const email = form.elements.email.value;
  const password = form.elements.password.value;

  console.log("ENVIANDO:", { username, email, password });

  const res = await fetch("/api/register", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ username, email, password }),
  });

  const data = await res.json();
  console.log("RESPUESTA:", data);
});
