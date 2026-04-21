# DVD Rental Data Analysis (SQL Project)

## Project Overview

This project analyzes the DVD Rental Database, a generated database for a fictitious DVD rental chain, using SQL to explore customer behavior, inventory efficiency, and revenue performance. The database can be downloaded using this [link](https://neon.com/postgresql/postgresql-getting-started/postgresql-sample-database). 

The analysis simulates a real-world business scenario by identifying operational inefficiencies and uncovering actionable insights to improve financial performance. This project is ongoing, I plan to expand it with Excel and Tableau dashboards in the future.

## Business Objectives
- Understand customer purchasing behavior and lifetime value
- Identify inventory inefficiencies 
- Analyze revenue drivers across films, categories, and actors
- Evaluate demand distribution across stores
- Measure audience reach and content penetration

## File Description
- [customer_analysis.sql](scripts/customer_analysis.sql): Customer segmentation, lifetime value metrics, rental frequency, and preferred content analysis.
- [inventory_analysis.sql](scripts/inventory_analysis.sql): Stock evaluation, store-level comparisons, and `rent_per_copy` efficiency metrics.
- [performance_analysis.sql](scripts/performance_analysis.sql): Revenue attribution across categories, films, ratings, and actors. Includes audience reach metrics.

## Analysis Breakdown

### Customer Analysis
- Calculate first and most recent purchase dates per customer
- Compute total lifetime spending and rental frequency
- Identify preferred movie ratings and category diversity per customer

### Inventory Analysis
- Identify films not stocked in any store (lost revenue opportunity)
- Identify inventory items with zero rentals
- Calculate `rent_per_copy` to evaluate supply vs demand efficiency
- Compare inventory composition and performance between Store 1 and Store 2

### Performance Analysis
- Identify top-grossing and most-rented film categories
- Identify top-grossing and most-rented actors
- Measure actor audience reach
- Attribute film revenue to individual actors

## Key Insights

### Inventory Inefficiencies
- Several catalog films are not stocked in any store, representing revenue opportunities if ordered.
- Some high-demand films are stocked in only one store location, representing potential revenue loss.

### Supply Imbalance
- Films with high `rent_per_copy` are likely understocked, additional copies could generate more revenue. 
- Films with low `rent_per_copy` are likely overstocked or unpopular, inventory could be reduced or promotional discounting.
  
### Content Performance
- Actors appearing in many ensemble films often generate less attributed revenue than those in films with fewer high-performing actors. 
- Some actors have broad audience appeal (high reach) but low revenue per appearance. Others have niche, dedicated fan bases (low reach, high revenue). This can inform more precise marketing and acquisition strategy.

## Business Applications
- Reallocate inventory toward high-demand but understocked films.
- Reduce or eliminate consistently low-performing inventory items.
- Ensure popular films are available across all store locations to maximize accessibility.
- Focus acquisition budgets on top-performing categories and hight-performing actors (high revenue + high reach).
- Implement targeted promotions for niche actors with a dedicated fanbase (high revenue + low reach) to expand their audience.






