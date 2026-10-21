-- PLATA · el parte diario limpio: la limpieza que hiciste en la J3, ahora como modelo dbt.
-- Cada entrega del parte es una carpeta fecha_carga=… en bronce: aquí se leen todas juntas.
with bruto as (
    select *, parse_filename(filename) as archivo
    from {{ source('bronce', 'parte') }}
),
sin_dup as (
    -- una fila por turno
    select * from bruto
    qualify row_number() over (partition by turno order by fecha_carga desc) = 1
),
mediana_festival as (
    select festival, median(raciones::integer) as raciones_mediana
    from sin_dup
    where raciones::integer between 1 and 1000
    group by festival
)
select
    s.turno,
    s.fecha::date                                              as fecha,
    upper(trim(s.cocinero))                                         as cocinero,
    s.food_truck,
    s.festival,
    case when s.raciones::integer between 1 and 1000 then s.raciones::integer
         else round(m.raciones_mediana)::integer end               as raciones,
    not (s.raciones::integer between 1 and 1000)                   as raciones_corregido,
    s.kg_ingredientes::double                                              as kg_ingredientes,
    s.importe_eur::double                                      as importe_eur,
    s.incidencia,
    s.archivo,
    s.fecha_carga
from sin_dup s
join mediana_festival m using (festival)
