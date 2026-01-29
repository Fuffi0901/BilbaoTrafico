library(lubridate)
library(tidyr)
library(dplyr) 
library(httr2)
library(jsonlite)
library(sf) 
library(ggplot2)

# Sonómetros - mediciones
url_med <- "https://www.bilbao.eus/aytoonline/jsp/opendata/movilidad/od_sonometro_mediciones.jsp?idioma=c&formato=json"

# Sonómetros - ubicación
url_ubi <- "https://www.bilbao.eus/aytoonline/jsp/opendata/movilidad/od_sonometro_ubicacion.jsp?idioma=c&formato=geojson"

# Tráfico
url_traf <- "https://www.bilbao.eus/aytoonline/srvDatasetTrafico?formato=geojson"

sonometros_mediciones <- fromJSON(url_med)
head(sonometros_mediciones)

#Separamos Fecha y Hora
sonometros_mediciones <- separate(
  sonometros_mediciones,
  fecha_medicion,
  into = c("Fecha", "Hora"),
  sep = " "
)

#Renombramos la columna
sonometros_mediciones <- sonometros_mediciones %>%
  rename(Decibelios = decibelios)

sonometros_mediciones <- sonometros_mediciones %>%
  rename(Codigo = nombre_dispositivo)

#Formateamos las columnas para que tengan valores
sonometros_mediciones$Fecha <- ymd(sonometros_mediciones$Fecha)
sonometros_mediciones$Hora <- hms(sonometros_mediciones$Hora)
sonometros_mediciones$Decibelios <- as.numeric(sonometros_mediciones$Decibelios)



sonometro_ubicacion <- st_read(url_ubi)
sonometro_ubicacion$status <- as.integer(sonometro_ubicacion$status)
sonometro_ubicacion$deviceTypeId <- as.integer(sonometro_ubicacion$deviceTypeId)
sonometro_ubicacion$longitude <- as.double(sonometro_ubicacion$longitude)
sonometro_ubicacion$latitude <- as.double(sonometro_ubicacion$latitude)



trafico <- st_read(url_traf)

trafico$CodigoSeccion <- as.integer(trafico$CodigoSeccion)
trafico$Ocupacion <- as.integer(trafico$Ocupacion)
trafico$Intensidad <- as.integer(trafico$Intensidad)
trafico$Velocidad <- as.integer(trafico$Velocidad)

trafico <- separate(
  trafico,
  FechaHora                                               ,
  into = c("Fecha", "Hora"),
  sep = " "
)

trafico$Fecha <- ymd(trafico$Fecha)
trafico$Hora <- hms(trafico$Hora)


#install.packages("mapview")
#library(mapview)
# Mapa de la zona de Bilbao en la que se muestran los sonometros y las carreteras del dataset.
#mapview(trafico, zcol = "Intensidad", layer.name = "Tráfico") + 
 # mapview(sonometro_ubicacion, col.regions = "red", layer.name = "Sonómetros")



# Realizar la unión espacial
# Buscamos el índice del polígono más cercano para cada sonómetro
indices <- st_nearest_feature(sonometro_ubicacion, trafico)

# Creamos la unión basada en esos índices
resultado_final <- cbind(sonometro_ubicacion, st_drop_geometry(trafico)[indices, ])
resultado_final
sum(is.na(resultado_final))


hora_referencia_trafico <- trafico$Hora

mediciones_filtradas <- sonometros_mediciones %>%
  filter(Hora >= hora_referencia_trafico)

resultado_final <- mediciones_filtradas %>%
  inner_join(st_drop_geometry(resultado_final), by = c("Codigo" = "name", "Fecha" = "Fecha"))

# Verificamos el resultado
head(resultado_final)




resultado_final <- resultado_final %>%
  right_join(sonometros_mediciones,
            by = c("name" = "Codigo",
                   "Fecha" = "Fecha",
                   "Hora"  = "Hora"))


sum(is.na(resultado_final))

resultado_final <- resultado_final[ rowSums(is.na(resultado_final)) == 0, ]

sum(is.na(resultado_final))

resultado_final
ggplot(resultado_final, aes(x = Decibelios)) +
  geom_histogram(bins = 100) +
  theme_minimal() +
  ggtitle("Distribución de Decibelios")

ggplot(resultado_final, aes(y = Decibelios)) +
  geom_boxplot() +
  theme_minimal() +
  ggtitle("Boxplot de Decibelios (Outliers)")

ggplot(resultado_final, aes(x = name, y = Decibelios)) +
  geom_boxplot(outlier.alpha = 0.2) +
  coord_flip() +
  theme_minimal() +
  ggtitle("Decibelios por sensor")


mapview(trafico, zcol = "Intensidad",col.regions = hcl.colors(100, "YlOrRd"), layer.name = "Tráfico") + 
  mapview(resultado_final, zcol = "Decibelios", col.regions = hcl.colors(100, "Inferno"), layer.name = "Ruido (dB)")

