##### Impacto del Tweet de Musk sobre la cotuzación de Dogecoin ######
library(dplyr)
library(riingo)
library(ggplot2)
library(CausalImpact)
library(magrittr)
library(tidyverse)
library(lubridate) 
library(scales)   
library(gridExtra)
library(quantmod)
# 0 Nos conectamos a las bases de datos de riingo 
riingo_set_token(token= "a3db2cbda9081225835e5a356e00769f7abe640f", inform = TRUE)

# 1 establecemos las fechas para el análisis
start_analysis <- as.POSIXct('2021-01-28 11:00:00 UTC', tz = 'UTC')
end_analysis <- as.POSIXct('2021-01-29 01:00:00 UTC', tz = 'UTC')
tweet_doge <- as.POSIXct('2021-01-28 22:47:00 UTC', tz = 'UTC')
#end_analysis <- as.POSIXct('2021-01-29 11:53:00 UTC', tz = 'UTC')
# 1 Obtenemos los datos de bitcoin (contrafactual) y de dogecoin 

# obtenemos Dogecoin en usd 
doge <- riingo_crypto_prices(
  'dogeusd', start_date = start_analysis,
  end_date = end_analysis, resample_frequency = '1min'
) %>% mutate(crypto = 'Dogecoin')

# obtenemos datos de Bitcoin, Litecoin, Cardano y Ethereum también en usd, estas series se emplearán para construir el contrafactual

bit <- riingo_crypto_prices(
    'btcusd', start_date = start_analysis, # si se quiere en euros es btceur 
    end_date = end_analysis, resample_frequency = '1min'
  ) %>% mutate(crypto = 'Bitcoin')
  
lite <- riingo_crypto_prices(
  'ltcusd', start_date = start_analysis,
  end_date = end_analysis, resample_frequency = '1min'
) %>% mutate(crypto = 'Litecoin')

cardano <- riingo_crypto_prices(
  'adausd', start_date = start_analysis,
  end_date = end_analysis, resample_frequency = '1min'
) %>% mutate(crypto = 'Cardano')

ethereum <- riingo_crypto_prices(
  'ethusd', start_date = start_analysis,
  end_date = end_analysis, resample_frequency = '1min'
) %>% mutate(crypto = 'Ethereum')

  
# 2 juntamos las bases manteniendo únicamente las columnas donde hay datos tanto de dogecoin como de las otras criptomonedas
# para esto se agrupa los datos por fecha y hora, luego se crea una columna "crypto" que toma valores n = 1 o n = 2, siendo 1 
# cuando la cotización en esa fecha y hora es solo de una de las criptomonedas, y 2 cuando en esa fecha y hora se transaron 
# ambas criptomonedas, luego se filtra la base para n=2 y de esa manera se obtiene una base que contiene transacciones en 
# fecha y hora exactamente iguales.

datos <- full_join(doge, bit) %>% 
  full_join(., lite ) %>% 
  full_join(., cardano) %>% 
  full_join(., ethereum) %>% 
    group_by(date) %>% 
    mutate(
      n = n(),
      precio = close,
      crypto = factor(crypto, levels = c('Dogecoin', 'Bitcoin', "Litecoin", "Cardano", "Ethereum"))
    ) %>% 
    filter(n == 5) %>% 
  as.data.frame() %>%
  dplyr::select(date, crypto, precio) 

datos_final <- spread(datos, key = crypto, value = precio) %>% dplyr::select(Dogecoin, Bitcoin, Litecoin, 
                                                                             Cardano, Ethereum, date)
rownames(datos_final) <- datos_final$date 
datos_final$date <- NULL

# 3 se ajusta el modelo
#elon_tweet_doge <- which(tiempo == tweet_doge) # se elige el momento del tweet como punto de corte

tiempo <- datos$date %>% unique() 

elon_tweet_doge <- which(tiempo == tweet_doge)
periodo.anterior <- c(1,313)
periodo.posterior <- c(314, 401)

#periodo.anterior <- c(1,317)
#periodo.posterior <- c(318, 800)

modelo_doge <- CausalImpact(datos_final, periodo.anterior, periodo.posterior)

summary(modelo_doge, "report")
summary(modelo_doge)
# 4 graficos
plot(modelo_doge)

plot(modelo_doge, 'original') +
  xlab('Tiempo') +
  ylab('Precio (USD)') +
  ggtitle('Tweet de Musk sobre Dogecoin (28 de enero)') 

# 5 creamos una funcion para normalizar 
normalizar <- function(x) {(x - mean(x)) / sd(x)}

doge_norm <- normalizar(datos_final$Dogecoin)
bit_norm <- normalizar(datos_final$Bitcoin)
lite_norm <- normalizar(datos_final$Litecoin)
cardano_norm <- normalizar(datos_final$Cardano)
ethereum_norm <- normalizar(datos_final$Ethereum)

base_norm <- as.data.frame(cbind(doge_norm, bit_norm, lite_norm, cardano_norm, ethereum_norm)) %>%
  mutate(tiempo = as.POSIXct(tiempo))

# 6 Gráficos

# 6.1 Gráfico de la serie de tiempo de Dogecoin
ggplot(base_norm) + geom_line(aes(tiempo, doge_norm), color = "black") + 
  xlab('Tiempo') +
  ylab('Precio (USD)') +
  ggtitle('Evolución de precios de las Dogecoin') +
  geom_vline(xintercept = tweet_doge)

# 6.2 Gráfico con todas las series de tiempo
ggplot(base_norm) + 
  geom_line(aes(tiempo, doge_norm), color = "black", size = 1.5) + 
  geom_line(aes(tiempo, bit_norm), color = "red") + 
   geom_line(aes(tiempo, lite_norm), color = "#A43E58") + 
  geom_line(aes(tiempo, cardano_norm), color = "#3E83A4") + 
  geom_line(aes(tiempo, ethereum_norm), color = "#593EA4") + 
    xlab('Tiempo') +
  ylab('Precio (USD)') +
  ggtitle('Evolución de precios de las dos criptomonedas') +
  geom_vline(xintercept = tweet_doge)


