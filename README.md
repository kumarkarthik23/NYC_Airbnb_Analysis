# NYC Airbnb 2019 Data Analysis
**Author:** Kumar Karthik Ankasandra Naveen  
**Language:** R  
**Project Type:** Data Cleaning, EDA, Statistical Analysis  

---

## Overview
This project analyzes the NYC Airbnb 2019 dataset.  
It includes:

- Data cleaning  
- Exploratory data analysis  
- Visualizations  
- Statistical tests (t-tests, correlation, regression, ANOVA)

The goal is to understand how listing price varies by neighborhood, room type, reviews, and availability.

---

## What This Project Does
- Cleans and prepares raw Airbnb data  
- Explores distributions and pricing patterns  
- Compares boroughs (Manhattan vs Brooklyn)  
- Compares room types  
- Evaluates relationships between reviews, availability, and price  
- Tests if the average price differs from a benchmark value  
- Uses regression and ANOVA for deeper insights  

---

## Main Files
```
nyc_airbnb_analysis.R   # Final analysis script
AB_NYC_2019.csv         # Dataset 
images/                 # Folder for plot images
```

---

## Example Visuals (Optional)
Add these images to an `/images` folder if you want:

- Neighborhood distribution  
- Room type distribution  
- Price histogram  
- Price by room type boxplot  
- Manhattan vs Brooklyn comparison  

```
![Price Histogram](images/price_histogram.png)
```

(If you don’t add images, GitHub will simply ignore the links.)

---

## Key Findings (Short Version)
- Manhattan listings are significantly more expensive than Brooklyn  
- Entire homes/apts cost more than private or shared rooms  
- Average NYC Airbnb price ≈ **$133**, not $150  
- Reviews and availability have **very weak** correlation with price  
- Room type strongly affects price (confirmed by ANOVA)

---

## How to Run
1. Download the R script  
2. Place the dataset (`AB_NYC_2019.csv`) in the same folder  
3. Run in R or RStudio:  
```r
source("nyc_airbnb_analysis.R")
```

---

## License
This project is for educational and portfolio purposes.
