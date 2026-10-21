-- kg_ingredientes tiene que estar en un rango creíble para este negocio (5.95 a 117.8).
select turno, kg_ingredientes from {{ ref('stg_parte') }}
where kg_ingredientes not between 5.95 and 117.8
