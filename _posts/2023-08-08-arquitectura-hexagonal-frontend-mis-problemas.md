---
layout: post
title: "Arquitectura en el Frontend - Mis problemas con Hexagonal"
date: 2023-08-08 08:00:00 +0100
author: jose
categories: codium
feature_image: post-assets/hexagonal-en-el-frontend

read_time: 11
---

<br />
<a href="https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html">Clean Architecture</a>,
<a href="https://jeffreypalermo.com/2008/07/the-onion-architecture-part-1/">Onion Architecture</a> y
<a href="https://medium.com/ssense-tech/hexagonal-architecture-there-are-always-two-sides-to-every-story-bc0780ed7d9c">Hexagonal Architecture</a> (también conocido como Ports-and-Adapters) se han convertido en la norma para el diseño de software y aunque en el mundo “backend” su uso está extendido, en el mundo “frontend” se empieza a oír sobre ello, sus beneficios y cómo aplicarlo.

Hay que destacar que esta arquitectura (y sus principios) tienen muchos años y sus fundamentos se han mantenido en el tiempo y esto me lleva al siguiente tweet:

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">iamdevloper (@iamdevloper) <a href="https://twitter.com/iamdevloper/status/1218939581103472640">https://twitter.com/iamdevloper/status/1218939581103472640</a></p>&mdash; iamdevloper (@iamdevloper) <a href="https://twitter.com/iamdevloper/status/1218939581103472640"></a></blockquote>

Para comprender los problemas que yo he ido encontrándome y a los cuales he catalogado como “sobre-ingeniería”, vamos a imaginarnos por un momento que nos piden que desarrollemos la siguiente historia de usuario:

> Como usuario quiero poder acceder a la página principal y ver el listado de productos con:
>
> - Nombre el producto
> - Imagen del producto
> - Precio

<div class="alert alert-info">
  <p>
    <i class="fa fa-info-circle" aria-hidden="true"></i>
    <span>Para obtener el listado de productos y el detalle del producto, disponemos de una API desarrollada, por tanto sólo tendríamos que hacer llamadas HTTP para obtener dicha información.</span>
  </p>
</div>

Una vez comprendida la historia de usuario, nos vamos a código.

## Aterrizando la historia de usuario a código

La arquitectura hexagonal se basa en separar las capas de aplicación de las capas externas. He “troceado” la funcionalidad y aterrizado en sus capas correspondientes:

_Dominio_

- Product: Representa un producto con su nombre, imagen, precio y descuento (si lo tiene).
- ProductRepository: Es una interfaz que define los métodos para acceder a los productos. Se utilizará para conectar la capa de aplicación con la capa externa (por ejemplo, una API).

_Aplicación_

- ListProducts: Es la capa de aplicación que maneja la lógica de negocio relacionada con los productos.

_Adapters_ (infraestructura)

- HttpProductRepository: implementa la interfaz ProductRepository definida en la capa de dominio (Core) y se conecta a una API para obtener los datos de los productos.

_UI_

- HomePage: presenta los productos a los usuarios.

<p class="text-center">
<img src="/img/post-assets/hexagonal-frontend/user-history-hexagonal.png"  alt="Aparecen unos hexagonos en forma de capas. En la capa más interna, está el bloque de Dominio, con Product y ProductRepositorio. Un nivel más arriba, aparece la capa de Aplicación con ListProducts y en la parte más externa los Adapters con HttpProductRepository"/>
</p>

Una vez definidas las capas, podemos ir a código, pero no sin antes debatir un poco…

<div class="alert alert-warning">
  <p>
    <i class="fa fa-warning" aria-hidden="true"></i>
    <span>¡Ojo! Estos debates pueden ocurrir antes de iniciar el proyecto para así generar las bases y/o reglas que utilizarán el </span>
  </p>
</div>

### Product: ¿Es una clase o un tipo?

En la mayoría de los casos, cuando definimos una entidad en la capa de dominio, generalmente solo queremos definir la estructura de los datos y no necesitamos agregar lógica específica a la entidad. Una interfaz o tipo es ideal para esta situación porque simplemente define la forma o estructura de los datos sin preocuparse por la implementación.

Los tipos en TypeScript son solo contratos que describen la forma de un objeto. No pueden contener lógica ni tener instancias reales. Por otro lado, las clases pueden contener propiedades, métodos y lógica adicional.

```typescript
// Type
type Product = {
  name: string;
  image: string;
  price: number;
};

// Class
class Product {
  constructor(
    public readonly name: string,
    public readonly image: string,
    public readonly price: number
  ) {}
}
```

<p>
  <i>
En mi experiencia, siempre elijo definir mis entidades como tipo y si en algún momento necesito agregar más lógica o comportamiento a la entidad, lo convierto en una clase aunque implique un tiempo de refactor. <br />
¿Y por qué elijo eso?  <br />
<span style="padding-left: 16px;">- por su simplicidad (a no ser que exista una decisión de equipo)</span><br />
<span style="padding-left: 16px;">- y porque favorece a una programación más funcional</span><br />
En la mayoría de los casos siempre consumo información y la muestro al usuario, carece de lógica, y si tiene lógica, la realidad suele ser que ésta acaba en el backend.
</i>
</p>

### El purismo extremo: ¿Debe ListProduct devolver un DTO o un objeto de Dominio?

<p class="text-center">
<img src="/img/post-assets/hexagonal-frontend/hexagonal-en-el-frontend-without-class.png"  alt="Aparecen unos hexagonos en forma de capas con flechas apuntando de una capa externa a la interna. En la capa más externa los adapters con una flecha apuntando a la siguiente capa inmediata, Application y a la vez, la capa de Application apuntando con una flecha a la capa de Domain"/>
</p>

Si nos fijamos en la imagen y en sus flechas nos muestran las conexiones y comunicación entre las diferentes capas y componentes del sistema. Por tanto, cada capa solo debe llamar a la siguiente inmediata.

Si nos vamos a esa teoría y optamos por el purismo, la capa de aplicación no debería devolver objetos de dominio, sino debe devolver una Respuesta acorde a los datos a necesitar. Y es aquí donde aparecen los [DTO](https://stackoverflow.com/questions/1051182/what-is-a-data-transfer-object-dto), de esa manera prevenimos que otras capas externas tengan acceso al dominio.

```typescript
// application/ProductDTO.ts
type ProductDTO {
  name: string;
  image: string;
  price: number;
}

// application/ListProducts.ts
class ListProducts {
  constructor(private productRepository: ProductRepository) {}

  async getProducts(): Promise<ProductDTO[]> {
    const products = await this.productRepository.getProducts();
    return products.map((product) => this.convertToProductDTO(product));
  }

  private convertToProductDTO(product: Product): ProductDTO {
    return {
      name: product.name,
      image: product.image,
      price: product.price,
    };
  }
}
```

<i>Existen más debates, pero prefiero parar aquí para no hacer un post tan largo…</i>

Por tanto el código final que nos quedaría sería algo así:

```typescript
// domain
type Product {
  name: string;
  image: string;
  price: number;
}

interface ProductRepository {
  getProducts(): Promise<Product[]>;
}


// application
type ProductDTO {
  name: string;
  image: string;
  price: number;
}

class ListProducts {
  constructor(private productRepository: ProductRepository) {}

  async getProducts(): Promise<ProductDTO[]> {
    const products = await this.productRepository.getProducts();
    return products.map((product) => this.convertToProductDTO(product));
  }

  private convertToProductDTO(product: Product): ProductDTO {
    return {
      name: product.name,
      image: product.image,
      price: product.price,
    };
  }
}

// Infrastructure - Adapters
import axios from 'axios';
import { Product, ProductRepository } from '../domain/DomainInterfaces';

class HttpProductRepository implements ProductRepository {

  constructor(private readonly apiBaseUrl: string) {
    this.apiBaseUrl = apiBaseUrl;
  }

  async getProducts(): Promise<Product[]> {
        const response = await axios.get<Product[]>(`${this.apiBaseUrl}/products`);
      return response.data;
  }
}

export default HttpProductRepository;
```

```tsx
// UI
const HomePage: React.FC = () => {
  const [products, setProducts] = useState<ProductDTO[]>([]);
  const productRepository = new HttpProductRepository('https://api.codium.team');
  const listProducts = new ListProducts(productRepository);

  useEffect(() => {
    listProducts.getProducts().then(setProducts);
  }, []);

  return (
    <div>
      <h1>Lista de Productos</h1>
      <ul>
        {products.map((product) => (
          {products.map((product, index) => (
            <li key={product.name} data-testid={'product-id-' + index}>
              <div>
                <img src={product.image} alt={product.name} />
                <h3>{product.name}</h3>
                <p>Precio: ${product.price}</p>
              </div>
            </li>
          ))}
        ))}
      </ul>
    </div>
  );
};

```

## (Mis) Problemas

<h3 style="margin-top: 36px;">No hay suficiente complejidad de dominio</h3>

Si el dominio no es complejo (similar a un CRUD), o si el desafío al desarrollar la aplicación NO está en la complejidad de las reglas de negocio, entonces la arquitectura Hexagonal podría no ser la mejor elección, y es posible que sea mejor optar por otro tipo de arquitectura.

<h3 style="margin-top: 36px;">Interfaces inútiles</h3>

<p style="margin: 0;">El uso excesivo de interfaces puede tener su origen en un Principio de Diseño muy antiguo: “Depender de abstracciones, en lugar de implementaciones”. El uso de interfaces nos permite intercambiar implementaciones en tiempo de ejecución.</p>

<p style="margin: 0;">Otro de los motivos del uso de interfaces es El Principio de Inversión de Dependencia.</p>

<p style="margin: 0;">Por tanto para mí una interfaz merece existir si y sólo si:</p>

- Tiene más de una implementación en el proyecto, o
- Si quieres (y puedes) desacoplarte del backend.

<h3 style="margin-top: 36px;">Capas estrictas</h3>

<p style="margin-bottom: 0; margin-top: 16px;"><strong>Aplicación</strong></p>

- Tipos de retorno.<br />
  Si comparas Product y ProductDTO en éste código ambos devuelven los mismos datos y/o atributos, por tanto y desde mi punto de vista, suele ser innecesaria tener esa complejidad. Es mejor permitir que las otras capas sepan de tu dominio ya que sólo transfieren o consumen información.
- Servicios que llaman a métodos de repositorio sin lógica alguna. <br />
  Si optamos por eliminar los DTO y devolver siempre objetos de dominio, tendríamos un código tal que así:

```typescript
class ListProducts {
  constructor(private productRepository: ProductRepository) {}

  getProducts(): Promise<Product[]> {
    return this.productRepository.getProducts();
  }
}
```

Para mí, éste código es un ejemplo claro del [Code Smells llamado Middle Man](https://refactoring.guru/smells/middle-man), ya que este método representa "indirección sin abstracción": no agrega ninguna nueva semántica (abstracción) al método al que delega (<code>productRepository.getProducts</code>). El método anterior no mejora la claridad del código, sino que solo agrega un "salto" adicional en la cadena de llamadas.

<p><i>A mí personalmente me gusta más optar por saltarme capas. ¿Desventajas de ésta decisión? <br/>Requiere tomar decisiones subjetivas y que cambian con el tiempo, por lo que es más difícil mantener la consistencia y cohesión.
</i></p>

<h3 style="margin-top: 36px;">Repositorios (Repository Pattern)</h3>

La idea con los repositorios es tener un punto centralizado de acceso a datos.

Lo que ocurre muchas veces en el frontend es que los métodos de un repositorio se utilizan un único punto y además que las consultas no suelen ser muy complejas.

En los proyectos en los que he trabajado, las fuentes siempre han sido las mismas: Mi propia API (o de la empresa). Por tanto eliminar ésta capa me aporta:

- **Simplicidad**: como estoy trabajando con una API propia, es muy probable que ya tenga el control completo sobre la estructura y comportamiento. La API suele estar diseñada para satisfacer mis necesidades específicas.

En casos así prefiero trabajar directamente con la API desde la capa de aplicación.

```typescript
class ListProducts {
  async getProducts(): Promise<Product[]> {
    const response = await axios.get<Product[]>(`https://.../products`);
    return response.data;
  }
}
```

Sé que más de uno o una ha notado el dolor: ¡estoy importando axios (infraestructura) directamente en la capa de aplicación. _¡Las flechas Jose, las flechas!_

Una vez eliminado el repositorio, suelo aislar módulos en clases de mi dominio. Por ejemplo, para el caso de axios, crearía una clase _APIClient (Adapter)_ con unos métodos públicos definidos.

```typescript
class APIClient {
  constructor(private readonly apiUrl: string) {}

  async get<T>(path: string): Promise<T> {
    const response = await axios.get<T>(`${this.apiUrl}${path}`);
    return response.data;
  }

  // more methods
}
```

¿Por qué crearía el adapter <code>APIClient</code>?

- **Me permite centralizar errores y así poder devolver errores de mi dominio**. <br />
  Por ejemplo, imagínate hacer una petición a la API para obtener un producto y que ésta no existiese (404). Si no tuviese un punto de control del error que axios podría lanzarme (un AxiosError) ésta podría expandirse como un virus por todo mi código. <br /> Por tanto, para evitar que axios se expanda, opto por capturar los errores comunes de Axios y devuelvo mis propias excepciones. En el caso de un 404 devolvería un <code>NotFoundException</code>.
- **Poder establecer lógicas en las llamadas**.
  - Podría definir cómo se accede o cómo se establece la autenticación para realizar la llamada.
  - Definir el número de intentos…
  - O incluso definir lógica de cómo se cancelan las peticiones en caso de necesitarlas.

Y lo usuaria en el caso de uso:

```typescript
class ListProducts {
  constructor(private readonly apiClient: APIClient) {}

  async getProducts(): Promise<Product[]> {
    const response = await this.apiClient.get<Product[]>(`/products`);
    return response.data;
  }
}
```

De esa manera aíslo aquellos módulos externos que tiene mayor probabilidades de cambio. Por ejemplo podría cambiar axios por fetch y sólo implicaría tocar en un único punto.

_Pero puedo ir un paso más y eliminar la necesidad de que ProductList requiera de APIClient para poder utilizarlo, sólo debo de conocer de dónde extraer la url de API y establecerlo en el APIClient (quizás venga del environment, esté hardcodeado etc…)_

```typescript
export class ProductList {
  private apiClient: APIClient;

  constructor() {
    this.apiClient = new APIClient();
  }

  async getProducts(): Promise<Product[]> {
    const products = await this.apiClient.get<Product[]>(`/products`);
    return products;
  }
}
```

<p style="margin: 0;" class="text-center"><small>Lo sé, os estoy llevando al límite.</small></p>

_Vale bien… ¡Pero Jose, el patrón repositorio te permite crear test unitarios y/o sociales sin depender de cosas externas!_

Hablemos de testing…

<h3 style="margin-top: 36px;"><strong>Testing</strong></h3>

Aplicando hexagonal junto al patrón repositorio nos permite crear tests unitarios que cumplan con el acrónimo FIRST:

- **F**ast: sea rápido de ejecutar así obtenemos feedback rápido
- **I**solate: que esté aislado, no dependa de base de datos ni de que tenga internet
- **R**epeatable: que siempre dé el mismo resultado.
- **S**elf-validating: los tests se autovaliden sin tener que analizar si ha pasado o no
- **T**imely: los tests se deben crear antes de empezar a desarrollar el código (TDD).

Con los cambios que he ido introduciendo, veamos cómo podemos cumplir con la mayoría de éstas características.

<h3 style="margin-top: 36px; margin-bottom: 24px;">Tipos de tests</h3>

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">rauchg (@rauchg) <a href="https://twitter.com/rauchg/status/807626710350839808">https://twitter.com/rauchg/status/807626710350839808</a></p>&mdash; rauchg (@rauchg) <a href="https://twitter.com/rauchg/status/807626710350839808"></a></blockquote>

A medida que pasa el tiempo, estoy cada vez más de acuerdo con [Kent C Doods y su post sobre "Write tests. Not too many. Mostly integration](https://kentcdodds.com/blog/write-tests) (_no el tema del trofeo, pero sí en escribir más tests de integración_).

Pero, quizás cambiaría la frase a: “Write tests, mostly sociable tests”

Partiendo de esta idea, en cuanto a la historia de usuario se refiere, acabaría creando tests más sociables sobre la UI utilizando un servidor http con respuestas predefinidas.

Esto implica que acabaría incumplimiento la F del acrónimo FIRST dado que al crear servidores http, ésta podría no ser rápida.

<p style="margin-bottom: 16px;">Para “mockear” la petición HTTP utilizaría MSW:</p>

- MSW: [Mock Service Worker (MSW)](https://mswjs.io/) mejora las pruebas de los componentes que realizan llamadas a la API mediante la definición de mocks al nivel de red en lugar de mockear nuestro propio código.

¿Cómo acabaría testeando ésta nueva funcionalidad?

Acabaría omitiendo los tests unitarios (application) ya que carece de lógica y no me aporta valor, y me centraría más en crear tests de UI que prueban todo el flujo aunque falseando la respuesta de la API con MSW.

```tsx
// Home.test.tsx
import { render, screen } from "@testing-library/react";
import { productsHandlerException } from "./api-mocks/handlers";
import { mswServer } from "./api-mocks/msw-server";
import HomePage from "./HomePage";

describe("Component: HomePage", () => {
  it("displays returned products on successful fetch", async () => {
    render(<HomePage />);

    const displayedProducts = await screen.findAllByTestId(/product-id-\d+/);
    expect(displayedProducts).toHaveLength(2);
    expect(screen.getByText("Product Zero")).toBeInTheDocument();
    expect(screen.getByText("Product One")).toBeInTheDocument();
  });

  // en caso de que quisiera testear un error
  it("displays error message when fetching products raises error", async () => {
    mswServer.use(productsHandlerException);
    render(<HomePage />);

    const errorDisplay = await screen.findByText("Failed to fetch products");
    expect(errorDisplay).toBeInTheDocument();
    const displayedProducts = screen.queryAllByTestId(/product-id-\d+/);
    expect(displayedProducts).toEqual([]);
  });
});

// msw-server.ts
import { setupServer } from "msw/node";
import { handlers } from "./handlers";

export const mswServer = setupServer(...handlers);

// handlers.ts
import { rest } from "msw";

const mockProducts: Product[] = [
  { name: "Product Zero", image: "...", price: 10 },
  { name: "Product One", image: "...", price: 15 },
];

// en caso de querer tener handler globales para todos los tests
const productsHandler = rest.get(`.../products`, async (req, res, ctx) =>
  res(ctx.json(mockProducts))
);
export const handlers = [productsHandler];

// exporto en caso quiera crear test de una exception
export const productsHandlerException = rest.get(
  `.../products`,
  async (req, res, ctx) =>
    res(ctx.status(500), ctx.json({ message: "Deliberately broken request" }))
);
```

El hecho de falsear la respuesta con MSW puede dar la falsa seguridad de que todo está funcionando, por tanto, para sentirme más seguro a la hora de desplegar, acabaría creando, tests e2e (happy path) en un entorno pre o [test de humo](https://www.qalovers.com/2017/12/smoke-test.html) con cypress (o playwright).

Para cerrar, el último motivo por el cuál opto por simplificar las capas al aplicar arquitectura hexagonal es por cuestiones de optimización (tiempo de carga de la web). Pero éste punto hoy me lo saltaré, si te interesa a tí, no dudes en hacérnoslo saber 🙂

En resumen, seguimos poniendo en el centro la capa de dominio (y sus reglas de negocio si existiese) pero impulsamos la simplicidad: no necesitamos implementar capas intermedias entre la lógica de la aplicación, la fuente de datos y su representación visual.

Si sientes curiosidad por cómo queda todo, te dejo el repositorio con la feature desarrollada en [Github](https://github.com/CodiumTeam/post-hexagonal-blog-codium) o editarlo en [stackblitz](https://stackblitz.com/edit/vitest-dev-vitest-qyyby2?file=src%2FHome.test.tsx)

<script async="" src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
<style>
  .twitter-tweet {
    margin: 0 auto 24px auto !important;
    width: 100%;
  }
</style>
