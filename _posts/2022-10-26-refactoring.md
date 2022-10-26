---
layout: post
title:  "Refactoring"
date:   2022-10-26 08:00:00 +0100
author: jose
categories: codium
feature_image: post-assets/refactoring-webstorm

read_time : 6
---

He estado programando en JS durante casi 7 años, y si hay algo que aprendí estos últimos años, es que la legibilidad y la simplicidad son la clave para un código sostenible y mantenible. Hoy veo la refactorización como herramienta útil para conseguir ese objetivo.

> Refactoring a change made to the internal structure of software to make it easier to understand and cheaper to modify without changing its observable behavior

A medida que profundizaba en los conceptos de refactoring, y sobre todo en los refactorings automáticos, nacían dentro de mí nuevas necesidades.

Soy un usuario de editores de código (pasé de Sublime Text a VS Code) por tanto al intentar aplicar ciertos refactorings, se me estaba quedando bastante corto. Por mucho que instalara extensiones que me permitiesen potenciar o automatizar procesos, seguían sin satisfacer mis necesidades.


Quiero dejar claro que este post no es un post comparativo del rollo IDE vs editores, sino más bien, compartir mi experiencia de cómo cambió mi manera de desarrollar al dar el paso a un IDE (WebStorm).


<i>Si eres usuario de VS Code, al final de éste post, te compartiré algunas extensiones que para mi son un must-have que te ayudarán en tu día a día.</i>

## Renaming

Nos permite darle un nuevo nombre a variables, funciones, clase o método.

A mí personalmente, me gusta que el nombre del fichero esté alineado con la función/clase que exporta. Por tanto, si cambio el nombre de la función o clase, debo renombrar también el nombre del fichero.

Ejemplo:
Imagínate que tenemos como regla dentro del equipo que todo el código que escribimos debe estar en inglés. Al navegar por el código nos encontramos con un componente que se llama Botón.


```javascript
// Boton.tsx
export function Boton(props: {children: React.ReactNode, onClick: () => void}) {
 return <button onClick={props.onClick}>{props.children}</button>
}
```

Si aplicamos <a href="https://martinfowler.com/bliki/OpportunisticRefactoring.html">Opportunistic Refactoring</a> para renombrar tanto el componente como el fichero, hacerlo a mano puede implicar mucho trabajo, ya que deberíamos:

- Buscar sus usos y sustituirlo uno por uno
- Renombrar el fichero
- Cambiar los imports

Y dependiendo del tamaño de la base de código, podría llevarnos tiempo realizar el cambio.

Ésto lo podemos hacer de manera automática y delegar ese trabajo al editor.

<iframe class="video" src="https://www.youtube.com/embed/4eg0ijD6cjg" title="Refactoring - Rename Component" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>


## Extract variable or extract to method

O mejor… extraer a un componente

Nos podemos encontrar con lógica que es complicada de entender o que está duplicada en varias partes del código. El refactor `extract-to-variable` o `extract-to-method` nos puede ayudar a lidiar con ese problema.


<iframe class="video" src="https://www.youtube.com/embed/iXuAOcaDSek" title="Refactoring - Extract variable or method" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## Flip if-else

Nos permite invertir el sentido de una lógica. Super útil y sobre todo cuando queremos simplificar if-else aplicando las cláusulas de guarda.

<iframe class="video" src="https://www.youtube.com/embed/CvsPATswRvU" title="Refactoring - Invert if else statements" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>


## Change function signature

Con éste refactoring podríamos:
- Reordenar parámetros
- Añadir nuevos parámetros dándole valores por defecto y/o añadir el argumento en todos aquellos puntos dónde se está utilizando la función/método
- Eliminar parámetros

Ésta es una de las que más me voló la cabeza (junto a inline-method que veremos más adelante).

<iframe class="video" src="https://www.youtube.com/embed/mfhxPVZOFpI" title="Refactoring - Change Signature" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## Change method name

Este refactor para algunos podría parecer una tontería pero para alguien como yo, que viene del sufrimiento puro por hacer los cambios de manera manual, el hecho de tenerlo automatizado, me permitió centrarme en darle un mejor nombre al método para así reflejar lo que realmente hace y dejar de pensar tanto en <i>qué partes del código debo de aplicar los cambios.</i>

No lo he juntado con el refactor Renaming ya que considero que merece su propio apartado…


<iframe class="video" src="https://www.youtube.com/embed/LFygWE1MLZs" title="Refactoring - Rename method" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## Inline

Éste refactor nos permite reemplazar una referencia de una variable o método por su contenido. Para mí vale oro este refactor combinandolo con la de extract.
Para ver el valor, empecemos a sufrir. Imaginad por un momento que tenemos un custom hook que se utiliza por toda nuestra aplicación.

```javascript
const [count, add] = useCount(0, 1, 10, () => {
 console.log('Counter starts again...');
});
```

```javascript
function useCount(
  initialValue: number,
  toAdd: number,
  limit: number,
  onReset: () => void
) {...}
```

Éste custom hook recibe los siguientes parámetros:
- `initialValue`: valor inicial del contador
- `toAdd`: valor a sumar. Puede ir el contador de 1 en 1 o de 10 en 10…
- `limit`: máximo que puede llegar el contador
- `onReset`: callback cuando se resetea el contador

Ahora bien, queremos cambiar el contrato de éste custom hook. En vez de tener n parámetros, queremos encapsular esos parámetros en un objeto.

Queremos llegar a una definición así:

```javascript
export function useCount(obj) {
 const [value, setValue] = useState(obj.initialValue)
 ```

Dónde su uso quede de la siguiente manera:

```javascript
const [count, add] = useCount({
 initialValue: 0,
 toAdd: 1,
 limit: 10,
 onReset: () => {
   console.log('Counter starts again...');
 }
});
```

Reemplazarlo en todos los puntos dónde se esté utilizando este custom hook podría ser una tarea muy aburrida o que acabemos con un tremendo dolor de cabeza.

Pero… ¿Podemos aplicarlo de manera automática? Sí!, combinando los refactorings anteriores e introduciendo el Inline :)


<iframe class="video" src="https://www.youtube.com/embed/NDS_yNGyOgM" title="Refactoring - Inline variable or function" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

## VS Code


Visual studio code por defecto tiene una serie de refactors automáticos (y aparecen más si trabajas con TS) pero son escasos y a veces poco potentes.

Te dejo algunas extensiones super útiles para favorecer el refactoring

- <a href="https://marketplace.visualstudio.com/items?itemName=nicoespeon.abracadabra">Abracadabra:</a> Permite automatizar ciertos refactorings. Lo malo es que sólo es compatiable con JavaScript y Typescript. Si te interesa ver abracadabra en acción, puedes. Si te interesa ver abracadabra en acción, puedes ver mi charla en MadridJS.
- <a href="https://marketplace.visualstudio.com/items?itemName=p42ai.refactor">P42:</a> Tiene varias opciones de refactoring (algunas parecidas a la de Abracadabra) que nos permite aplicar refactor de manera más segura utilizando las últimas funcionalidades de JS.
- <a href="https://marketplace.visualstudio.com/items?itemName=NuclleaR.vscode-extension-auto-import">Auto import:</a> De Auto importa los ficheros, métodos o clases.

Aunque existen muchos otros refactorings que utilizo en mi día a día, espero que este artículo te haya servido para que te introduzcas aún más el refactor en tu día a día.

Si quieres profundizar más sobre Refactor, en Codium disponemos de un Curso de donde trabajamos refactorizando <a href="https://www.codium.team/curso-legacy-code.html">código legacy </a>y otro donde refactorizamos el código aplicando <a href="https://www.codium.team/curso-refactoring-a-patrones.html">patrones de diseño</a> que permitirán revolucionar tu forma de programar.
