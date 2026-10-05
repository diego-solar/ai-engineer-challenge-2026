-- Unir las clasificaciones con las reviews originales.
-- Incluye solamente los IDs de la ejecucion actual.
WITH current_results AS (
    SELECT
        c.thematic_category,
        c.improvement_area,
        r.overall_rating
    FROM review_classifications AS c
    JOIN reviews AS r ON r.review_id = c.review_id
    WHERE c.review_id IN ({placeholders})
)
SELECT
    c.thematic_category,
    COUNT(*) AS review_count,
    ROUND(AVG(c.overall_rating), 2) AS avg_overall_rating,

    -- Para esta categoria, contar las reviews de cada area.
    (
        SELECT a.improvement_area
        FROM current_results AS a
        WHERE a.thematic_category = c.thematic_category
        GROUP BY a.improvement_area
        ORDER BY COUNT(*) DESC, a.improvement_area ASC
        LIMIT 1
    ) AS most_frequent_improvement_area

FROM current_results AS c
GROUP BY c.thematic_category
ORDER BY review_count DESC, c.thematic_category;