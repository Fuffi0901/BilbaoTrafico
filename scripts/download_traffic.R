library(httr2)

url_traf <- "https://www.bilbao.eus/aytoonline/srvDatasetTrafico?formato=geojson"
timestamp <- format(Sys.time(), "%Y%m%d_%H%M")
filename <- paste0("data/trafico_", timestamp, ".geojson")

# Descarga el archivo
request(url_traf) %>%
  req_perform(path = filename)

print(paste("Guardado:", filename))