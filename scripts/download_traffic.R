if (!dir.exists("data")) {
  dir.create("data")
}

url_traf <- "https://www.bilbao.eus/aytoonline/srvDatasetTrafico?formato=geojson"
timestamp <- format(Sys.time(), "%Y%m%d_%H%M")
filename <- paste0("data/trafico_", timestamp, ".geojson")

# Simulamos ser un navegador Chrome real en Windows
user_agent <- "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

# Comando curl más agresivo
# -H añade la cabecera de navegador
# --retry intenta 3 veces si falla
comando <- paste0("curl -k -L -A '", user_agent, "' '", url_traf, "' -o ", filename, " --max-time 150 --retry 3")

print(paste("Intentando descarga:", filename))
system(comando)

# Verificamos si funcionó
if (file.exists(filename) && file.info(filename)$size > 500) {
  print(paste("✅ ¡Conseguido! Tamaño:", file.info(filename)$size, "bytes"))
} else {
  # Si falla, imprimimos lo que hay en el archivo (si es que hay algo) para ver el error del servidor
  if (file.exists(filename)) {
    print("Contenido del error del servidor:")
    print(readLines(filename, n = 5))
  }
  stop("❌ El servidor sigue rechazando la conexión o el archivo es demasiado pequeño.")
}
