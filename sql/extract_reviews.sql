SELECT
    r.review_id,
    r.published_date,
    rv.name AS reviewer_name,
    st.name AS seat_type,
    tt.name AS traveller_type,
    -- Concatenar origin y destination con una coma y un espacio, manejando valores nulos
    CASE
      WHEN rt.origin IS NULL AND rt.destination IS NULL THEN NULL
      WHEN rt.origin IS NULL THEN rt.destination
      WHEN rt.destination IS NULL THEN rt.origin
      ELSE rt.origin || ', ' || rt.destination
    END AS origin_destination,
    -- Aircraft family (valores distintos son concatenados para evitar duplicados) a través de un subquery
    (
        SELECT GROUP_CONCAT(DISTINCT a.family)
        FROM review_aircraft ra
        JOIN aircraft a USING (aircraft_id)
        WHERE ra.review_id = r.review_id
    ) AS aircraft_family,
    -- Calificaciones generales y específicas
    r.overall_rating,
    vfm.score AS value_for_money,
    cabin.score AS cabin_staff_service,
    -- Concatenar header y body con dos saltos de línea entre ellos, manejando valores nulos
    CASE
      WHEN r.header IS NULL AND r.body IS NULL THEN NULL
      WHEN r.header IS NULL THEN r.body
      WHEN r.body IS NULL THEN r.header
      ELSE r.header || char(10) || char(10) || r.body
    END AS header_body
FROM reviews r
-- Joins completos con reviewers, seat_types; left join con traveller_types y routes
JOIN reviewers rv USING (reviewer_id)
JOIN seat_types st USING (seat_type_id)
LEFT JOIN traveller_types tt USING (traveller_type_id)
LEFT JOIN routes rt USING (route_id)
-- Doble join sobre la misma tabla con review_ratings para obtener las calificaciones de value_for_money y cabin_staff_service
JOIN rating_categories rc_vfm ON rc_vfm.code = 'value_for_money'
JOIN review_ratings vfm
  ON vfm.review_id = r.review_id
  AND vfm.category_id = rc_vfm.category_id
LEFT JOIN rating_categories rc_cabin ON rc_cabin.code = 'cabin_staff_service'
LEFT JOIN review_ratings cabin
  ON cabin.review_id = r.review_id
  AND cabin.category_id = rc_cabin.category_id
-- Criterios de filtrado: reviews verificadas, publicadas entre mayo y octubre de 2023, de Economy o Premium Economy, no recomendadas, con calificación general y valor por dinero menores o iguales a 2
WHERE r.verified = 1
  AND r.published_date BETWEEN '2023-05-01' AND '2023-10-31'
  AND st.name IN ('Economy Class', 'Premium Economy')
  AND r.recommended = 0
  AND r.overall_rating <= 2
  AND vfm.score <= 2
ORDER BY r.published_date DESC, r.review_id DESC;