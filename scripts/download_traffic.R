# Crear la carpeta data si no existe
if (!dir.exists("data")) {
  dir.create("data")
}
options(timeout = 300)
# Configurar URL y nombre de archivo con timestamp
url_traf <- "https://www.bilbao.eus/aytoonline/srvDatasetTrafico?formato=geojson"
# Usamos UTC para evitar líos de zonas horarias en el servidor
timestamp <- format(Sys.time(), "%Y%m%d_%H%M")
filename <- paste0("data/trafico_", timestamp, ".geojson")

# Descargar usando la función base de R (no necesita paquetes)
tryCatch({
  download.file(url_traf, destfile = filename, mode = "wb")
  print(paste("Archivo guardado con éxito:", filename))
}, error = function(e) {
  stop("Error al descargar los datos: ", e$message)
})
