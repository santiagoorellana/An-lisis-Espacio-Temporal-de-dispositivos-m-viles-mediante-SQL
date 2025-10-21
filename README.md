<h1>Análisis Espacio-Temporal de dispositivos móviles mediante SQL</h1>

<p>Los dispositivos móviles constituyen un objeto de estudio importante en la actualidad y A partir de la detección y procesamiento de las señales provenientes de los dispositivos móviles se pueden obtener informaciones relevantes para la seguridad y control tecnológico. Los dispositivos móviles utilizan sistemas y protocolos de comunicación en los cuales el transmisor se identifica frente a los posibles receptores con una cadena de caracteres o un número, único para cada dispositivo.
Los sistemas de monitoreo que leen la información que es trasmitida por los dispositivos móviles que se encuentran en un área de cobertura cercana, pueden guardar la fecha y hora de la detección de las señales además de otras informaciones referentes a la señal. Al conocer además la ubicación geográfica del sistema de monitoreo en cada instante de tiempo, se hace posible entonces la realización de un análisis Espacio-Temporal. 
En el presente trabajo se proponen funciones SQL que permiten realizar comparaciones aproximadas en las dimensiones tiempo y espacio y consultas para realizar el análisis Espacio-Temporal.</p>


<h2>Análisis Espacio-Temporal propuesto</h2>
<p>Es importante conocer que las Lecturas de las señales que transmiten los dispositivos móviles pueden ser clasificadas como:</p>

•	Provocadas: Cuando el sistema de monitoreo decide en que momento leer la señal, lo cual supone que la señal está disponible en cada instante.
•	Eventuales: Cuando el sistema de monitoreo lee la señal solamente cuando esta aparece.

<p>Las lecturas pueden durar fracciones de segundos o ser prolongadas en el tiempo hasta varios minutos. Para realizar un análisis espacio-temporal de las lecturas de los sistemas de monitoreo, se necesitan al menos:</p>

•	Identificación: (Quién) Cadena o número que identifica al dispositivo.
•	Tiempo: (Cuando) Fecha y hora de la lectura. También se puede utilizar la duración.
•	Espacio: (Donde) Coordenadas o nombre del emplazamiento del Sistema de Monitoreo.

<p>Se necesita además almacenar las lecturas en una Base de Batos, en la cual se encuentre una tabla de lecturas, que debe tener al menos tres campos para la Identificación del dispositivo y las componentes Temporal y Espacial, siendo cada registro de esta tabla una lectura realizada por el sistema de monitoreo. Luego sobre la Base de Datos se podrán realizar los siguientes análisis espaciotemporales de interés:</p>

•	Análisis de presencia: Permite conocer qué dispositivos estuvieron en un lugar específico a una fecha y hora específica. 
•	Análisis de ubicación: Para conocer los lugares en los que ha estado un dispositivo.
•	Análisis de coincidencias: Permite encontrar las coincidencias entre dispositivos a partir del lugar, fecha y hora. Es decir, que dado un dispositivo A, muestra los dispositivos que han estado junto con A en el mismo lugar y al mismo tiempo. Se pueden buscar coincidencias entre dos dispositivos o entre grupos de dispositivos. También se pueden buscar todas las coincidencias de un determinado dispositivo con respecto a todos los de la base de datos. 

<p>En la implementación de los análisis espaciotemporales inciden situaciones propias de los fenómenos de la vida real, por ejemplo: Dos lecturas realizadas en un mismo lugar por diferentes Sistemas de Monitoreo no tienen necesariamente las mismas coordenadas. También sucede que si un dispositivo emite una señal y otro dispositivo cercano le contesta con otra señal, las lecturas de ambas señales tendrán tiempos diferentes, y esto puede conducir a interpretar erróneamente que los dispositivos no han coincidido en el tiempo. 
Teniendo en cuenta esto, la implementación del análisis espaciotemporal debe realizar comparaciones aproximadas, que utilicen umbrales de tolerancia establecidos por el usuario. Por ejemplo: Si dos lecturas tienen coordenadas separadas por una distancia inferior o igual a 20 metros, puede asumirse que están en el mismo lugar o área. También se aplica con el tiempo de las lecturas, al asumir que dos dispositivos han coincidido en el mismo espacio y tiempo, si la diferencia temporal entre la detección de de las señales de ambos es inferior o igual a 5 minutos.
En la práctica, los umbrales de tolerancia espacial y temporal deben ser ajustados teniendo en cuenta principalmente: El nivel de precisión que se quiera lograr, el error introducido por el sistema de monitoreo y sus algoritmos, los errores de propagación para las frecuencias de trabajo de los dispositivos y la cantidad de lecturas por unidades de tiempo. Se han realizado pruebas con sistemas que realizan hasta cientos de lecturas por minuto y con otros que realizan de una a doce lecturas por horas, pudiéndose determinar que mientras más escasas son las lecturas, mayores deben ser las tolerancias permitidas en las comparaciones, con una consecuente pérdida de precisión en los resultados.
Otro problema que se enfrenta es la dificultad algorítmica, la cual tienta a utilizar ciclos y condicionales para la solución de los mismos. En el presente trabajo se tuvo como premisa implementar las operaciones de análisis espaciotemporales mediante las consultas del tipo SELECT-FROM-WHERE, dejándole la optimización de las búsquedas al gestor de las bases de datos. Esto es importante para la portabilidad de las consultas entre diferentes gestores de bases de datos.</p>

<h2>Implementación experimental del análisis espacio-temporal propuesto</h2>
<p>Para la realización de la presente investigación se implementó en una base de datos MySQL una tabla llamada “lecturas” con los siguientes campos:</p>

<h2>Descripción de los campos de la tabla </h2>
Campo	Tipo	Descripción
numero_de_lectura	Int	 Identificador de la lectura (Campo llave)
id_dispositivo	text	 Identificador del dispositivo.
fecha_hora	datetime	 Fecha y hora de realización de la lectura.
nombre_de_lugar	text	 Nombre para identificar el lugar de lectura.
longitud	double	 Longitud de la coordenada en WGS84
latitud	double	 Latitud de la coordenada en WGS84

<p>Con el objetivo de probar la implementación de los análisis espaciotemporales de interés, la tabla fue llenada con varias lecturas ficticias, supuestamente realizadas en diferentes lugares de Alamar y Bacuranao, en el municipio Habana del Este. Los dispositivos son ficticios y los datos fueron seleccionados con mucho cuidado, teniendo en cuenta además que las coordenadas sean coherentes con los nombres de los lugares declarados. Para las comparaciones aproximadas se implementaron dos funciones SQL que se describen a continuación:</p>

Nombre de función: minutos_entre
Parámetros de entrada: 
FT1: Fecha y hora de A. Es un valor tipo “datetime”.
FT2: Fecha y hora de B. Es un valor tipo “datetime”.
Salida: Minutos de diferencia entre los dos valores de fecha y hora.

 <img width="475" alt="minutos entre" src="https://github.com/user-attachments/assets/7e568f5f-fd8d-4ee1-8679-382df7047bdb" />
<p>Figura 1. Implementación en SQL de la función llamada “minutos_entre”.</p>

Nombre e función: metros_entre
Parámetros de entrada: 
X1: Longitud de la coordenada de A en WGS84. Es un valor tipo “double”.
Y1: Latitud la coordenada de A en WGS84. Es un valor tipo “double”.
X2: Longitud de la coordenada de B en WGS84. Es un valor tipo “double”.
Y2: Latitud la coordenada de B en WGS84. Es un valor tipo “double”.
Salida: Metros de distancia entre las coordenadas de A y B.

<img width="551" height="511" alt="metros entre" src="https://github.com/user-attachments/assets/8c221c00-ed85-443f-be54-faec73268559" />
<p>Figura 2. Implementación en SQL de la función llamada “metros_entre”.</p>

<p>La función “metros_entre” se implementó experimentalmente utilizando las fórmulas de Bessel, asumiendo que la tierra es perfectamente esférica y que cada grado equivale a 111,302 Km, lo cual introduce pequeños errores en los cálculos de distancia de hasta 2.5%. Finalmente se decidió implementar mediante la fórmula Haversine que tiene errores más pequeños de 0.25%. Para mayor exactitud, se podría utilizar el método de Vincenty inverso, el cual tiene un error menor a 0.01 metros, pero al ser un algoritmo iterativo, este haría más compleja la implementación de la función y traería más demoras en las operaciones de búsqueda. Por esa razón se decidió por el método Haversine que es más sencillo de implementar y rápido en su ejecución.
Las funciones “minutos_entre” y “metros_entre” fueron almacenadas en la base de datos MySQL y utilizadas para la implementación de los análisis espaciotemporales de interés se describen a continuación. </p>

<h2>Análisis de ubicación:</h2>
<p>La implementación en SQL de la consulta es muy simple, ya que solamente necesita como valor de búsqueda el identificador del dispositivo. En la figura se muestran los valores de búsqueda en amarillo.</p>

<img width="566" alt="ubicacion" src="https://github.com/user-attachments/assets/7b090933-589b-43af-a418-23222ce4abd5" />
<p>Fingura 3. Implementación en SQL del “Análisis de ubicación”.</p>

<h2>Análisis de presencia: </h2>
<p>Esta consulta emplea las funciones “metros_entre” y “minutos_entre” para realizar las comparaciones aproximadas. Los valores de búsqueda se resaltan en amarillo y se utilizan para indicar las coordenadas del lugar, la fecha y la hora que deben tener las lecturas que se desean buscar. En el ejemplo, el valor 50 es el umbral de distancia en metros para la comparación de las coordenadas. El valor 5 es el umbral de tiempo en minutos.</p>

<img width="668" alt="presencia" src="https://github.com/user-attachments/assets/ac55aa96-c5f5-4662-89f5-b2e018ef4998" />
<p>Figura 4. Implementación en SQL del “Análisis de presencia”.</p>

<p>Este tipo de análisis espaciotemporal puede realizarse empleando el nombre de los lugares en vez de las coordenadas, pero con la desventaja de ser menos preciso. Además, se pueden dar problemas tales como que un lugar tenga más de un nombre. </p>

<h2>Análisis de coincidencias: </h2>
<p>A continuación se muestra un ejemplo de la implementación del “Análisis de coincidencias entre dos dispositivos”. Los valores de búsqueda son los identificadores de los dispositivos y los umbrales de comparación aproximada.</p>

<img width="706" alt="coincidencia" src="https://github.com/user-attachments/assets/7e32f490-4b62-4ebf-bfad-d7c0d1ea60c8" />
<p>Figura 5. Implementación en SQL del “Análisis de coincidencia entre dos dispositivos”.</p>

<p>Para el “Análisis de Coincidencias Entre Dos Grupos de Dispositivos” se podrá utilizar la misma función, pero con una modificación, tal como se muestra a continuación:</p>

<img width="661" alt="coincidencia grupos" src="https://github.com/user-attachments/assets/6bf2a6f4-f4c8-4933-9c9d-52689995bb6a" />
<p>Figura 6. Implementación SQL del “Análisis de coincidencia entre dos grupos de dispositivos”.</p>

<p>En la consulta de la figura 6, se puede ver que los valores de búsqueda son dos listas de dispositivos los cuales se pasan a la consulta como dos conjuntos, por lo que se puede asumir que el “Análisis de Coincidencias Entre Dos Dispositivos” es un caso particular del “Análisis de Coincidencias Entre Dos Grupos de Dispositivos”.
Otra operación de análisis de coincidencia espacio-temporal es contar las coincidencias de un dispositivo con respecto a todos los de la base de datos. Esta consulta solamente requiere que se le indique el identificador del dispositivo de interés y los umbrales de tolerancia espacial y temporal. Su implementación es la que se muestra seguidamente:</p>

<img width="811" alt="coincidencias conteo" src="https://github.com/user-attachments/assets/f92195e3-8edf-4b9e-8fd3-37feaacd5ed9" />
<p>Figura 7. Implementación SQL del “Análisis de coincidencia entre un dispositivo y todos los de la base de datos”.</p>

<p>La implementación de los análisis espacio-temporales mediante consultas SQL puede agilizar el trabajo de análisis, pero son muy complejas de entender para los usuarios que no tienen conocimientos profundos en el campo de la informática. Todas los operaciones anteriormente presentadas fueron implementadas como procedimientos almacenados en la base de datos MySQL, con lo cual se le ahora al usuario de la base de datos el tener que entender y escribir repetidas veces las consultas que utiliza. 
También es importante resaltar que, las consultas han sido presentadas en su expresión más simple, pero es posible aumentar la cantidad de campos a mostrar y hacer más complejas las condiciones de filtrado y hacer prefiltrado cuando se trabaje con bases de datos muy extensas. 
Dada la complejidad de las consultas presentadas y de las que se deriven de estas, lo más razonable podría ser la implementación de un programa especializado en el análisis espacio-temporal de las bases de datos, mediante el cual el usuario pueda realizar las consultas de manera sencilla, mediante un formulario que le facilite la introducción y validación de parámetros tales como coordenadas geográficas, fechas, horas y listas de dispositivos.
Al utilizar las consultas, es importante que se tenga cuidado en la selección de los umbrales de tolerancia, que deben estar en correspondencia principalmente con los niveles de precisión del sistema de monitoreo y con la cantidad de lecturas por unidades de tiempo.</p>

