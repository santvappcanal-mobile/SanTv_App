// Reemplaza los {{marcadores}} de la página con los valores de config.js
document.addEventListener("DOMContentLoaded", function () {
  var cfg = window.SANTV || {};
  var llenar = function (t) {
    return t.replace(/\{\{(\w+)\}\}/g, function (m, k) { return cfg[k] !== undefined ? cfg[k] : m; });
  };
  document.title = llenar(document.title);
  document.body.innerHTML = llenar(document.body.innerHTML);
});
