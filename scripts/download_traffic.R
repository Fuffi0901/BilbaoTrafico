# Cargar librerías necesarias para procesar el dato antes de guardarlo
library(sf)
library(dplyr)

if (!dir.exists("data")) { dir.create("data") }

# Archivos
url_traf <- "https://www.bilbao.eus/aytoonline/srvDatasetTrafico?formato=geojson"
temp_file <- "data/temp_trafico.geojson"
master_file <- "data/trafico_historico.csv"

# 1. Descarga con curl (el método que nos funcionó)
user_agent <- "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
comando <- paste0("curl -k -L -A '", user_agent, "' '", url_traf, "' -o ", temp_file, " --max-time 150 --retry 3")

system(comando)

# 2. Si la descarga fue exitosa, procesamos y anexamos
if (file.exists(temp_file) && file.info(temp_file)$size > 500) {
  
  # Leer el geojson recién descargado
  nuevo_dato <- st_read(temp_file, quiet = TRUE)
  
  # Convertir a tabla normal (quitando la geometría para ahorrar espacio en el CSV)
  # Si necesitas las coordenadas, usa: nuevo_dato <- nuevo_dato %>% mutate(geom = st_as_text(geometry))
  nuevo_dato_tabular <- st_drop_geometry(nuevo_dato)
  
  # 3. Guardar o Anexar
  if (!file.exists(master_file)) {
    # Si el archivo no existe, lo creamos con cabeceras
    write.table(nuevo_dato_tabular, master_file, sep = ",", row.names = FALSE, col.names = TRUE)
    print("Archivo maestro creado.")
  } else {
    # Si ya existe, anexamos sin repetir cabeceras
    write.table(nuevo_dato_tabular, master_file, sep = ",", row.names = FALSE, 
                col.names = FALSE, append = TRUE)
    print("Nuevas líneas añadidas al histórico.")
  }
  
  # Borrar el archivo temporal para no llenar el repo de basura
  file.remove(temp_file)
  
} else {
  stop("❌ Error en la descarga.")
}
