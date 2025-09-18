-- Data Summary

SELECT
	COUNT(review_id) total_reviews,
	ROUND(AVG(average_rating), 4) avearage_rating,
    ROUND(AVG(CASE
				WHEN recommended = 'TRUE' THEN 1
                ELSE 0
                END), 4) recommendation
    FROM fct_review;

	-- find % of verified and unverified reviews

SELECT
  CASE
    WHEN VERIFIED = 'True' THEN 'Verified'
    ELSE 'Unverified'
  END verified,
COUNT(*) count,
ROUND(COUNT(*) / SUM(COUNT(*)) OVER (), 4) percentage
FROM fct_review
GROUP BY verified
ORDER BY verified;

-- Satisfaction Metrics

	-- average service ratings

SELECT
	'seat_comfort' category,
    ROUND(AVG(seat_comfort),4) avg_rating -- avg seat comfort
FROM fct_review
GROUP BY 'seat_comfort'
UNION
SELECT
	'cabin_staff_service' category,
    ROUND(AVG(cabin_staff_service), 4) -- avg_cabin_staff_service
FROM fct_review
GROUP BY 'cabin_staff_service'
UNION
SELECT
	'food_and_beverages' category,
    ROUND(AVG(food_and_beverages), 4) -- avg_food_and_beverages
FROM fct_review
GROUP BY 'food_and_beverages'
UNION
SELECT
	'inflight_entertainment' category,
    ROUND(AVG(inflight_entertainment), 4) -- avg_inflight_entertainment
FROM fct_review
GROUP BY 'inflight_entertainment'
UNION
SELECT
	'ground_service' category,
    ROUND(AVG(ground_service), 4) -- avg_ground_service
FROM fct_review
GROUP BY 'ground_service'
UNION
SELECT
	'wifi_and_connectivity' category,
    ROUND(AVG(wifi_and_connectivity), 4) -- avg_wifi_and_connectivity
FROM fct_review
GROUP BY 'wifi_and_connectivity'
UNION
SELECT
	'value_for_money' category,
    ROUND(AVG(value_for_money), 4) -- avg_value_for_money
FROM fct_review
GROUP BY 'value_for_money';

-- Customer Satisfaction Factors Correlation Analysis

	-- clean nulls

SELECT 
  cabin_staff_service,
  food_and_beverages,
  ground_service,
  inflight_entertainment,
  seat_comfort,
  wifi_and_connectivity,
  value_for_money
FROM fct_review
WHERE cabin_staff_service IS NOT NULL
  AND food_and_beverages IS NOT NULL
  AND ground_service IS NOT NULL
  AND inflight_entertainment IS NOT NULL
  AND seat_comfort IS NOT NULL
  AND wifi_and_connectivity IS NOT NULL
  AND value_for_money IS NOT NULL
  AND seat_type != 'Economy Class'; -- change '!=' or '=' to select eco or non-eco seats

	-- create correlation matrix table
    -- 7×7 correlation matrix from fct_review
    -- metrics above
    -- expression pattern:
    -- (AVG(x * y) - AVG(x) * AVG(y)) / NULLIF( STDDEV(x) * STDDEV(y), 0 )

CREATE OR REPLACE VIEW correlation_matrix AS
SELECT
  1 AS join_key,
  t.metric_x,
  t.metric_y,
  t.correlation
FROM (    

/* =========================
   UPPER TRIANGLE (UNIQUE PAIRS)
   ========================= */
   
SELECT 'cabin_staff_service' AS metric_x, 'cabin_staff_service' AS metric_y, 1.0 AS correlation
UNION ALL
SELECT 'food_and_beverages','food_and_beverages',1.0
UNION ALL
SELECT 'ground_service','ground_service',1.0
UNION ALL
SELECT 'inflight_entertainment','inflight_entertainment',1.0
UNION ALL
SELECT 'seat_comfort','seat_comfort',1.0
UNION ALL
SELECT 'wifi_and_connectivity','wifi_and_connectivity',1.0
UNION ALL
SELECT 'value_for_money','value_for_money',1.0

UNION ALL
SELECT 'cabin_staff_service','food_and_beverages',
       (AVG(cabin_staff_service * food_and_beverages) - AVG(cabin_staff_service) * AVG(food_and_beverages))
       / NULLIF(STDDEV(cabin_staff_service) * STDDEV(food_and_beverages), 0)
FROM fct_review
WHERE cabin_staff_service IS NOT NULL AND food_and_beverages IS NOT NULL

UNION ALL
SELECT 'cabin_staff_service','ground_service',
       (AVG(cabin_staff_service * ground_service) - AVG(cabin_staff_service) * AVG(ground_service))
       / NULLIF(STDDEV(cabin_staff_service) * STDDEV(ground_service), 0)
FROM fct_review
WHERE cabin_staff_service IS NOT NULL AND ground_service IS NOT NULL

UNION ALL
SELECT 'cabin_staff_service','inflight_entertainment',
       (AVG(cabin_staff_service * inflight_entertainment) - AVG(cabin_staff_service) * AVG(inflight_entertainment))
       / NULLIF(STDDEV(cabin_staff_service) * STDDEV(inflight_entertainment), 0)
FROM fct_review
WHERE cabin_staff_service IS NOT NULL AND inflight_entertainment IS NOT NULL

UNION ALL
SELECT 'cabin_staff_service','seat_comfort',
       (AVG(cabin_staff_service * seat_comfort) - AVG(cabin_staff_service) * AVG(seat_comfort))
       / NULLIF(STDDEV(cabin_staff_service) * STDDEV(seat_comfort), 0)
FROM fct_review
WHERE cabin_staff_service IS NOT NULL AND seat_comfort IS NOT NULL

UNION ALL
SELECT 'cabin_staff_service','wifi_and_connectivity',
       (AVG(cabin_staff_service * wifi_and_connectivity) - AVG(cabin_staff_service) * AVG(wifi_and_connectivity))
       / NULLIF(STDDEV(cabin_staff_service) * STDDEV(wifi_and_connectivity), 0)
FROM fct_review
WHERE cabin_staff_service IS NOT NULL AND wifi_and_connectivity IS NOT NULL

UNION ALL
SELECT 'cabin_staff_service','value_for_money',
       (AVG(cabin_staff_service * value_for_money) - AVG(cabin_staff_service) * AVG(value_for_money))
       / NULLIF(STDDEV(cabin_staff_service) * STDDEV(value_for_money), 0)
FROM fct_review
WHERE cabin_staff_service IS NOT NULL AND value_for_money IS NOT NULL

UNION ALL
SELECT 'food_and_beverages','ground_service',
       (AVG(food_and_beverages * ground_service) - AVG(food_and_beverages) * AVG(ground_service))
       / NULLIF(STDDEV(food_and_beverages) * STDDEV(ground_service), 0)
FROM fct_review
WHERE food_and_beverages IS NOT NULL AND ground_service IS NOT NULL

UNION ALL
SELECT 'food_and_beverages','inflight_entertainment',
       (AVG(food_and_beverages * inflight_entertainment) - AVG(food_and_beverages) * AVG(inflight_entertainment))
       / NULLIF(STDDEV(food_and_beverages) * STDDEV(inflight_entertainment), 0)
FROM fct_review
WHERE food_and_beverages IS NOT NULL AND inflight_entertainment IS NOT NULL

UNION ALL
SELECT 'food_and_beverages','seat_comfort',
       (AVG(food_and_beverages * seat_comfort) - AVG(food_and_beverages) * AVG(seat_comfort))
       / NULLIF(STDDEV(food_and_beverages) * STDDEV(seat_comfort), 0)
FROM fct_review
WHERE food_and_beverages IS NOT NULL AND seat_comfort IS NOT NULL

UNION ALL
SELECT 'food_and_beverages','wifi_and_connectivity',
       (AVG(food_and_beverages * wifi_and_connectivity) - AVG(food_and_beverages) * AVG(wifi_and_connectivity))
       / NULLIF(STDDEV(food_and_beverages) * STDDEV(wifi_and_connectivity), 0)
FROM fct_review
WHERE food_and_beverages IS NOT NULL AND wifi_and_connectivity IS NOT NULL

UNION ALL
SELECT 'food_and_beverages','value_for_money',
       (AVG(food_and_beverages * value_for_money) - AVG(food_and_beverages) * AVG(value_for_money))
       / NULLIF(STDDEV(food_and_beverages) * STDDEV(value_for_money), 0)
FROM fct_review
WHERE food_and_beverages IS NOT NULL AND value_for_money IS NOT NULL

UNION ALL
SELECT 'ground_service','inflight_entertainment',
       (AVG(ground_service * inflight_entertainment) - AVG(ground_service) * AVG(inflight_entertainment))
       / NULLIF(STDDEV(ground_service) * STDDEV(inflight_entertainment), 0)
FROM fct_review
WHERE ground_service IS NOT NULL AND inflight_entertainment IS NOT NULL

UNION ALL
SELECT 'ground_service','seat_comfort',
       (AVG(ground_service * seat_comfort) - AVG(ground_service) * AVG(seat_comfort))
       / NULLIF(STDDEV(ground_service) * STDDEV(seat_comfort), 0)
FROM fct_review
WHERE ground_service IS NOT NULL AND seat_comfort IS NOT NULL

UNION ALL
SELECT 'ground_service','wifi_and_connectivity',
       (AVG(ground_service * wifi_and_connectivity) - AVG(ground_service) * AVG(wifi_and_connectivity))
       / NULLIF(STDDEV(ground_service) * STDDEV(wifi_and_connectivity), 0)
FROM fct_review
WHERE ground_service IS NOT NULL AND wifi_and_connectivity IS NOT NULL

UNION ALL
SELECT 'ground_service','value_for_money',
       (AVG(ground_service * value_for_money) - AVG(ground_service) * AVG(value_for_money))
       / NULLIF(STDDEV(ground_service) * STDDEV(value_for_money), 0)
FROM fct_review
WHERE ground_service IS NOT NULL AND value_for_money IS NOT NULL

UNION ALL
SELECT 'inflight_entertainment','seat_comfort',
       (AVG(inflight_entertainment * seat_comfort) - AVG(inflight_entertainment) * AVG(seat_comfort))
       / NULLIF(STDDEV(inflight_entertainment) * STDDEV(seat_comfort), 0)
FROM fct_review
WHERE inflight_entertainment IS NOT NULL AND seat_comfort IS NOT NULL

UNION ALL
SELECT 'inflight_entertainment','wifi_and_connectivity',
       (AVG(inflight_entertainment * wifi_and_connectivity) - AVG(inflight_entertainment) * AVG(wifi_and_connectivity))
       / NULLIF(STDDEV(inflight_entertainment) * STDDEV(wifi_and_connectivity), 0)
FROM fct_review
WHERE inflight_entertainment IS NOT NULL AND wifi_and_connectivity IS NOT NULL

UNION ALL
SELECT 'inflight_entertainment','value_for_money',
       (AVG(inflight_entertainment * value_for_money) - AVG(inflight_entertainment) * AVG(value_for_money))
       / NULLIF(STDDEV(inflight_entertainment) * STDDEV(value_for_money), 0)
FROM fct_review
WHERE inflight_entertainment IS NOT NULL AND value_for_money IS NOT NULL

UNION ALL
SELECT 'seat_comfort','wifi_and_connectivity',
       (AVG(seat_comfort * wifi_and_connectivity) - AVG(seat_comfort) * AVG(wifi_and_connectivity))
       / NULLIF(STDDEV(seat_comfort) * STDDEV(wifi_and_connectivity), 0)
FROM fct_review
WHERE seat_comfort IS NOT NULL AND wifi_and_connectivity IS NOT NULL

UNION ALL
SELECT 'seat_comfort','value_for_money',
       (AVG(seat_comfort * value_for_money) - AVG(seat_comfort) * AVG(value_for_money))
       / NULLIF(STDDEV(seat_comfort) * STDDEV(value_for_money), 0)
FROM fct_review
WHERE seat_comfort IS NOT NULL AND value_for_money IS NOT NULL

UNION ALL
SELECT 'wifi_and_connectivity','value_for_money',
       (AVG(wifi_and_connectivity * value_for_money) - AVG(wifi_and_connectivity) * AVG(value_for_money))
       / NULLIF(STDDEV(wifi_and_connectivity) * STDDEV(value_for_money), 0)
FROM fct_review
WHERE wifi_and_connectivity IS NOT NULL AND value_for_money IS NOT NULL

/* =========================
   lower triangle (mirror the pairs)
   ========================= */
   
UNION ALL
SELECT 'food_and_beverages','cabin_staff_service',
       (AVG(cabin_staff_service * food_and_beverages) - AVG(cabin_staff_service) * AVG(food_and_beverages))
       / NULLIF(STDDEV(cabin_staff_service) * STDDEV(food_and_beverages), 0)
FROM fct_review
WHERE cabin_staff_service IS NOT NULL AND food_and_beverages IS NOT NULL

UNION ALL
SELECT 'ground_service','cabin_staff_service',
       (AVG(cabin_staff_service * ground_service) - AVG(cabin_staff_service) * AVG(ground_service))
       / NULLIF(STDDEV(cabin_staff_service) * STDDEV(ground_service), 0)
FROM fct_review
WHERE cabin_staff_service IS NOT NULL AND ground_service IS NOT NULL

UNION ALL
SELECT 'inflight_entertainment','cabin_staff_service',
       (AVG(cabin_staff_service * inflight_entertainment) - AVG(cabin_staff_service) * AVG(inflight_entertainment))
       / NULLIF(STDDEV(cabin_staff_service) * STDDEV(inflight_entertainment), 0)
FROM fct_review
WHERE cabin_staff_service IS NOT NULL AND inflight_entertainment IS NOT NULL

UNION ALL
SELECT 'seat_comfort','cabin_staff_service',
       (AVG(cabin_staff_service * seat_comfort) - AVG(cabin_staff_service) * AVG(seat_comfort))
       / NULLIF(STDDEV(cabin_staff_service) * STDDEV(seat_comfort), 0)
FROM fct_review
WHERE cabin_staff_service IS NOT NULL AND seat_comfort IS NOT NULL

UNION ALL
SELECT 'wifi_and_connectivity','cabin_staff_service',
       (AVG(cabin_staff_service * wifi_and_connectivity) - AVG(cabin_staff_service) * AVG(wifi_and_connectivity))
       / NULLIF(STDDEV(cabin_staff_service) * STDDEV(wifi_and_connectivity), 0)
FROM fct_review
WHERE cabin_staff_service IS NOT NULL AND wifi_and_connectivity IS NOT NULL

UNION ALL
SELECT 'value_for_money','cabin_staff_service',
       (AVG(cabin_staff_service * value_for_money) - AVG(cabin_staff_service) * AVG(value_for_money))
       / NULLIF(STDDEV(cabin_staff_service) * STDDEV(value_for_money), 0)
FROM fct_review
WHERE cabin_staff_service IS NOT NULL AND value_for_money IS NOT NULL

UNION ALL
SELECT 'ground_service','food_and_beverages',
       (AVG(food_and_beverages * ground_service) - AVG(food_and_beverages) * AVG(ground_service))
       / NULLIF(STDDEV(food_and_beverages) * STDDEV(ground_service), 0)
FROM fct_review
WHERE food_and_beverages IS NOT NULL AND ground_service IS NOT NULL

UNION ALL
SELECT 'inflight_entertainment','food_and_beverages',
       (AVG(food_and_beverages * inflight_entertainment) - AVG(food_and_beverages) * AVG(inflight_entertainment))
       / NULLIF(STDDEV(food_and_beverages) * STDDEV(inflight_entertainment), 0)
FROM fct_review
WHERE food_and_beverages IS NOT NULL AND inflight_entertainment IS NOT NULL

UNION ALL
SELECT 'seat_comfort','food_and_beverages',
       (AVG(food_and_beverages * seat_comfort) - AVG(food_and_beverages) * AVG(seat_comfort))
       / NULLIF(STDDEV(food_and_beverages) * STDDEV(seat_comfort), 0)
FROM fct_review
WHERE food_and_beverages IS NOT NULL AND seat_comfort IS NOT NULL

UNION ALL
SELECT 'wifi_and_connectivity','food_and_beverages',
       (AVG(food_and_beverages * wifi_and_connectivity) - AVG(food_and_beverages) * AVG(wifi_and_connectivity))
       / NULLIF(STDDEV(food_and_beverages) * STDDEV(wifi_and_connectivity), 0)
FROM fct_review
WHERE food_and_beverages IS NOT NULL AND wifi_and_connectivity IS NOT NULL

UNION ALL
SELECT 'value_for_money','food_and_beverages',
       (AVG(food_and_beverages * value_for_money) - AVG(food_and_beverages) * AVG(value_for_money))
       / NULLIF(STDDEV(food_and_beverages) * STDDEV(value_for_money), 0)
FROM fct_review
WHERE food_and_beverages IS NOT NULL AND value_for_money IS NOT NULL

UNION ALL
SELECT 'inflight_entertainment','ground_service',
       (AVG(ground_service * inflight_entertainment) - AVG(ground_service) * AVG(inflight_entertainment))
       / NULLIF(STDDEV(ground_service) * STDDEV(inflight_entertainment), 0)
FROM fct_review
WHERE ground_service IS NOT NULL AND inflight_entertainment IS NOT NULL

UNION ALL
SELECT 'seat_comfort','ground_service',
       (AVG(ground_service * seat_comfort) - AVG(ground_service) * AVG(seat_comfort))
       / NULLIF(STDDEV(ground_service) * STDDEV(seat_comfort), 0)
FROM fct_review
WHERE ground_service IS NOT NULL AND seat_comfort IS NOT NULL

UNION ALL
SELECT 'wifi_and_connectivity','ground_service',
       (AVG(ground_service * wifi_and_connectivity) - AVG(ground_service) * AVG(wifi_and_connectivity))
       / NULLIF(STDDEV(ground_service) * STDDEV(wifi_and_connectivity), 0)
FROM fct_review
WHERE ground_service IS NOT NULL AND wifi_and_connectivity IS NOT NULL

UNION ALL
SELECT 'value_for_money','ground_service',
       (AVG(ground_service * value_for_money) - AVG(ground_service) * AVG(value_for_money))
       / NULLIF(STDDEV(ground_service) * STDDEV(value_for_money), 0)
FROM fct_review
WHERE ground_service IS NOT NULL AND value_for_money IS NOT NULL

UNION ALL
SELECT 'seat_comfort','inflight_entertainment',
       (AVG(inflight_entertainment * seat_comfort) - AVG(inflight_entertainment) * AVG(seat_comfort))
       / NULLIF(STDDEV(inflight_entertainment) * STDDEV(seat_comfort), 0)
FROM fct_review
WHERE inflight_entertainment IS NOT NULL AND seat_comfort IS NOT NULL

UNION ALL
SELECT 'wifi_and_connectivity','inflight_entertainment',
       (AVG(inflight_entertainment * wifi_and_connectivity) - AVG(inflight_entertainment) * AVG(wifi_and_connectivity))
       / NULLIF(STDDEV(inflight_entertainment) * STDDEV(wifi_and_connectivity), 0)
FROM fct_review
WHERE inflight_entertainment IS NOT NULL AND wifi_and_connectivity IS NOT NULL

UNION ALL
SELECT 'value_for_money','inflight_entertainment',
       (AVG(inflight_entertainment * value_for_money) - AVG(inflight_entertainment) * AVG(value_for_money))
       / NULLIF(STDDEV(inflight_entertainment) * STDDEV(value_for_money), 0)
FROM fct_review
WHERE inflight_entertainment IS NOT NULL AND value_for_money IS NOT NULL

UNION ALL
SELECT 'wifi_and_connectivity','seat_comfort',
       (AVG(seat_comfort * wifi_and_connectivity) - AVG(seat_comfort) * AVG(wifi_and_connectivity))
       / NULLIF(STDDEV(seat_comfort) * STDDEV(wifi_and_connectivity), 0)
FROM fct_review
WHERE seat_comfort IS NOT NULL AND wifi_and_connectivity IS NOT NULL

UNION ALL
SELECT 'value_for_money','seat_comfort',
       (AVG(seat_comfort * value_for_money) - AVG(seat_comfort) * AVG(value_for_money))
       / NULLIF(STDDEV(seat_comfort) * STDDEV(value_for_money), 0)
FROM fct_review
WHERE seat_comfort IS NOT NULL AND value_for_money IS NOT NULL

UNION ALL
SELECT 'value_for_money','wifi_and_connectivity',
       (AVG(wifi_and_connectivity * value_for_money) - AVG(wifi_and_connectivity) * AVG(value_for_money))
       / NULLIF(STDDEV(wifi_and_connectivity) * STDDEV(value_for_money), 0)
FROM fct_review
WHERE wifi_and_connectivity IS NOT NULL AND value_for_money IS NOT NULL
) AS t;

SELECT * FROM correlation_matrix;