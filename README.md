# American Airlines Reviews — Tableau Dashboard

This project explores passenger feedback for American Airlines, highlighting what travelers value most and where the experience can improve. It includes service-rating analysis, customer segments (traveler type, nationality), and a Pearson correlation heatmap across service dimensions.

## How to open
- Download `twbx/AA_Analysis.twbx`
- Open with Tableau Desktop

## Key Views
- **Overview:** Number of Reviews, Average Rating, % Recommended, trend by year
- **Customer Analysis:** Traveller Type Distribution, Nationality breakdown
- **Service Quality:** Staff, Food, Seat Comfort, Entertainment, Wi-Fi, Ground, Value
- **Correlation Heatmap:** How service ratings relate to each other

## Data Notes
- Ratings use a 1–5 scale (5 = best); nulls excluded pairwise in correlations
- Airline fixed to “American Airlines”
- Traveller types include Business, Solo Leisure, Couple Leisure, Family Leisure

## SQL
- `sql/AA.sql` contains metrics finding and Pearson correlation queries (MySQL-compatible).

## License
MIT