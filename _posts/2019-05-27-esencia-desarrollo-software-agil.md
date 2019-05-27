---
layout: post
title:  "La esencia del desarollo de software ágil"
date:   2019-05-27 14:00:00 +0100
categories: codium
feature_image: post-assets/water

read_time : 5
---
 
En junio de 2018 [Martin Fowler](https://twitter.com/martinfowler) impartió 3 mini charlas en Madrid y hubo una slide que realmente me impactó:
 
![Responsive features slide](img/post-assets/martin-fowler.jpg)

Quizás fue por [sesgo de confirmación](https://es.wikipedia.org/wiki/Sesgo_de_confirmaci%C3%B3n) pero me pareció una forma muy elegante de plasmar en una transparencia la esencia de la agilidad.

Me impactó ver que, para él, **la piedra angular para ser ágil son los tests** automáticos.

Empezaremos con algunas definiciones para estar en la misma página:

- _Self-testing code_: Es el código que tiene tests que permiten validar su correcto funcionamiento sin intervención humana.
- _Refactoring_: Acción de cambiar el código sin cambiar el comportamiento observable para mejorar la calidad interna.
- _YAGNI_: Es una forma de pensar que buscar crear sólo las funcionalidades necesarias en este momento. Es el acrónimo de 'You Aren't Gonna Need It'. 
- _Calidad interna_: Es el estado del código fuente de un programa. Una baja calidad interna se traduce en más dificultad para los programadores de hacer su trabajo y en una mayor probabilidad de errores.
- _Integración continua_: Es una práctica que consiste en compartir los cambios hechos por cada desarrollador con el resto de compañeros al menos una vez al día. Está muy relacionado con [Trunk based development](https://trunkbaseddevelopment.com/).
- _Entrega continua_: Es una forma de desarrollar software en iteraciones cortas que busca que el software se pueda poner en producción en cualquier momento. No confundir con [despliegue continuo](https://en.wikipedia.org/wiki/Continuous_deployment).
- _Funcionalidades adaptables_: Facilidad de cambiar el comportamiento de una aplicación añadiendo, modificando o eliminando funcionalidades.


## ¿Por qué el código auto testeado facilita el refactoring?
Cuando llego a un código que me parece complejo de entender mi cuerpo me suele perdir hacer un poco de limpieza. Sin embargo se encuentra con el freno que supone el riesgo de introducir fallos.

Los tests me permiten darme cuenta si cometo algún error mientras estoy haciendo refactoring. Es ese feedback rápido el que me da seguridad. 

Si tengo un harnés de tests, que garantizan que el código se comporta como espero, puedo hacer refáctorings más profundos. Cambios como cambiar la firma de los métodos, extraer comportamiento a colaboradores para reusarlo, borrar código, actualizar versiones, reemplazo de librerías...

Por el contrario, si no tengo un harnés de tests tiendo a hacer refáctorings suaves. Por ejemplo aquellos que confío que el IDE hace bien: rename, extract, move method...

Es la seguridad que me dan los tests la que hace que el software sea más moldeable.

## ¿Por qué el código auto testeado facilita la integración continua?
Jordi siempre cuenta una anécdota de una empresa en la que dedicaban dos semanas de un período de 3 meses a poner en común el trabajo hecho por los miembros de los equipos. Esas semanas eran, con diferencia, las más duras porque no funcionaba nada y había mucha presión por entregar.

Por otro lado recuerdo cuando, utilizando SVN, un compañero o yo, hacíamos commit y alguien dejaba de poder trabajar porque se había introducido un bug.

También ocurre a algunas empresas que tienen un proceso de pruebas manuales muy extensivo, con el coste en tiempo y dinero que supone. ¿Acaso se pueden permitir estar probando varias veces al día que todo sigue funcionando?

Los tests nos permiten validar que el software cumple con los requisitos para los que fue diseñado. De esta forma sabemos que no vamos a interrumpir ni estropear el trabajo de otro compañero.

Al tener esta seguridad, podemos estar constantemente compartiendo nuestro trabajo.

## ¿Por qué la integración continua facilita el refactoring?
Imaginemos que cambiamos el nombre a un método y cambiamos todos los sitios donde se usa. Si otro desarrollador que todavía no tiene esos cambios lo utiliza habrá conflicto al hacer integrar los cambios.

Cuanto más tiempo pase entre integraciones, mayores probabilidades habrá de conflictos. Además éstos serán más difíciles de resolver.

Por eso, hacer integración continua conlleva que el refactor sea más barato y menos estresante, ya que los conflictos se detectan rápidamente y son más fáciles de resolver.

## ¿Por qué el refactoring mejora la calidad interna?
Un refactoring, en esencia, es un cambio del código que busca mejorar la calidad interna del código.

Otro tema es que haya refáctorings que no reduzcan complejidad, ni mejoren la comprensión del software, ni que preparen el código para abordar nuevos retos. Para mí, esos no es refactorizar el código es complicarlo.

## ¿Por qué el refactoring habilita el YAGNI?
Si tu software es moldeable es más fácil añadir funcionalidades después.

Poder añadir funcionalidades después permite simplificar y post poner los desarrollos.

Simplificar permite entregar antes y reducir la complejidad.

Un código más simple suele tener mejor calidad interna.

## ¿Por qué la integración continua habilita la entrega continua?
Este es el punto que menos soy capaz de unir pues, en mi opinión, falta una pieza clave para tener el software siempre en un estado que sea desplegable y son las [feature toogles](https://martinfowler.com/articles/feature-toggles.html).

Si queremos poder desplegar teniendo una funcionalidad a medias, tenemos que ser capaz de activarla y/o desactivarla a nuestra voluntad. Con eso separamos el desarrollo del software de cuándo se entrega a los usuarios.

Teniendo siempre la última versión del código de todos los desarrolladores y la posibilidad de activar o no determinadas partes hace que podamos desplegar en cualquier momento.

## ¿Por qué la calidad interna y la entrega continua habilitan tener funcionalidades adaptables?
Tener una buena calidad interna permite que el software sea moldeable, que sea fácil de entender y de cambiar.

Tener el software siempre listo para desplegar hace que una vez una funcionalidad esté terminada pueda ser entregada a los usuarios. Evita bloqueos porque hay funcionalidades a medias que romperían la experiencia de usuario.

Por lo que si el software es fácil de cambiar y se puede obtener valor tan pronto como esté terminado conseguimos **la esencia del desarrollo ágil: adaptabilidad**.
