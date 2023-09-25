---
layout: post
title:  "Tests sociales"
date:   2023-09-04 09:00:00 +0200
author: hugo
categories: codium
read_time : 15
---

beneficios:

 menos tiempo definiendo mocks
 mas confianza
 menos posibilidad de errores de contrato
 menos tests a escribir
 mas resiliente a refactor
 
problemas:

 setups mas complejos
 el origen de un test fallido puede no ser tan claro
 
contexto:

 desarrollo front
 recepcion de datos desde API propia
 acomplamiento consciente a la API
 simplificacion de las capas ideales de hexagonal
 

test hyper-simplificados:
 
 testean un componente renderizado desde el test
 se omite el renderizado via router
 a veces se pasan los datos por props al componente 
 los enlaces se prueban espiando Router.push
    solo se prueba happy-path
    no se tienen en cuenta posibles redirecciones causadas por middlewares

mejoras que podemos hacer:

 testear como el usuario, el usuario no monta un componente, navega a una ruta
 al componente montado por la ruta no le llegan props, realiza sus peticiones a la API
 cuando el usuario hace click en un enlace, observamos la URL cambiada en el navegador
 
con estas mejoras nuestros test se parecen más a tests de aceptación, y soportan mejor el cambio de los detalles de implementacion.
puesto que testeamos usando el router como punto de entrada, podemos hacer TDD desde el inicio de la tarea hasta el final                  


limitaciones:

 * páginas embebidas en layouts que requieren llamadas API
 * listados con paginación o filtros