WITH current_results AS (
    SELECT
        c.thematic_category,
        c.improvement_area,
        r.overall_rating
    FROM review_classifications AS c
    JOIN reviews AS r ON r.review_id = c.review_id
    WHERE c.review_id IN ({placeholders})
),
theme_stats AS (
    SELECT
        thematic_category,
        COUNT(*) AS review_count,
        ROUND(AVG(overall_rating), 2) AS avg_overall_rating
    FROM current_results
    GROUP BY thematic_category
),
area_counts AS (
    SELECT
        thematic_category,
        improvement_area,
        COUNT(*) AS area_count
    FROM current_results
    GROUP BY thematic_category, improvement_area
),
ranked_areas AS (
    SELECT
        thematic_category,
        improvement_area,
        ROW_NUMBER() OVER (
            PARTITION BY thematic_category
            ORDER BY area_count DESC, improvement_area ASC
        ) AS position
    FROM area_counts
)
SELECT
    s.thematic_category,
    s.review_count,
    s.avg_overall_rating,
    a.improvement_area AS most_frequent_improvement_area
FROM theme_stats AS s
JOIN ranked_areas AS a
    ON a.thematic_category = s.thematic_category
WHERE a.position = 1
ORDER BY s.review_count DESC, s.thematic_category;