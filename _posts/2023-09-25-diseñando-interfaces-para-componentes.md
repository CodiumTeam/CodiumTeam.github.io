---
layout: post
title:  "Diseñando interfaces para componentes"
date:   2023-09-25 09:00:00 +0200
author: hugo
categories: codium
feature_image: post-assets/components-interface-design
feature_credit: Foto por Saad Salim
---

Si pudiera resumir la clave para diseñar mejores componentes (refiriéndome a componentes web como los de React o Vue), diría que sin duda alguna, la clave es **hacer más con menos**.

Recientemente, he trabajado en un proyecto donde he encontrado algunas veces que componentes que aparentemente resuelven una necesidad que tengo, lo hacen de tal manera que me obligan a adoptar funcionalidades que no necesito, o me obligan a pasar varios flags para deshabilitar esas funcionalidades.

Esto me ha hecho reflexionar sobre las diferentes formas en las que podemos afrontar el diseño de la interfaz pública de un componente y cuáles son las características que hacen un diseño mejor o peor.

Ilustraré los ejemplos con Vue, pero los patrones que explicaré también son aplicables a otras librerías como React y Angular.

## Preferir slots sobre propiedades para pasar contenido

En el contexto de los proyectos en los que he trabajado he detectado cierta tendencia a favorecer las propiedades del componente sobre los slots a la hora de pasar contenido. El problema con las propiedades es que son bastante rígidas y nos dan problemas cuando queremos pasar contenido que va más allá de un simple string.

Un ejemplo de componente que sufre de rigidez podría ser este componente `<Alert>` usado para mostrar mensajes de importancia:

{% raw %}
```vue
<script setup>
const props = defineProps({
    'title': {
      type: String,
      required: true,
    },
    'description': {
      type: String,
      required: true,
    },
});

const visible = ref(true);
</script>

<template>
  <div class="alert" v-if="visible">
    <span class="alert__title">{{ props.title }}</span>
    <span class="alert__description">{{ props.description }}</span>
    <span class="alert__dismiss" @click="visible=false">X</span>
  </div>
</template>
```
{% endraw %}

Y que sería usado de la siguiente manera:

```vue
<alert title="Warning!" description="Oops, something unexpected happened"/>
```

Para pintar algo como esto:

<img class="centered" src="/img/post-assets/component-interfaces/alert-example-1.png" alt="Se muestra una caja amarilla con el mensaje de alerta en cuestión"/>

### Vienen los problemas

A priori podría parecer una buena interfaz, seguro que cuando creamos el componente teníamos un par de ejemplos que nos proporcionó diseño que nos hizo pensar que los Alert siempre iban a constar de un título y una descripción compuestos por simples strings. La cuestión es que dentro de no mucho nos pasaran nuevos diseños en los que de repente las cosas habrán cambiado, y se querrán usar negritas dentro del mensaje, o incluir un enlace de ayuda, o mostrar alertas sin título por ejemplo.

<img class="centered" src="/img/post-assets/component-interfaces/alert-example-2.png" alt="Se muestra una caja amarilla con un mensaje de alerta similar, esta vez incluyendo un enlace en el texto"/>

¿Podría ser que se adapte la interfaz del componente a lo que necesitamos? Tal vez podríamos definir que el campo title no es obligatorio, con eso resolveríamos por lo menos el problema de tener un Alert sin título. Pero, ¿cómo podemos resolver el problema con el mensaje que usa negritas o un enlace?

Algo como lo siguiente no sería válido:

```vue
<alert
    title="Warning"
    description="Oops! something unexpected happened, <a href=''>contact support</a> for help."
/>
```

Si hiciéramos algo así el resultado no sería el esperado, podríamos usar la directiva `v-html` dentro del componente para anular el escapado de html y aparentemente solucionar el problema, pero crearíamos un problema de seguridad adicional en los lugares donde este componente se use junto con contenido obtenid de una fuente no confiable, como por ejemplo un input de usuario. Miremos el siguiente ejemplo:

```vue
<alert title="Oops" description="`La búsqueda de '${searchInput}' no produjo resultados`"/>
```

En este caso se ha utilizado el componente Alert para indicar que la búsqueda de unos términos introducidos por el usuario no ha producido resultados. El problema es que como activamos la directiva `v-html` el contenido de message no será escapado y el input del buscador se convierte en un vector para la inyección de código en la página.

### Simplificar es la solución

¿Cómo podríamos resolver esto entonces? La respuesta es **tomar menos decisiones por el usuario** y resolver justo lo mínimo que requiere el componente alerta. 

Podríamos definir un componente alerta como una caja que contiene algún tipo de contenido definido por quien lo llama, además esa caja debe poder ser ocultada haciendo clic sobre un botón de cerrar. Delegando el formateado del contenido a quien llama al componente podríamos reducir la implementación a esto:

{% highlight vue mark_lines="7" %}
<script setup>
const visible = ref(true);
</script>

<template>
  <div class="alert" v-if="visible">
    <slot/>
    <span class="alert__dismiss" @click="visible=false">X</span>
  </div>
</template>
{% endhighlight %}

Y los anteriores ejemplos podrían definirse de las siguientes maneras:

```vue
<alert>
  <h4>Warning!</h4>
  <p>Oops, something unexpected happened</p>
</alert>

<alert>
  <h4>Error!</h4>
  <p>Oops! something unexpected happened, <a href="">contact support</a> for help</p>
</alert>
```

Incluso podemos incluir contenido de fuentes no confiables, como la entrada de un usuario, de forma segura, ya que si introduce html en el input, este será escapado y no podrá usarse como vector de inyección de código.

```vue
{% raw %}
<alert>
  <h4>Error!</h4>
  <p>La búsqueda de '{{ searchInput }}' no produjo resultados</p>
</alert>
{% endraw %}
```


## Aplicar funcionalidad extra desde fuera

Otro error común que limita la reusabilidad de un componente es querer resolver demasiados problemas desde dentro.

Veamos un ejemplo simplificado, a continuación muestro un componente destinado a pintar tablas dado un array de objetos.

{% raw %}
```vue
<script setup>
const props = defineProps({
  data: {type: Array, required: true},
})
</script>

<template>
  <table v-if="props.data.length">
    <tr v-for="item in props.data" :key="item">
      <td v-for="value in Object.values(item)" :key="value">
        {{ value }}
      </td>
    </tr>
  </table>
</template>
```
{% endraw %}

Veamos un ejemplo de uso de este componente:

```vue
<script setup>
const items = [
  {name: "Onions", quantity: 2},
  {name: "Lettuce", quantity: 1},
  {name: "Jalapenos", quantity: 4},
]
</script>

<template>
  <Table :data="items"/>
</template>
```

Ahora alguien nos pide que en una tabla de nuestra aplicación debe ser posible filtrar los elementos usando un cuadro de búsqueda, y además los elementois coincidentes deben resaltar el texto coincidente dentro de cada elemento.

La tendencia de un desarrollador menos experimentado será a meter la lógica dentro del componente que ya existe, tal vez añadiendo un flag para habilitar o deshabilitar la función, ya que no queremos aplicar este nuevo comportamiento en todas las tablas de nuestra aplicación, esto está destinado a una nueva historia de usuario en particular.

Veamos una posible solución, resaltaré las líneas que hemos modificado respecto a la implementación original.

{% highlight vue mark_lines="4 7 8 9 10 11 13 17 18 20" %}
<script setup>
const props = defineProps({
  data: { type: Array, required: true },
  search: { type: [String, undefined], default: undefined }
});

function containsSearch(item) {
  return Object.values(item).some((value) => {
    return value.toString().toLowerCase().includes(props.search.toLowerCase());
  });
}

const filteredData = computed(() => props.data.filter(containsSearch));
</script>

<template>
  <table v-if="filteredData.length">
    <tr v-for="item in filteredData" :key="item">
      <td v-for="value in Object.values(item)" :key="value">
        <Highlight :content="value.toString()" :search-text="props.search"/>
      </td>
    </tr>
  </table>
</template>
{% endhighlight %}

Ahora veamos como usaríamos esta nueva versión de nuestro componente. Tenemos que introducir una campo de búsqueda y capturar la entrada del usuario en algún lugar para poder pasar el contenido como filtro a nuestra tabla.

```vue
<script setup>
const items = [
  {name: "Onions", quantity: 2},
  {name: "Lettuce", quantity: 1},
  {name: "Jalapenos", quantity: 4},
]

const search = ref('');
</script>

<template>
  <input @input="search = $event.target.value" type="text"/>
  <Table :data="items" :search="search"/>
</template>
```

Podría parecer que no hay ningún problema con este código, cumple con lo que nos han pedido y no ha añadido mucha complejidad para hacerlo. Además, podemos seguir usando la tabla sin usar la propiedad `search` y se sigue comportando igual que antes.

### El problema es la tendencia

Aunque por si solo este cambio no es un problema, genera una tendencia, si cada nuevo comportamiento que queramos en una tabla acaba dentro de nuestro componente `<Table>` pronto acabaremos con un espagueti difícil de mantener, donde el estado de diferentes extensiones de funcionalidad se cruzan unos con otros, resultando en un código difícil de seguir mentalmente.

El secreto para que extender el comportamiento se haga de una manera que tenga un crecimiento limpio y predecible es usar la composición, y crear herramientas que nos permiten realizar el mismo comportamiento reduciendo al mínimo cuantos cambios tenemos que hacer en nuestro componente Table.

### La composición al rescate

Usando los [composables](https://vuejs.org/guide/reusability/composables.html#what-is-a-composable) podemos extender el comportamiento de un componente desde fuera, veamos el siguiente ejemplo de código anotado:

```js
export function useFilteredTable(data) {
  // almacenará la versión filtrada de los datos,
  // se inicializa con una copia de los datos sin filtrar.
  const filteredData = ref(data);

  // almacena la búsqueda en curso
  const search = ref('');

  // dado un string, devuelve el mismo string como un nodo del DOM
  // aplicando negritas a las coincidencias con la búsqueda
  function highlight(text) {
    return h(Highlight, {
      searchText: search.value,
      content: text.toString()
    })
  }

  // por cada pareja clave-valor del item reemplaza el valor
  // por su versión resaltada en negritas
  function replaceValuesWithHighlightedOccurrences(item) {
    return Object.fromEntries(
      Object.entries(item).map(
        ([k, v]) => [k, highlight(v)]
      )
    );
  }

  // comprueba si alguno de los valores contenidos en la fila
  // contiene la palabra de búsqueda
  function itemContainsFilter(item) {
    const searchTextInLowerCase = search.value.toLowerCase();
    return Object.values(item).some((value) => {
      const columnValueInLowerText = value.toString().toLowerCase();
      return columnValueInLowerText.includes(searchTextInLowerCase);
    });
  }

  // permite modificar la búsqueda y recalcular filteredData
  function setFilter(text) {
    search.value = text;
    filteredData.value = data.filter(itemContainsFilter).map(replaceValuesWithHighlightedOccurrences);
  }

  // la API pública de este composable es lo que devolvemos aquí
  return {
    filteredData,
    setFilter,
  }
}
```

Vamos a explicar lo que hace. Llamamos a la función con el set de datos que pasaríamos a nuestra tabla, y estos son almacenados en una [ref](https://vuejs.org/api/reactivity-core.html#ref) de Vue. También inicializamos otra ref para almacenar el valor de la búsqueda.

Posteriormente, vemos la función `highligh(text)`, esta función recibe texto y lo convierte en componentes renderizados que incluyen el texto con resaltado de las coincidencias de búsqueda, su tipo de retorno es [vNode](https://vuejs.org/api/render-function.html#h).

Luego encontramos la función `itemContainsFilter(item)` que devuelve un booleano indicando si un elemento del array de items inicial contiene o no la búsqueda del usuario.

Por último tenemos `setFilter(text)` que es la forma en la que permitiremos al usuario establecer la búsqueda que quiere aplicar sobre la tabla. Los valores de retorno son la API pública del comportamiento de filtrado, devolviendo los datos ya filtrados (y resaltados) y la función para modificar la búsqueda.

```js
const items = [
  {name: "Onions", quantity: 2},
  {name: "Lettuce", quantity: 1},
  {name: "Jalapenos", quantity: 4},
]

const {filteredData, setFilter} = useFilteredTable(items);

// en este punto `filteredData` es exactamente igual a `items`

setFilter('lett'); // ahora configuramos un filtro

// en este punto `filteredData` solo contiene el elemento `Lettuce`
```

Veamos como usaríamos ahora nuestro componente `Table` junto a este nuevo "composable":

```vue
<script setup>
const items = [
  {name: "Onions", quantity: 2},
  {name: "Lettuce", quantity: 1},
  {name: "Jalapenos", quantity: 4},
]

const {filteredData, setFilter} = useFilteredTable(items);
</script>

<template>
  <input @input="setFilter($event.target.value)" type="text"/>
  <Table :data="filteredData"/>
</template>
```

Como ahora nuestros items no solo pueden contener strings como valores, sino también vNodes, tenemos que hacer una muy pequeña modificación a nuestro componente Table para que pinte correctamente los vNodes (los valores con el resaltado de las ocurrencias del texto buscado). También hemos tenido que cambiar el componente Table, la clave es que los cambios son mucho menores, y sobre todo, **no hemos modificado su interfaz pública**.

{% highlight vue mark_lines="11 12" %}
{% raw %}
<script setup>
const props = defineProps({
  data: {type: Array, required: true},
})
</script>

<template>
  <table v-if="props.data.length">
    <tr v-for="item in props.data" :key="item">
      <td v-for="value in Object.values(item)" :key="value">
        <component v-if="isVNode(value)" :is="value"></component>
        <template v-else>{{ value }}</template>
      </td>
    </tr>
  </table>
</template>
{% endraw %}
{% endhighlight %} 

### Observemos la nueva tendencia

Podría pasar que más adelante nos piden que diferentes tablas se comporten de diferente manera ante el campo de búsqueda. Por ejemplo, si pones varias palabras, algunas tablas funcionarán mostrando solo las filas que contengan todas las palabras (AND), mientras que otras tablas deben mostrar las filas que contengan cualquiera de las palabras introducidas (OR).

Usando "composables" podemos crear un nuevo composable que tiene el comportamiento distinto, y cada comportamiento viviría en su propio módulo, donde es fácil de testear. De manera que podríamos renombrar el composable actual a `useFilteredTableAnd` y tener un nuevo componente `useFilteredTableOr`, los nombres son muy mejorables, pero la idea clave es que extenderíamos el comportamiento **sin modificar el código existente** 🤯. Esto nos permite trabajar con mucha más seguridad, ya que obviamente es muy difícil romper las cosas que no tocamos, por lo que trabajamos sin riesgo, cosas como renombrar un composable podemos hacerlo con el IDE usando [refactors automáticos]({% post_url 2022-10-26-refactoring %}), por lo que son operaciones sin riesgo.


Los ejemplos de código de este post podeis encontrarlos en su forma ejecutable en [este repositorio de GitHub](https://github.com/CodiumTeam/vue-interface-design-examples).
