-- Crear la tabla review_classifications para almacenar las clasificaciones temáticas y áreas de mejora de cada review
CREATE TABLE IF NOT EXISTS review_classifications (
    review_id INTEGER PRIMARY KEY,
    thematic_category TEXT NOT NULL,
    improvement_area TEXT NOT NULL,
    FOREIGN KEY (review_id) REFERENCES reviews(review_id)
);