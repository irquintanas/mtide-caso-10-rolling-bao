# Caso 10 · Rolling Bao — el encargo

> Negocio y datos **ficticios**, creados para la asignatura. Es tu mismo caso de la J3.

## Qué ha pasado desde la J3

En la J3 limpiaste el parte en un cuaderno y contestaste tres preguntas. Rolling Bao quiere su parte de turnos cargado solo. Y este fin de semana tiene cuatro food trucks en cuatro festivales, con los pedidos registrados en sus TPV: quiere saber **qué festival rinde más por hora abierta**.

Ahora conviertes aquel cuaderno en un **lakehouse** de verdad, en tu propio repositorio, y publicas un **portal** que
cuenta lo que has hecho. Cómo preparar el repositorio y el ciclo de trabajo de cada bloque: [README.md](README.md).

## Lo que tienes al empezar

- En bronce, el parte de la J3: `lakehouse/bronce/parte/fecha_carga=2026-06-15/`.
- En `dbt/models/plata/stg_parte.sql`, la limpieza que hiciste en la J3, con unos tests básicos (`_plata.yml`, `dbt/tests/`).
- `dbt build` en verde. La capa oro, vacía: la construyes tú.
- En `paginas/`, las cuatro páginas del portal que escribirás, cada una con un guion de lo que debe contar.

**Bronce no se toca nunca**: todo arreglo va en plata.

---

## Bloque 1 · La remesa nueva · rama `remesa`

1. `python herramientas/sistema_simulado.py remesa`: llega una entrega nueva del parte en `bronce/parte/fecha_carga=2026-06-25/` (unos diez días más de turnos).
2. `dbt build --project-dir dbt --profiles-dir dbt`. La remesa la han rellenado los cocineros desde el móvil, cada uno a su manera. El test de valores aceptados te dirá dónde.
3. Arregla `dbt/models/plata/stg_parte.sql` hasta que `dbt build` quede en verde y el problema esté resuelto (no siempre hay un test que lo grite: a veces tienes que escribirlo tú). Deja un comentario en el SQL: **qué** venía mal y **por qué** lo arreglas así.
4. Escribe `paginas/1-remesa.md`.
5. Pull request en tu repositorio, Actions en verde y lo fusionas.

## Bloque 2 · El oro · rama `oro`

Crea en `dbt/models/oro/` estos modelos, **con estos nombres exactos** (el portal y la jornada de Visualización los leen así):

| Modelo | Qué tiene |
|---|---|
| `dim_cocinero` | una fila por cada valor distinto de `cocinero` |
| `dim_food_truck` | una fila por cada valor distinto de `food_truck` |
| `dim_festival` | una fila por cada valor distinto de `festival` |
| `fact_turnos` | un turno por fila: `turno`, `fecha`, `cocinero`, `food_truck`, `festival`, `raciones`, `kg_ingredientes`, `importe_eur`, `con_incidencia` |
| `pregunta_1` | ¿Qué **festival** deja menos ingreso por ración? Una fila por `festival`, con `festival` en la primera columna y `ingreso_racion` (€/ración), de menor a mayor |
| `pregunta_2` | ¿Qué **cocinero** gasta más ingredientes por ración? Una fila por `cocinero`, con `cocinero` en la primera columna y `kg_100raciones` (kg por 100 raciones), de mayor a menor |
| `pregunta_3` | ¿Qué **food truck** acumula más incidencias por cada 1.000 raciones? Una fila por `food_truck`, con `food_truck` en la primera columna y `incidencias_1000raciones` (incidencias por 1.000 raciones), de mayor a menor |

En un `_oro.yml`, sus tests: en las dimensiones, `unique` y `not_null`; en el hecho, `unique` en `turno` y `relationships` con cada dimensión.

Escribe `paginas/2-oro.md`: tu estrella y las tres respuestas. Con la remesa nueva (un 25 % más de datos), ¿siguen saliendo las mismas que en la J3? Pull request, verde, fusionas.

## Bloque 3 · Fuentes nuevas · rama `fuentes`

1. `python herramientas/sistema_simulado.py fuentes`: llegan estos ficheros a bronce y quedan declarados en `dbt/models/plata/_fuentes.yml`.

| Fichero | Qué es | Columnas |
|---|---|---|
| `bronce/calendario/calendario.csv` | en qué festival estuvo (o está hoy) cada food truck, y su horario de apertura y cierre | fecha, festival, food_truck, hora_apertura, hora_cierre |
| `bronce/eventos/pedidos_festival_2026-06-27.json` | Los TPV de los food trucks exportan un registro con cada pedido de hoy: la hora a la que se hizo (`ts_evento`) y la hora a la que llegó al servidor (`ts_envio`). | pedido_id, food_truck, festival, ts_evento, ts_envio, raciones, importe |

2. **El giro.** Uno de los food trucks está en un recinto **sin cobertura**: guarda los pedidos y los sincroniza **de golpe** cada cierto tiempo. Si cuentas por la hora de llegada al servidor, su curva de ventas es mentira.
3. Modelos de plata: `stg_calendario` y `stg_eventos` (el registro lo lees con `source('bronce', 'eventos')`).
4. **Test protagonista.** **Todo festival del parte existe en el calendario.** Escríbelo como test. Para que pase, no vale con `upper()`/`trim()`: necesitas una tabla de equivalencias. Hazla como **seed** (`seeds/…csv`) y úsala en plata.
5. **Pregunta 4** (`dbt/models/oro/pregunta_4.sql`): ¿Qué festival rinde más **por hora abierta** y cuál es su mejor hora? Usa la hora del pedido, no la del envío.
6. Escribe `paginas/3-fuentes.md`. Pull request, verde, fusionas.

## Bloque 4 · El memo · rama `memo`

Escribe `paginas/memo.md`: el memo para la dirección de Rolling Bao, con las cuatro respuestas citadas con marcas. La comprobación exige que existan `pregunta_1` a `pregunta_4`. Repasa el portal entero antes de fusionar.

---

## Lo que se entrega

- Tu repositorio en tu cuenta, con los cuatro pull requests fusionados y la última ejecución de `main` en verde.
- Tu portal publicado, con sus cuatro páginas escritas, y tu `dbt-docs`.
- La presentación oral (5 minutos): con tu portal en pantalla, el problema de calidad, tu test protagonista, las cuatro respuestas y tu recomendación.
