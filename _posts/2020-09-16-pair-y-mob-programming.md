---
layout: post
title:  "Pair y mob programming"
date:   2020-09-16 09:00:00 +0100
author: luis
categories: codium
feature_image: img/post-assets/pair-programming.jpg

read_time : 3
---
 
El pair programming es la acción de programar simultáneamente dos personas utilizando un mismo ordenador.

En Codium llevamos haciendo pairing muchos años y es una actividad que aplicamos en muchas partes: planificación estratégica, preparación de propuestas, reuniones con clientes, escritura de emails y, por supuesto, programación.

Ahora que en Codium somos más estamos experimentando, en nuestra colaboración con [Habitissimo](https://www.habitissimo.es), el mob programming en remoto y la verdad es que las sensaciones son muy buenas.

Una de las formas de definir el mob programming es más de dos personas resolviendo el un problema, al mismo tiempo, en un mismo lugar y en el mismo ordenador.

Tanto pair como mob programming tienen muchos **beneficios**, como por ejemplo:
- Mejora la calidad del resultado al haber tenido en cuenta múltiples puntos de vista y revisiones.
- Mejora la satisfacción del equipo al tener un resultado consensuado.
- Mejora la comunicación al promover la argumentación de los diferentes puntos de vista.
- Mejora las habilidades del equipo al aprender de las diferentes formas de hacer.
- Reduce las dependencias de una persona al haber siempre, al menos, otra que tiene ese conocimiento. Hace al equipo resistente a cambios por vacaciones, enfermedad o cambios en los integrantes.

Quizás **la principal pega podría** ser el coste ya que tienes a dos o más personas haciendo lo mismo. Para mí ocurre lo mismo que con TDD: lo importante no es el corto plazo sino el medio/largo plazo con todos los beneficios comentados anteriormente.

Sin un proceso de calidad acabaríamos teniendo muchos programadores introduciendo bugs sin parar. Sin un proceso de comunicación fluido acabaría sucediendo que hay muchos bloqueos porque sólo una persona es capaz de modificar ese código. Sin un proceso de homogeneización cada parte del código tendría un estilo diferente y costaría entenderlo y no sabríamos lo que se puede cambiar.

Para hacer pairing o mob hay algunas **recomendaciones básicas** como:
- Es un espacio seguro, donde expresarse y ser; no un lugar donde ser juzgado.
- El respeto hacia los demás: no criticar personas sino a las ideas y hacerlo de la forma más empática posible. 
- Cambiar quién está escribiendo para evitar que alguien tenga mucha influencia y otros desconecten.
- Buen espacio de trabajo. Si es en persona, un espacio donde no se moleste ni nos molesten e idealmente múltiples pantallas, teclados y ratones. Si es en remoto, sobre todo buena conexión a internet, la webcam encendida y un buen micrófono.

Me gustaría compartir **algunos trucos** que nos han funcionado bien:
- Hacer mini retrospectivas al finalizar la sesión (al menos las primeras veces con alguien nuevo) para comentar lo que ha ido bien y compartir todas aquellas cosas que se pueden mejorar.
- Tener una libreta donde apuntar posibles refactors, feedback para la retro, bugs que hemos encontrado, etc, con el objetivo de no estar continuamente interrumpiendo o cambiando el foco.
- Tener espacios para explorar a solas y compartirlo/discutirlo después.
- Hacer pausas periódicas.

Últimamente estamos experimentando con que el driver sea como una inteligencia artificial y se limite a escribir lo que digan los copilotos. Lo que buscamos es que el driver no vaya muy rápido haciendo y algún copiloto pueda desconectar.

Por último algunas cosas en las que varios miembros del equipo **han mejorado gracias al pairing/mob**:
- El valor de cuidar la experiencia del desarrollador: automatizar, documentar y acelerar los procesos que se repiten.
- Dar pasos más pequeños al desarrollar y vivir en verde (tener siempre los tests pasando).
- Sostener el dolor de ciertas decisiones. Ya sea porque otros compañeros no le ven beneficio o por hacer las cosas de una forma que no somos capaces de valorar.
- Los beneficios de diferentes tipos de testing (unitarios, de integración, de aceptación, más aislados, más sociables...) y ejecutados en diferentes momentos (mientras se desarrolla, antes de un commit, antes de un push, en la pipeline de forma aislada, en la pipeline después de desplegar staging…).

Como puedes ver, estamos muy satisfechos y contentos con el pairing y mob.

**Si no lo haces a menudo, ¿te animas a darle una oportunidad?**

<small>Imagen de la cabecera de [https://blog.galvanize.com/pair-programming-two-heads-better-one/fullstack-infographic-week-9-pair-programming-01-1/](https://blog.galvanize.com/pair-programming-two-heads-better-one/fullstack-infographic-week-9-pair-programming-01-1/)<small>
