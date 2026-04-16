# DVD Rental Data Analysis (SQL Project)

## Project Overview

This project analyzes the DVD Rental Database, a generated database for a fictitious DVD rental chain, using SQL to explore customer behavior, inventory efficiency, and revenue performance. The database can be downloaded using this [link](https://neon.com/postgresql/postgresql-getting-started/postgresql-sample-database). It simulates a real-world business scenario by identifying inefficiencies and finding insights to improve operational and financial performance. This project is ongoing as I plan to improve and add on it. 

## Business Objectives
- Understand customer purchasing behaviour
- Identify inventory inefficiencies
- Analyze revenue drivers across films, categories, and actors
- Evaluate demand across stores

## Analysis Breakdown
- Customer Analysis
  - Find the first and most recent purchase
  - Calculate total spending
  - Identify preferred movie ratings and content diversity
- Inventory Analysis
  - Identify films not available in store
  - Identify unused items
  - Evaluate supply vs demand
- Performance Analysis
  - Identify popular and top grossing film categories
  - Analyze top performing actors based on revenue
  - Measure audience reach
  - Evaluate revenue distribution per film and per actor

## Key Insights
- Inventory Inefficiencies
  - Several films are not stocked in any store, limiting potential revenue
  - Some films are high in demand but only stocked in one store
- Supply Imbalance
  - Some films show high rent_per_copy, suggesting that they might be understocked
  - Some films show low rent_per_copy, suggesting that they might be overstocked
- Content Performance
  - Actors with more films do not always generate higher revenue
  - Revenue contribution is concentrated rather than evenly distributed across large casts

## Business Applications
- Reallocate inventories towards high-demand but understocked films
- Reduce low performing inventory items
- Ensure popular films are available across all stores
- Focus on high performing categories and actors 






