---
layout: post
title:  "TDD en React JS"
date:   2022-05-26 08:00:00 +0100
author: jose
categories: codium
feature_image: post-assets/tdd-react-js

read_time : 6
---

Vamos a ver con un poco más en detalle lo que implica trabajar aplicando la metodología TDD en un proyecto “real” en ReactJS.

> Esta es la segunda parte de Desarrollo basado en pruebas (TDD). Puedes encontrar la primera parte en <a href="/2022-05_que-es-tdd">¿Qué es TDD?</a>.


Para ésta explicación utilizaré la Coffee Machine. Ésta kata la que utilizamos en el curso de TDD y en concreto la veremos con JavaScript.

La Coffee Machine kata se hace en 5 iteraciones, la primera de ellas consiste en preparar las bebidas. Las siguientes iteraciones van añadiendo funcionalidades nuevas que ponen a prueba las decisiones que hemos ido tomando. En éste post trabajaremos tan sólo la primera iteración.

Antes de avanzar me gustaría definir la interfaz que usaré ya que en ésta kata somos completamente libres de decir el diseño de la máquina de café.
En mi caso, el usuario deberá seleccionar la bebida que desea, luego el número de azúcar y por último darle al botón “Start” (preparar bebida).

![Coffe Machine ReactJs](/img/tdd/coffee-machine.png)

<h2>Drink Maker</h2>

Hemos comprado una máquina que sabe preparar bebida, nosotros tan sólo debemos indicarle qué tipo de bebida debe preparar. Ésta máquina es el <code>DrinkMakerBox</code>.

El DrinkMakerBox permite convertir comandos en pedidos y un comando no es más que un texto codificado. Por ejemplo, C:: le indica a la máquina de bebidas que debe preparar un café sin azúcar y sin palillo para remover.

Unos ejemplos de comandos que podría recibir el DrinkMakerBox son:

```bash
"T:1:0" (1 té con 1 de azúcar y palillo para remover)
"H::" (1 chocolate sin azúcar y sin palillo)
"C:2:0" (1 café con 2 de azúcar y con palillo para remover)
```

Código de DrinkMakerBox:

```javascript
function DrinkMakerBox({command = ''}) {
  if (!isValidCommand(command)) {
    return <NullComponent/>
  }

  // Ejecuta el comando
  drinkMaker.execute(command);

  return <ShowDrink command={command}/>
}
```

Antes de avanzar con la primera iteración me gustaría dejar claro que no haremos **TDD de maquetación**, sino de funcionalidad. Dentro del proyecto ya disponemos de componentes reutilizables que nos permitirán añadir funcionalidad sin la necesidad de tener que maquetar o hacer CSS.

<h2>Primera iteración: Preparando las bebidas</h2>

En ésta primera iteración introduciremos la capacidad de **seleccionar Café sin Azúcar y sin palillo**.

<h4>1. Primer test </h4>

Nuestro test seguiría el siguiente flujo:

```
1. Usuario selecciona café
2. Usuario presiona Start
3. Recibe el café
```

```javascript
test('User is able to select "Coffee"', function () {
  render(<CoffeeMachine />);
  // We spy on drink maker execution command
  jest.spyOn(drinkMaker, "execute");
  const coffeeButton = screen.getByText("Coffee");
  const startButton = screen.getByText("Start");

  userEvent.click(coffeeButton);
  userEvent.click(startButton);

  expect(drinkMaker.execute).toHaveBeenCalledWith("C::");
});
```

<h4>2. Introducir el código más simple posible para que el test que acabamos de escribir pase.</h4>

```jsx
function CoffeeMachine() {
  const [command, setCommand] = useState("");

  return (
    <MachineWrapper>
      <DrinksBlock>
        <ColumnsButtonsGroup>
          {/* Añadimos botón "Coffee" */}
          <Button text="Coffee" />
        </ColumnsButtonsGroup>
      </DrinksBlock>

      <RightPanel>
        {/* Añadimos botón "Start" */}
        <Button
          text="Start"
          onClick={() => {
            /* Cuando el usuario da al botón start establece el comando */
            setCommand("C::");
          }}
        />
      </RightPanel>

      <div className="output">
        <DrinkMakerBox command={command} />
      </div>
    </MachineWrapper>
  );
}
```

```bash
 PASS  src/CoffeeMachine.test.js
  ✓ User is able to select "Coffee" (98 ms)

Test Suites: 1 passed, 1 total
Tests:       1 passed, 1 total
Snapshots:   0 total
Time:        1.945 s, estimated 2 s

```

Con eso ya tendríamos nuestra primera implementación. El usuario es capaz de seleccionar café sin azúcar.

<h3>Bebida con 1 de azúcar</h3>

<i>El usuario tiene la posibilidad de seleccionar Café con 1 de azúcar y con palillo.</i>

<h4>1. Añadiendo test </h4>

```
1. Usuario selecciona café
2. Usuario selecciona añadir azúcar
3. Usuario le da a start
4. Recibe café
```

```jsx
test('User is able to select "Coffee" with one sugar', function () {
  render(<CoffeeMachine />);
  // We spy on drink maker execution command
  jest.spyOn(drinkMaker, "execute");
  const coffeeButton = screen.getByText("Coffee");
  const addSugarButton = screen.getByText("+");
  const startButton = screen.getByText("Start");


  userEvent.click(coffeeButton);
  userEvent.click(addSugarButton);
  userEvent.click(startButton);

  expect(drinkMaker.execute).toHaveBeenCalledWith("C:1:0");
});
```

Nos vamos al código de producción e introducimos el botón de seleccionar azúcar y cambiamos la lógica.

<h3>2. Añadiendo código</h3>

Dentro del estado, añadimos un nuevo atributo “numberOfSugars” y la inicializamos a 0

```jsx
  const [numberOfSugars, setNumberOfSugars] = useState(0);

  // ....

<RightPanel>
  <div>
    <SmallButton
      text="+"
      onClick={() => {
        /* Establecemos el número de azúcar en 1 */
        setNumberOfSugars(1);
      }}
    />
  </div>

  <Button
    text="Start"
    onClick={() => {
      const numSugarText = numberOfSugars ? "1" : "";
      const stickText = numberOfSugars === 0 ? "" : "0";

      setCommand(`C:${numSugarText}:${stickText}`);
    }}
  />
</RightPanel>
```

```bash
 PASS  src/CoffeeMachine.test.js
  ✓ User is able to select "Coffee" (99 ms)
  ✓ User is able to select "Coffee" with one sugar (53 ms)

Test Suites: 1 passed, 1 total
Tests:       2 passed, 2 total
Snapshots:   0 total
Time:        1.844 s, estimated 2 s
```

<h3>Bebida con 2 de azúcar</h3>

<i>El usuario tiene la posibilidad de seleccionar Café con 2 de azúcar y con palillo.</i>

<h4>1. Añadiendo test </h4>

```bash
1. Usuario selecciona café
2. Usuario selecciona añadir azúcar
3. Usuario selecciona añadir azúcar
4. Usuario le da a start
5. Recibe café
```

```jsx
test('User is able to select "Coffee" with two sugar', function () {
  render(<CoffeeMachine />);
  // We spy on drink maker execution command
  jest.spyOn(drinkMaker, "execute");
  const coffeeButton = screen.getByText("Coffee");
  const addSugarButton = screen.getByText("+");
  const startButton = screen.getByText("Start");

  userEvent.click(coffeeButton);
  userEvent.click(addSugarButton);
  userEvent.click(addSugarButton);
  userEvent.click(startButton);

  expect(drinkMaker.execute).toHaveBeenCalledWith("C:2:0");
});
```

<h4>2. Modificando código </h4>

Para conseguir que el test se ponga en verde debemos cambiar en dos puntos el código de producción:

Debemos eliminar el hardcodeo del número de azúcar y hacerlo dinámico. A su vez también debemos hacer dinámico cómo se calcula el número de azúcar que vamos a enviar a la coffee machine.

```jsx
<SmallButton
  text="+"
  onClick={() => {
    /* Azúcar dinámico */
    setNumberOfSugars(numberOfSugars + 1);
  }}
/>

<Button
  text="Start"
  onClick={() => {
    const numSugarText = numberOfSugars
      ? numberOfSugars.toString()
      : "";
    const stickText = numberOfSugars === 0 ? "" : "0";

    setCommand(`C:${numSugarText}:${stickText}`);
  }}
/>
```

```bash
 PASS  src/CoffeeMachine.test.js
  ✓ User is able to select "Coffee" (107 ms)
  ✓ User is able to select "Coffee" with one sugar (57 ms)
  ✓ User is able to select "Coffee" with two sugar (63 ms)

Test Suites: 1 passed, 1 total
Tests:       3 passed, 3 total
Snapshots:   0 total
Time:        1.935 s
```

Con ésto estaríamos dando la posibilidad al usuario de que seleccione café sin azúcar o con 1 o dos de azúcar.

<h3>3. Refactorizando </h3>

Podemos refactorizar el código para hacerlo un poco más legible.

¿Qué podriamos refactorizar?

Los cambios que podemos hacer son:

1. Mover a un método el handler cuando el usuario selecciona Café
2. También mover a un método el cálculo del comando.
3. Eliminar el hardcodeo de “C” que indica que es un café, es decir, darle un significado a ese valor.

<h4>1. Mover a un método el handler cuando el usuario selecciona Café</h4>

```diff
+  const addSugar = () => {
+    setNumberOfSugars(numberOfSugars + 1);
+  };

-          <SmallButton
-            text="+"
-            onClick={() => {
-              /* Azúcar dinámico */
-              setNumberOfSugars(numberOfSugars + 1);
-            }}
-          />
+          <SmallButton text="+" onClick={addSugar} />
```

<h4>2. Mover a un método el handler cuando el usuario selecciona Café</h4>

```diff
+  const prepareDrink = () => {
+    const numSugarText = numberOfSugars ? numberOfSugars.toString() : '';
+    const stickText = numberOfSugars === 0 ? '' : '0';
+
+    setCommand(`C:${numSugarText}:${stickText}`);
+  };
+

-        <Button
-          text="Start"
-          onClick={() => {
-            const numSugarText = numberOfSugars
-              ? numberOfSugars.toString()
-              : '';
-            const stickText = numberOfSugars === 0 ? '' : '0';
-
-            setCommand(`C:${numSugarText}:${stickText}`);
-          }}
-        />
+        <Button text="Start" onClick={prepareDrink} />
```

<h4>3. Eliminar el hardcodeo de “C” que indica que es un café, es decir, darle un significado a ese valor.</h4>

```diff
--- a/src/CoffeeMachine.js
+++ b/src/CoffeeMachine.js
@@ -7,6 +7,10 @@

+ const DRINKS = {
+  Coffee: 'C',
+};
+
 function CoffeeMachine() {
   const [command, setCommand] = useState('');
   const [numberOfSugars, setNumberOfSugars] = useState(0);
@@ -19,7 +23,7 @@
  function CoffeeMachine() {
     const numSugarText = numberOfSugars ? numberOfSugars.toString() : '';
     const stickText = numberOfSugars === 0 ? '' : '0';

-    setCommand(`C:${numSugarText}:${stickText}`);
+    setCommand(`${DRINKS.Coffee}:${numSugarText}:${stickText}`);
   };

   return (
```

<h4>Código final</h4>

```jsx

const DRINKS = {
  Coffee: 'C',
};

function CoffeeMachine() {
  const [command, setCommand] = useState('');
  const [numberOfSugars, setNumberOfSugars] = useState(0);

  const addSugar = () => {
    setNumberOfSugars(numberOfSugars + 1);
  };

  const prepareDrink = () => {
    const numSugarText = numberOfSugars ? numberOfSugars.toString() : '';
    const stickText = numberOfSugars === 0 ? '' : '0';

    setCommand(`${DRINKS.Coffee}:${numSugarText}:${stickText}`);
  };

  return (
    <MachineWrapper>
      <DrinksBlock>
        <ColumnsButtonsGroup>
          <Button text="Coffee" />
        </ColumnsButtonsGroup>
      </DrinksBlock>

      <RightPanel>
        <div>
          <SmallButton text="+" onClick={addSugar} />
        </div>

        <Button text="Start" onClick={prepareDrink} />
      </RightPanel>

      <div className="output">
        <DrinkMakerBox command={command} />
      </div>
    </MachineWrapper>
  );
}
```

<h4>¿Cómo continuar?</h4>

Hemos aplicado TDD en React utilizando Jest y Testing-library y sólo hemos cubierto un caso “Selección de bebida (café) con y sin azúcar”.

Como la historia de usuario y los criterios de aceptación están bien detallados, podemos continuar añadiendo más funcionalidades a la aplicación.

Aunque existen muchos recursos relacionados con React TDD, espero que este artículo te haya ayudado a aprender un poco sobre el desarrollo de TDD con React usando historias de usuarios. Si quieres profundizar más en TDD, en **Codium** disponemos de un <a href="https://www.codium.team/curso-tdd.html">Curso de TDD que te permitirá revolucionar tu forma de desarrollar.</a>

Puedes continuar con ésta kata introduciendo las nuevas funcionalidades o poner en práctica tus conocimientos de <a href="https://www.codium.team/tdd-challenge.html">TDD con nuestro challenge</a>

