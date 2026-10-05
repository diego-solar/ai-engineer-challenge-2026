INSERT INTO review_classifications
    (review_id, thematic_category, improvement_area)
VALUES (?, ?, ?)
ON CONFLICT(review_id) DO UPDATE SET
    thematic_category = excluded.thematic_category,
    improvement_area = excluded.improvement_area;