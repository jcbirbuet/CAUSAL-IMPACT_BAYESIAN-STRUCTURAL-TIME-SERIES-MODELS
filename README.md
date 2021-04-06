# CAUSAL-IMPACT_BAYESIAN-STRUCTURAL-TIME-SERIES-MODELS
El 28 de enero de 2021 a las 22:47:00 utc Elon Musk tuiteó y queremos determinar si esto tuvo un efecto sobre el precio de Dogecoin.

El desafío consiste en determinar si hubo un efecto causal y cuantificarlo. Para ello emplearemos un algoritmo desarrollado por Kay H Brodersen y que
está disponible en la librería CausalImpact de R.

Se trata de un enfoque de diferencias indiferencias pero aplicado a series de tiempo estructurales, donde además se emplea un método bayesiano para el
aprendizaje del modelo y la estimación del contrafactual

Este método mejora los que existían antes en dos aspectos: primero, proporciona una estimación de series de tiempo bayesiana para el efecto; segundo, 
porque utiliza promedios de distintos modelos (series de tiempo de otras criptomonedas) para construir el control sintético más apropiado para modelar 
el contrafactual.

Esta metodología es particularmente útil en este caso porque no estamos frente a un experimento controlado en el que se ha seleccionado aleatoriamente 
a un grupo que recibe el tratamiento, y a un grupo de control que es idéntico al primero excepto porque no recibió el tratamiento. Por ejemplo que Dogecoin
cotice en distintos mercados pero solo uno de ellos haya sido sometido al efecto del tweet.

Los diseños de DD son más limitados debido a que se basan en un modelo de regresión estático que asume datos idependientes e identicamente distribuidos a 
pesar de que el diseño tiene un componente temporal. Además, cuando se ajustan a datos correlacionados en serie los modelos estáticos producen inferencias 
muy optimistas con intervalos de incertidumbre muy estrechos.

En este caso, la variable de estudio es una serie temporal, por lo que el efecto causal de interés es la diferencia entre la serie observada y la serie 
que se habría observado si la intervención el tweet no hubiera tenido lugar.
