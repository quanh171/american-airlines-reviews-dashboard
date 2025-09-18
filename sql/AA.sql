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

WITH base AS (
  SELECT
    CASE
      WHEN LOWER(seat_type) = 'economy class' THEN 'economy class'
      ELSE 'non-economy class'
    END AS seat_group,
    cabin_staff_service,
    food_and_beverages,
    ground_service,
    inflight_entertainment,
    seat_comfort,
    wifi_and_connectivity,
    value_for_money
  FROM fct_review
),
corr_upper AS (
  /* diagonals */
  SELECT seat_group,'cabin_staff_service' AS metric_x,'cabin_staff_service' AS metric_y, 1.0 AS correlation FROM base GROUP BY seat_group
  UNION ALL SELECT seat_group,'food_and_beverages','food_and_beverages',1.0 FROM base GROUP BY seat_group
  UNION ALL SELECT seat_group,'ground_service','ground_service',1.0 FROM base GROUP BY seat_group
  UNION ALL SELECT seat_group,'inflight_entertainment','inflight_entertainment',1.0 FROM base GROUP BY seat_group
  UNION ALL SELECT seat_group,'seat_comfort','seat_comfort',1.0 FROM base GROUP BY seat_group
  UNION ALL SELECT seat_group,'wifi_and_connectivity','wifi_and_connectivity',1.0 FROM base GROUP BY seat_group
  UNION ALL SELECT seat_group,'value_for_money','value_for_money',1.0 FROM base GROUP BY seat_group

  /* upper triangle (21 pairs) */
  UNION ALL SELECT seat_group,'cabin_staff_service','food_and_beverages',
    (AVG(cabin_staff_service*food_and_beverages)-AVG(cabin_staff_service)*AVG(food_and_beverages))
    / NULLIF(STDDEV_SAMP(cabin_staff_service)*STDDEV_SAMP(food_and_beverages),0)
    FROM base WHERE cabin_staff_service IS NOT NULL AND food_and_beverages IS NOT NULL GROUP BY seat_group
  UNION ALL SELECT seat_group,'cabin_staff_service','ground_service',
    (AVG(cabin_staff_service*ground_service)-AVG(cabin_staff_service)*AVG(ground_service))
    / NULLIF(STDDEV_SAMP(cabin_staff_service)*STDDEV_SAMP(ground_service),0)
    FROM base WHERE cabin_staff_service IS NOT NULL AND ground_service IS NOT NULL GROUP BY seat_group
  UNION ALL SELECT seat_group,'cabin_staff_service','inflight_entertainment',
    (AVG(cabin_staff_service*inflight_entertainment)-AVG(cabin_staff_service)*AVG(inflight_entertainment))
    / NULLIF(STDDEV_SAMP(cabin_staff_service)*STDDEV_SAMP(inflight_entertainment),0)
    FROM base WHERE cabin_staff_service IS NOT NULL AND inflight_entertainment IS NOT NULL GROUP BY seat_group
  UNION ALL SELECT seat_group,'cabin_staff_service','seat_comfort',
    (AVG(cabin_staff_service*seat_comfort)-AVG(cabin_staff_service)*AVG(seat_comfort))
    / NULLIF(STDDEV_SAMP(cabin_staff_service)*STDDEV_SAMP(seat_comfort),0)
    FROM base WHERE cabin_staff_service IS NOT NULL AND seat_comfort IS NOT NULL GROUP BY seat_group
  UNION ALL SELECT seat_group,'cabin_staff_service','wifi_and_connectivity',
    (AVG(cabin_staff_service*wifi_and_connectivity)-AVG(cabin_staff_service)*AVG(wifi_and_connectivity))
    / NULLIF(STDDEV_SAMP(cabin_staff_service)*STDDEV_SAMP(wifi_and_connectivity),0)
    FROM base WHERE cabin_staff_service IS NOT NULL AND wifi_and_connectivity IS NOT NULL GROUP BY seat_group
  UNION ALL SELECT seat_group,'cabin_staff_service','value_for_money',
    (AVG(cabin_staff_service*value_for_money)-AVG(cabin_staff_service)*AVG(value_for_money))
    / NULLIF(STDDEV_SAMP(cabin_staff_service)*STDDEV_SAMP(value_for_money),0)
    FROM base WHERE cabin_staff_service IS NOT NULL AND value_for_money IS NOT NULL GROUP BY seat_group

  UNION ALL SELECT seat_group,'food_and_beverages','ground_service',
    (AVG(food_and_beverages*ground_service)-AVG(food_and_beverages)*AVG(ground_service))
    / NULLIF(STDDEV_SAMP(food_and_beverages)*STDDEV_SAMP(ground_service),0)
    FROM base WHERE food_and_beverages IS NOT NULL AND ground_service IS NOT NULL GROUP BY seat_group
  UNION ALL SELECT seat_group,'food_and_beverages','inflight_entertainment',
    (AVG(food_and_beverages*inflight_entertainment)-AVG(food_and_beverages)*AVG(inflight_entertainment))
    / NULLIF(STDDEV_SAMP(food_and_beverages)*STDDEV_SAMP(inflight_entertainment),0)
    FROM base WHERE food_and_beverages IS NOT NULL AND inflight_entertainment IS NOT NULL GROUP BY seat_group
  UNION ALL SELECT seat_group,'food_and_beverages','seat_comfort',
    (AVG(food_and_beverages*seat_comfort)-AVG(food_and_beverages)*AVG(seat_comfort))
    / NULLIF(STDDEV_SAMP(food_and_beverages)*STDDEV_SAMP(seat_comfort),0)
    FROM base WHERE food_and_beverages IS NOT NULL AND seat_comfort IS NOT NULL GROUP BY seat_group
  UNION ALL SELECT seat_group,'food_and_beverages','wifi_and_connectivity',
    (AVG(food_and_beverages*wifi_and_connectivity)-AVG(food_and_beverages)*AVG(wifi_and_connectivity))
    / NULLIF(STDDEV_SAMP(food_and_beverages)*STDDEV_SAMP(wifi_and_connectivity),0)
    FROM base WHERE food_and_beverages IS NOT NULL AND wifi_and_connectivity IS NOT NULL GROUP BY seat_group
  UNION ALL SELECT seat_group,'food_and_beverages','value_for_money',
    (AVG(food_and_beverages*value_for_money)-AVG(food_and_beverages)*AVG(value_for_money))
    / NULLIF(STDDEV_SAMP(food_and_beverages)*STDDEV_SAMP(value_for_money),0)
    FROM base WHERE food_and_beverages IS NOT NULL AND value_for_money IS NOT NULL GROUP BY seat_group

  UNION ALL SELECT seat_group,'ground_service','inflight_entertainment',
    (AVG(ground_service*inflight_entertainment)-AVG(ground_service)*AVG(inflight_entertainment))
    / NULLIF(STDDEV_SAMP(ground_service)*STDDEV_SAMP(inflight_entertainment),0)
    FROM base WHERE ground_service IS NOT NULL AND inflight_entertainment IS NOT NULL GROUP BY seat_group
  UNION ALL SELECT seat_group,'ground_service','seat_comfort',
    (AVG(ground_service*seat_comfort)-AVG(ground_service)*AVG(seat_comfort))
    / NULLIF(STDDEV_SAMP(ground_service)*STDDEV_SAMP(seat_comfort),0)
    FROM base WHERE ground_service IS NOT NULL AND seat_comfort IS NOT NULL GROUP BY seat_group
  UNION ALL SELECT seat_group,'ground_service','wifi_and_connectivity',
    (AVG(ground_service*wifi_and_connectivity)-AVG(ground_service)*AVG(wifi_and_connectivity))
    / NULLIF(STDDEV_SAMP(ground_service)*STDDEV_SAMP(wifi_and_connectivity),0)
    FROM base WHERE ground_service IS NOT NULL AND wifi_and_connectivity IS NOT NULL GROUP BY seat_group
  UNION ALL SELECT seat_group,'ground_service','value_for_money',
    (AVG(ground_service*value_for_money)-AVG(ground_service)*AVG(value_for_money))
    / NULLIF(STDDEV_SAMP(ground_service)*STDDEV_SAMP(value_for_money),0)
    FROM base WHERE ground_service IS NOT NULL AND value_for_money IS NOT NULL GROUP BY seat_group

  UNION ALL SELECT seat_group,'inflight_entertainment','seat_comfort',
    (AVG(inflight_entertainment*seat_comfort)-AVG(inflight_entertainment)*AVG(seat_comfort))
    / NULLIF(STDDEV_SAMP(inflight_entertainment)*STDDEV_SAMP(seat_comfort),0)
    FROM base WHERE inflight_entertainment IS NOT NULL AND seat_comfort IS NOT NULL GROUP BY seat_group
  UNION ALL SELECT seat_group,'inflight_entertainment','wifi_and_connectivity',
    (AVG(inflight_entertainment*wifi_and_connectivity)-AVG(inflight_entertainment)*AVG(wifi_and_connectivity))
    / NULLIF(STDDEV_SAMP(inflight_entertainment)*STDDEV_SAMP(wifi_and_connectivity),0)
    FROM base WHERE inflight_entertainment IS NOT NULL AND wifi_and_connectivity IS NOT NULL GROUP BY seat_group
  UNION ALL SELECT seat_group,'inflight_entertainment','value_for_money',
    (AVG(inflight_entertainment*value_for_money)-AVG(inflight_entertainment)*AVG(value_for_money))
    / NULLIF(STDDEV_SAMP(inflight_entertainment)*STDDEV_SAMP(value_for_money),0)
    FROM base WHERE inflight_entertainment IS NOT NULL AND value_for_money IS NOT NULL GROUP BY seat_group

  UNION ALL SELECT seat_group,'seat_comfort','wifi_and_connectivity',
    (AVG(seat_comfort*wifi_and_connectivity)-AVG(seat_comfort)*AVG(wifi_and_connectivity))
    / NULLIF(STDDEV_SAMP(seat_comfort)*STDDEV_SAMP(wifi_and_connectivity),0)
    FROM base WHERE seat_comfort IS NOT NULL AND wifi_and_connectivity IS NOT NULL GROUP BY seat_group
  UNION ALL SELECT seat_group,'seat_comfort','value_for_money',
    (AVG(seat_comfort*value_for_money)-AVG(seat_comfort)*AVG(value_for_money))
    / NULLIF(STDDEV_SAMP(seat_comfort)*STDDEV_SAMP(value_for_money),0)
    FROM base WHERE seat_comfort IS NOT NULL AND value_for_money IS NOT NULL GROUP BY seat_group

  UNION ALL SELECT seat_group,'wifi_and_connectivity','value_for_money',
    (AVG(wifi_and_connectivity*value_for_money)-AVG(wifi_and_connectivity)*AVG(value_for_money))
    / NULLIF(STDDEV_SAMP(wifi_and_connectivity)*STDDEV_SAMP(value_for_money),0)
    FROM base WHERE wifi_and_connectivity IS NOT NULL AND value_for_money IS NOT NULL GROUP BY seat_group
),
corr_full AS (
  SELECT seat_group, metric_x, metric_y, correlation FROM corr_upper
  UNION ALL
  SELECT seat_group, metric_y AS metric_x, metric_x AS metric_y, correlation
  FROM corr_upper
  WHERE metric_x <> metric_y
)
SELECT seat_group, metric_x, metric_y, correlation
FROM corr_full
ORDER BY seat_group, metric_x, metric_y;
