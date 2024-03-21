---
layout: post
title: "Stop mocking"
date: 2024-03-21 08:00:00 +0100
author: jose
categories: codium
feature_image: img/post-assets/fake-coverage.jpg

read_time: 9
---
Antes de continuar leyendo, y para que entiendas el por qué de éste post, te voy a explicar qué pienso o cómo defino los test unitarios.

Los tests unitarios son aquellos que cumplen con el acrónimo FIRST:
 * F: Fast (rápido, por si tienes mi nivel de inglés)
 * I: Independiente o aislado
 * R: repetible
 * S: self-validating (que se auto validan, pasa o no pasa vamos…)
 * T: timely, escribir el test antes de escribir el código de producción. 

<p style="margin-top: 0;"><i>Podemos omitir éste último si no te gusta mucho el TDD.</i></p>

**_Nota: Profundizamos más en esto en los cursos de [legacy code](https://www.codium.team/curso-legacy-code.html) y [TDD](https://www.codium.team/curso-tdd.html), por tanto, no entraré en cada uno de los puntos_**

Me gusta esa definición o característica porque no entra tanto en el detalle de:

_“un test unitario es una, UNA clase, o un método, pero nunca una combinación de clases o métodos”_

Y para mí, existe la falsa creencia de que un test unitario es una clase y/o un método, y todo aquello que no tenga que ver con eso, debe ser mockeado, o que las librerías externas también deben ser mockeados.


## Testing en el front

En éste post me voy a centrar sobre todo en la parte front, que es dónde, con un simple vistazo del fichero, soy capaz de detectar el smell o problemas (tampoco es tan difícil y verás por qué…).

Vamos con un ejemplo sencillo
“Un componente que saluda al usuario dependiendo de su idioma de navegador preferido”

Para resolver la internacionalización utilizaré `react-i18next`

```jsx
 // Greeting.jsx
import { useTranslation } from 'react-i18next';

const Greeting = () => {
   const { t } = useTranslation();
   return <p>{t('hello')}</p>;
};
```

```jsx
// Greeting.test.jsx
test('Greeting is in default language', () => {
   render(<Greeting />);
   expect(screen.getByText('Hello')).toBeVisible();
});
```

El test estaría en verde pero con un warning/error

<p style="color: #d42828; margin-bottom:  0">react-i18next:: You will need to pass in an i18next instance by using initReactI18next</p>

<p style="margin-top:  6px">No queremos tener test que lancen warning (en realidad es un fallo), por tanto vamos a solucionarlo.</p>


### Solución 1: vi.mock o jest.mock. 

Esta es la que más he visto y me duele en el alma. ¿Por qué? Porque se justifica que _“no sería un test unitario si no mockeo react-i18next, además la librería tiene su propio tests y yo no debería testear la librería”_. 

**Volvemos al test unitario = clase o método.**

```jsx
// Greeting.test.jsx
vi.mock('react-i18next', async importOriginal => {
   return {
       ...(await importOriginal()),
       /**
        * Sobreescribo el método que me interesa y
        * le añado el comportamiento que deseo
        */
       useTranslation: () => ({
           t: text => text, // siempre devolverá el texto que le paso a traducir
       }),
   };
});
```
<i>Mockeamos todo aquello que no es nuestro, adiós warning y pa’ lante…</i>

```jsx
test('Greatting in english', () => {
   render(<Greeting />);
   expect(screen.getByText('hello')).toBeVisible();
});
```

Y sé lo que estáis pensando:
<p style="color: #7a7a7a;"><i>“Ya pero aquí no confirmas si realmente estoy utilizando la librería de traducciones. Tienes que validar que se llamen con los parámetros adecuados.”.</i></p>

Vale, te lo voy a comprar. Voy a cambiar el test para validar que se haya llamado a la librería con los parámetros adecuados.

```jsx
const mockedUseTranslation = vi.fn(); // defino un método mock al que espiar
vi.mock('react-i18next', async importOriginal => {
   return {
       ...(await importOriginal<typeof import('react-i18next')>()),
       /**
        * Sobreescribo el método que me interesa y
        * utilizo el mock con el comportamiento sobreescrito
        */
       useTranslation: () => ({
           t: mockedUseTranslation.mockImplementation((text) => text),
       }),
   };
});


test('Greatting in any language', () => {
   render(<Greeting />);
   expect(mockedUseTranslation).toHaveBeenCalledWith('hello');
});
```

### Problemas

Acabamos testeando más detalles de implementación que comportamiento o funcionalidad. Esto hace que los tests sean frágiles, lo que significa que se rompen fácilmente cuando refactorizamos o cambiamos el código, incluso si la funcionalidad sigue siendo la misma.

Creamos representaciones poco realistas o inexactas de dependencias que no poseemos o controlamos. Obtenemos así falsos positivos, falsos negativos o errores en los tests, porque es posible que no sepamos del todo el comportamiento real, la lógica o el contrato de la dependencia que mockeamos. 

Por ejemplo, si mockeas o haces stub de librerías de terceros, puedes pasar por alto algunos casos extremos, errores o cambios que la librería podría devolver o introducir. 

Incluso he llegado a ver proyectos en los que mockean hasta sus propios componentes.

```jsx
vi.mock('../<path>/myComponent')
```

Y viendo eso, debemos sumar a los problemas:

<p style="margin: 0;">Incapacidad de hacer refactoring:</p>

<p style="margin: 16px 0 0 24px;">
Como nuestro mock sobreescribe en base al path o directorio en la que se encuentra el componente, acabamos creando tests acoplados a la estructura de directorio del proyecto.</p>

### Ventajas
Y por nombrar alguna ventaja:
- Controlar el comportamiento de las dependencias. ¿Es una ventaja?
- Es asilado

_Lo siento, no soy capaz de encontrar más ventajas_

### Solución 2: test sociables

_If you can omit mocking, omit mocking._

¿Qúe son los test sociables?

Para mí un test sociable es aquel que no se limita a testear una sola clase.

¿Ventaja? Nos ayuda a encontrar problemas reales en la forma en que trabajan los componentes juntos.
<p style="color: #7a7a7a;"><i>“ah… son test de integración…”.</i></p>

No del todo, para mí un test de integración es aquella que incumple con el acrónimo FIRST. Por ejemplo, si X hace una llamada a una API en ese caso:
- ya no es rápido y 
- depende de una api externa para funcionar por lo que, muy probablemente, no esté aislado.


Por tanto yo acabaría creando un test que se integre por completo con la librería. 

Englobar en nuestro test en un [I18nextProvider y pasarle una instancia de i18n](https://react.i18next.com/legacy-v9/i18nextprovider) definiendo el idioma que quiero en el test.

```jsx
test('Greetting in english', () => {
   const localI18n = i18n.cloneInstance({
       lng: 'en',
   });


   render(
       <I18nextProvider i18n={localI18n}>
           <Greeting />
       </I18nextProvider>
   );


   expect(screen.getByText('hello')).toBeVisible();
});
```

Para comprobar que estoy utilizando la librería, acabaría creando otro test en otro idioma

```jsx
test('Greeting in english', () => {
   const localI18n = i18n.cloneInstance({
       lng: 'es',
   });

   render(
       <I18nextProvider i18n={localI18n}>
           <Greeting />
       </I18nextProvider>
   );


     expect(screen.getByText('hola')).toBeVisible();
});
```

<i>Nota: esto es un ejemplo, acabaría moviendo el provider a un [custom render](https://testing-library.com/docs/react-testing-library/setup/#custom-render) para no tener código duplicado.</i>

### Problemas

Test duplicados que validan más o menos lo mismo (cambia el idioma). **De hecho, en el Front es un GRAN DOLOR**, no solo por la duplicidad, si no que los tests en el front son muy lentos. Más adelante explico cómo solucionar éste problema.

Cabe la posibilidad que tengamos setups más complejos o el origen de un test fallido puede no ser tan claro

Para algunos, otro problema sería que no somos capaces de definir el comportamiento deseado para ciertos tests.

### Ventajas

Una de las principales ventajas que promueve es crear test más realistas ya que testeamos la integración e interacción completa entre diferentes componentes. 

Nos permite centrarnos más en el qué y no en el cómo, es decir, probamos más qué hace (funcionalidad) a cómo lo hace (implementación).

1. menos tiempo definiendo mocks 
2. mas confianza 
3. menos posibilidad de errores de contrato 
4. menos tests a escribir 
5. mas resiliente a refactor

En éste punto quizás te surja una duda: 

<p style="color: #7a7a7a;"><i>“¿Cuál es la diferencia entre un test sociable vs test e2e?
”</i></p>

La diferencia está sobre todo en el punto en el que acabo creando esos “mocks”. 

> Suele ser en la capa de petición http.

En el post [“Mis problemas con Hexagonal”](https://blog.codium.team/2023-08_arquitectura-hexagonal-frontend-mis-problemas) muestro un ejemplo de cómo falseo las peticiones.


En cambio, cuando realizo los tests e2e con Cypress, suelen ser de tipo “Smoke test” donde las validaciones son más laxas: 
- No hay error en la consola
- Puedes navegar correctamente
- Puedes realizar acciones básicas a través de un navegador

### Reducir test duplicados.

He elegido react-i18next porque para mí es un gran incomprendido. La mayoría de veces se suele hacer x.mock sobre ésa librería.

Y el motivo suele ser el mismo:
- No quiero integrarme a mi sistema de traducciones. Si alguien cambia una traducción, mis tests no deberían romperse.

Para ello ofrezco soluciones:

- Si no tienes los ficheros de traducción en código, [extrae las traducciones de tu código](https://www.i18next.com/overview/plugins-and-utils#extraction-tools) como un proceso previo a la ejecución de los tests y testea en el idioma por defecto.
- Si mockeas para validar que se haya llamado con los parámetros adecuados porque quieres validar que no se te ha olvidado traducir. [Eslint al rescate](https://github.com/edvardchen/eslint-plugin-i18next), si lo juntas a un precommit hook evitarías que hagan commits de textos sin traducir.


Si mockeas otras librerías para validar contenido, estoy seguro que podrías darle una vuelta al test. Por un ejemplo


notistack: librería que nos permite mostrar un toast

```jsx
const mockEnqueueSnackbar = jest.fn();
vi.mock('notistack', () => ({
   ...jest.requireActual('notistack'),
   useSnackbar: () => ({
       enqueueSnackbar: mockEnqueueSnackbar,
   }),
}));


test('Show popup message', async() => {
  render(<ShowNotification />);

  await userEvent.click(screen.getByText('Show now'))

  expect(mockEnqueueSnackbar).toHaveBeenCalledWith('Notification works')
});
```

Podriamos re-escribir y validar el comportamiento real que vería un usuario.

1. Eliminamos vi.mock

```jsx
test('Show popup message', async() => {
  render(<ShowNotification />);


  await userEvent.click(screen.getByText('Show now'))


   expect(await screen.findByText('Notification works')).toBeVisible();
});
```

Para resumir este post, te invito a replantearte la manera en que realizas los tests, a salir de la caja para así buscar alternativas que te alejen del x.mock.

Si aún así no te convence, algunos consejos que aplicar en general:


1. Revisa regularmente y simplifica los mocks en tu test. Asegúrate de que reflejen escenarios realistas. Actualizalos, elimina los que no se usen y utiliza nombres claros y documentación para mejorar la claridad y la mantenibilidad. 
2. Potencia tu capacidad para detectar smells. Estate atento a un exceso de mocks, o de setup para el test, reduce tests demasiados complejos. 
3. Separar responsabilidades. [Container/Presentacional pattern](https://www.patterns.dev/react/presentational-container-pattern/) 
4. Fomenta la colaboración entre los miembros de tu equipo para garantizar que las decisiones de mocks se tomen cuidadosamente y se alineen con la estrategia general de testing. 
5. Fomenta el intercambio de conocimientos para promover las mejores prácticas y así mejorar continuamente los tests.

Y antes de cerrar. ¿Qué pasa con los mocks de peticiones http?

Mi posición está muy clara. [Stop mocking fetch](https://kentcdodds.com/blog/stop-mocking-fetch). Larga vida a msw 🎉 
