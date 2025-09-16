# American Airlines Reviews — Tableau Dashboard

Explore passenger feedback for American Airlines with a Tableau dashboard.
👉 [View Live Dashboard](https://quanh171.github.io/american-airlines-reviews-dashboard/)

This project explores passenger feedback for American Airlines, highlighting what travelers value most and where the experience can improve. It includes service-rating analysis, customer segments (traveler type, nationality), and a Pearson correlation heatmap across service dimensions.

## How to open
- Download `twbx/AA_Analysis.twbx`
- Open with Tableau Desktop (or Tableau Reader)

## Contents
- `dashboard/` → dashboard in PNG format
- `db/` → datasets used for this project
- `docs/` → HTML embed for GitHub Pages
- `sql/` → SQL for metrics finding and correlation matrix
- `twbx/` → Tableau packaged workbook (.twbx)

## Key Views
- **Overview:** Number of Reviews, Average Rating, % Recommended, trend by year
- **Customer Analysis:** Traveller Type Distribution, Nationality breakdown
- **Service Quality:** Staff, Food, Seat Comfort, Entertainment, Wi-Fi, Ground, Value
- **Correlation Heatmap:** How service ratings relate to each other

## Data Notes
- Ratings use a 1–5 scale (5 = best); nulls excluded pairwise in correlations
- Airline fixed to “American Airlines”
- Traveller types include Business, Solo Leisure, Couple Leisure, Family Leisure

## License
MIT