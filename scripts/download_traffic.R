if (!dir.exists("data")) {
  dir.create("data")
}

url_traf <- "https://www.bilbao.eus/aytoonline/srvDatasetTrafico?formato=geojson"
timestamp <- format(Sys.time(), "%Y%m%d_%H%M")
filename <- paste0("data/trafico_", timestamp, ".geojson")

# Usamos 'curl', que es el estándar de oro en Linux para descargas
# -L: sigue redirecciones
# -s: modo silencioso
# -k: ignora problemas de certificados SSL (a veces fallan en webs oficiales)
# --max-time: tiempo límite en segundos
comando <- paste0("curl -L -k -s '", url_traf, "' -o ", filename, " --max-time 120")

print(paste("Ejecutando:", comando))
system(comando)

# Verificación de seguridad
if (file.exists(filename) && file.info(filename)$size > 100) {
  print(paste("Éxito: Archivo guardado en", filename))
} else {
  stop("Error: El archivo no se descargó o es demasiado pequeño.")
}
