############################################################
# Project: NYC Airbnb 2019 – Data Cleaning, EDA & Statistics
# Author:  Kumar Karthik Ankasandra Naveen
# Course:  ALY 6010 - Probability Theory and Intro Statistics
# Date:    2023-12-13
#
# Description:
#   This script performs:
#     1) Data loading and cleaning
#     2) Exploratory Data Analysis (EDA)
#     3) Statistical hypothesis testing:
#          - Manhattan vs Brooklyn prices
#          - Entire home/apt vs Private room prices
#          - Price vs benchmark
#          - Reviews vs availability
#          - Reviews vs price (regression)
#          - Availability vs price (regression)
#          - ANOVA: price by room type
#
#   The dataset used is the 2019 NYC Airbnb open data from Kaggle.
############################################################


############################################################
# 0. (Optional) Environment Setup
############################################################

# NOTE:
# The following commands are optional and mainly used in RStudio
# to start with a clean environment. You can comment them out
# if you don't want this behavior.

cat("\014")                      # Clear console
rm(list = ls())                  # Clear global environment

# If there are open plot devices, close them (RStudio-safe)
try(dev.off(dev.list()["RStudioGD"]), silent = TRUE)

# If you use pacman and want to unload packages, uncomment:
# try(p_unload(p_loaded(), character.only = TRUE), silent = TRUE)

# Avoid scientific notation in printed output
options(scipen = 100)


############################################################
# 1. Load Required Libraries
############################################################

# Install these packages first if needed:
# install.packages("janitor")
# install.packages("tidyverse")

library(janitor)     # For clean_names and data cleaning helpers
library(tidyverse)   # For piping (%>%), dplyr verbs, etc.


############################################################
# 2. Load Dataset
############################################################

# Path to the CSV file – adjust if needed
data_path <- "AB_NYC_2019.csv"

# Read the raw Airbnb dataset
airbnb_raw <- read.csv(data_path, stringsAsFactors = FALSE)

# Quick structure check of raw data (optional)
str(airbnb_raw)


############################################################
# 3. Data Cleaning
############################################################
# Goal:
#   - Standardize column names
#   - Remove rows with missing values
#   - Remove invalid or extreme values
#   - Convert to appropriate data types
############################################################

airbnb_clean <- airbnb_raw %>%
  # 3.1 Standardize column names to snake_case
  clean_names() %>%
  
  # 3.2 Remove rows with any missing values
  na.omit() %>%
  
  # 3.3 Filter out clearly invalid rows
  #      - price = 0 (non-sensical for a listing)
  #      - availability_365 = 0 (never available)
  #      - minimum_nights > 365 (likely unrealistic)
  filter(
    price > 0,
    availability_365 > 0,
    minimum_nights <= 365
  )

# 3.4 Remove outliers in price using ± 2 standard deviations
mean_price <- mean(airbnb_clean$price)
sd_price   <- sd(airbnb_clean$price)
price_threshold <- 2 * sd_price

airbnb_clean <- airbnb_clean %>%
  filter(abs(price - mean_price) <= price_threshold)

# 3.5 Convert types:
#     - last_review: character -> Date
#     - room_type:   character -> factor
#     - neighbourhood_group: character -> factor
airbnb_clean <- airbnb_clean %>%
  mutate(
    last_review = as.Date(last_review),
    room_type   = as.factor(room_type),
    neighbourhood_group = as.factor(neighbourhood_group)
  )

# Summary of cleaned dataset
cat("Number of rows AFTER cleaning: ", nrow(airbnb_clean), "\n")
summary(airbnb_clean)


############################################################
# 4. Exploratory Data Analysis (EDA)
############################################################
# Goal:
#   - Understand distributions of key variables
#   - Visualize neighborhood and room type patterns
#   - Explore price distribution and spatial distribution
############################################################


########## 4.1 Descriptive Statistics ##########

# Descriptive stats for key numeric variables
summary(airbnb_clean$minimum_nights)
summary(airbnb_clean$price)


########## 4.2 Categorical Distributions ##########

# Bar plot: Neighbourhood group distribution
barplot(
  table(airbnb_clean$neighbourhood_group),
  main = "Neighbourhood Group Distribution",
  col = "skyblue",
  border = "black",
  xlab = "Neighbourhood Group",
  ylab = "Count",
  cex.names = 0.8
)

# Bar plot: Room type distribution
barplot(
  table(airbnb_clean$room_type),
  main = "Room Type Distribution",
  col = "salmon",
  border = "black",
  xlab = "Room Type",
  ylab = "Count",
  cex.names = 0.8
)


########## 4.3 Price & Minimum Nights Distributions ##########

# Histogram: Minimum nights
hist(
  airbnb_clean$minimum_nights,
  main = "Histogram of Minimum Nights",
  xlab = "Minimum Nights",
  col = "lightgreen",
  border = "black"
)

# Histogram: Price
hist(
  airbnb_clean$price,
  main = "Histogram of Price",
  xlab = "Price (USD)",
  col = "skyblue",
  border = "black"
)

# Boxplot: Price
boxplot(
  airbnb_clean$price,
  main = "Boxplot of Price",
  ylab = "Price (USD)",
  col = "skyblue",
  border = "black"
)


########## 4.4 Spatial Distribution ##########

# Scatter plot: Longitude vs Latitude (all listings)
plot(
  airbnb_clean$longitude,
  airbnb_clean$latitude,
  main = "Listing Locations in NYC",
  xlab = "Longitude",
  ylab = "Latitude",
  col  = "skyblue",
  pch  = 20
)


############################################################
# 5. Room-Type Subset Analysis (EDA by Room Type)
############################################################
# Goal:
#   - Compare price distributions and locations
#     for each room type:
#       - Entire home/apt
#       - Private room
#       - Shared room
############################################################

# Subset data by room type
entire_home  <- subset(airbnb_clean, room_type == "Entire home/apt")
private_room <- subset(airbnb_clean, room_type == "Private room")
shared_room  <- subset(airbnb_clean, room_type == "Shared room")

# Helper function to plot histogram & boxplot of price
plot_price_distribution <- function(data, title_prefix, col_hist, col_box) {
  hist(
    data$price,
    main = paste("Histogram of Price -", title_prefix),
    xlab = "Price (USD)",
    col = col_hist,
    border = "black"
  )
  
  boxplot(
    data$price,
    main = paste("Boxplot of Price -", title_prefix),
    ylab = "Price (USD)",
    col = col_box,
    border = "black"
  )
}

########## 5.1 Entire Home/Apt ##########
plot_price_distribution(entire_home, "Entire Home/Apt", "salmon", "salmon")

plot(
  entire_home$longitude,
  entire_home$latitude,
  main = "Locations - Entire Home/Apt",
  xlab = "Longitude",
  ylab = "Latitude",
  col  = "salmon",
  pch  = 20
)

########## 5.2 Private Room ##########
plot_price_distribution(private_room, "Private Room", "lightgreen", "lightgreen")

plot(
  private_room$longitude,
  private_room$latitude,
  main = "Locations - Private Room",
  xlab = "Longitude",
  ylab = "Latitude",
  col  = "green",
  pch  = 20
)

########## 5.3 Shared Room ##########
plot_price_distribution(shared_room, "Shared Room", "orange", "orange")

plot(
  shared_room$longitude,
  shared_room$latitude,
  main = "Locations - Shared Room",
  xlab = "Longitude",
  ylab = "Latitude",
  col  = "orange",
  pch  = 20
)


############################################################
# 6. Statistical Analysis & Hypothesis Testing
############################################################
# Each question below corresponds to a specific
# statistical task with:
#   - Hypotheses
#   - Method (test type)
#   - R implementation
############################################################


############################################################
# Question 1:
#   Is there a significant difference in average price
#   between Manhattan and Brooklyn?
#
# H0: mean_price_Manhattan = mean_price_Brooklyn
# H1: mean_price_Manhattan != mean_price_Brooklyn
#
# Test: Two-sample Welch t-test
############################################################

manhattan_prices <- airbnb_clean %>%
  filter(neighbourhood_group == "Manhattan") %>%
  pull(price)

brooklyn_prices <- airbnb_clean %>%
  filter(neighbourhood_group == "Brooklyn") %>%
  pull(price)

# Boxplot for visual comparison
boxplot(
  list(Manhattan = manhattan_prices, Brooklyn = brooklyn_prices),
  main = "Price Distribution: Manhattan vs Brooklyn",
  xlab = "Neighbourhood Group",
  ylab = "Price (USD)"
)

# Welch two-sample t-test
t_test_manhattan_brooklyn <- t.test(manhattan_prices, brooklyn_prices)

# Print results
cat("\n--- Question 1: Manhattan vs Brooklyn Prices ---\n")
print(t_test_manhattan_brooklyn)


############################################################
# Question 2:
#   Is there a difference in the average price between
#   entire home/apt and private room listings?
#
# H0: mean_price_entire = mean_price_private
# H1: mean_price_entire != mean_price_private
#
# Test: Two-sample Welch t-test
############################################################

entire_home_prices <- entire_home$price
private_room_prices <- private_room$price

# Boxplot comparison
boxplot(
  list("Entire Home/Apt" = entire_home_prices,
       "Private Room"    = private_room_prices),
  main = "Price Distribution: Entire Home/Apt vs Private Room",
  xlab = "Room Type",
  ylab = "Price (USD)"
)

# Welch two-sample t-test
t_test_entire_vs_private <- t.test(entire_home_prices, private_room_prices)

cat("\n--- Question 2: Entire Home/Apt vs Private Room Prices ---\n")
print(t_test_entire_vs_private)


############################################################
# Question 3:
#   Is there a correlation between the number of reviews
#   and listing availability (availability_365)?
#
# H0: Correlation = 0
# H1: Correlation != 0
#
# Test: Pearson correlation
############################################################

# Compute Pearson correlation
cor_reviews_availability <- cor(
  airbnb_clean$number_of_reviews,
  airbnb_clean$availability_365
)

# Scatter plot
plot(
  airbnb_clean$number_of_reviews,
  airbnb_clean$availability_365,
  main = "Number of Reviews vs Availability (365 days)",
  xlab = "Number of Reviews",
  ylab = "Availability (days)"
)

cat("\n--- Question 3: Reviews vs Availability ---\n")
cat("Correlation coefficient:", cor_reviews_availability, "\n")


############################################################
# Question 4:
#   Is the average price significantly different from
#   a specified benchmark price (e.g., $150)?
#
# H0: mean_price = benchmark_price
# H1: mean_price != benchmark_price
#
# Test: One-sample t-test
############################################################

benchmark_price <- 150  # You can change this benchmark value

# Histogram with benchmark line
hist(
  airbnb_clean$price,
  main = "Distribution of Airbnb Prices (with Benchmark)",
  xlab = "Price (USD)",
  col  = "lightblue",
  border = "black"
)
abline(v = benchmark_price, col = "red", lwd = 2)

# One-sample t-test
t_test_vs_benchmark <- t.test(airbnb_clean$price, mu = benchmark_price)

cat("\n--- Question 4: Price vs Benchmark (", benchmark_price, ") ---\n", sep = "")
print(t_test_vs_benchmark)


############################################################
# Question 5:
#   Is there a relationship between the number of reviews
#   and the price of a listing?
#
# H0: No linear relationship (slope = 0)
# H1: There is a linear relationship (slope != 0)
#
# Methods:
#   - Pearson correlation
#   - Simple linear regression: price ~ number_of_reviews
############################################################

# Scatter plot: reviews vs price
plot(
  airbnb_clean$number_of_reviews,
  airbnb_clean$price,
  main = "Number of Reviews vs Price",
  xlab = "Number of Reviews",
  ylab = "Price (USD)"
)

# Pearson correlation
cor_reviews_price <- cor(
  airbnb_clean$number_of_reviews,
  airbnb_clean$price
)

cat("\n--- Question 5: Reviews vs Price ---\n")
cat("Correlation coefficient:", cor_reviews_price, "\n")

# Linear regression model
lm_reviews_price <- lm(price ~ number_of_reviews, data = airbnb_clean)
summary(lm_reviews_price)


############################################################
# Question 6:
#   Does listing availability (availability_365) influence price?
#
# H0: No linear relationship (slope = 0)
# H1: There is a linear relationship (slope != 0)
#
# Methods:
#   - Pearson correlation
#   - Simple linear regression: price ~ availability_365
############################################################

# Scatter plot: availability vs price
plot(
  airbnb_clean$availability_365,
  airbnb_clean$price,
  main = "Availability (365 days) vs Price",
  xlab = "Availability (days per year)",
  ylab = "Price (USD)"
)

# Pearson correlation
cor_availability_price <- cor(
  airbnb_clean$availability_365,
  airbnb_clean$price
)

cat("\n--- Question 6: Availability vs Price ---\n")
cat("Correlation coefficient:", cor_availability_price, "\n")

# Linear regression model
lm_availability_price <- lm(price ~ availability_365, data = airbnb_clean)
summary(lm_availability_price)


############################################################
# Question 7:
#   How does room type (Entire home/apt, Private room, Shared room)
#   affect price?
#
# H0: All room types have the same mean price
# H1: At least one room type has a different mean price
#
# Test: One-way ANOVA
############################################################

# Boxplot: price by room type
boxplot(
  price ~ room_type,
  data = airbnb_clean,
  main = "Price by Room Type",
  xlab = "Room Type",
  ylab = "Price (USD)"
)

# ANOVA model
anova_room_type <- aov(price ~ room_type, data = airbnb_clean)

cat("\n--- Question 7: ANOVA - Price by Room Type ---\n")
summary(anova_room_type)

############################################################
# SAVE ALL PLOTS TO /images FOLDER
############################################################

# Create images folder if it doesn't exist
if(!dir.exists("images")) {
  dir.create("images")
}

# Helper function to save plots
save_plot <- function(filename, plot_code, width=7, height=5) {
  png(file.path("images", filename), width=width, height=height, units="in", res=120)
  plot_code
  dev.off()
}

############################################################
# 1. Neighborhood Group Distribution
############################################################
save_plot("neighbourhood_distribution.png", {
  barplot(table(airbnb_clean$neighbourhood_group),
          main = "Neighbourhood Group Distribution",
          col = "skyblue", border = "black",
          xlab = "Neighbourhood Group", ylab = "Count")
})

############################################################
# 2. Room Type Distribution
############################################################
save_plot("room_type_distribution.png", {
  barplot(table(airbnb_clean$room_type),
          main = "Room Type Distribution",
          col = "salmon", border = "black",
          xlab = "Room Type", ylab = "Count")
})

############################################################
# 3. Price Histogram
############################################################
save_plot("price_histogram.png", {
  hist(airbnb_clean$price,
       main = "Histogram of Price",
       xlab = "Price", col = "skyblue", border = "black")
})

############################################################
# 4. Price Boxplot
############################################################
save_plot("price_boxplot.png", {
  boxplot(airbnb_clean$price,
          main = "Boxplot of Price",
          ylab = "Price", col = "skyblue", border = "black")
})

############################################################
# 5. Location Scatterplot
############################################################
save_plot("location_scatter.png", {
  plot(airbnb_clean$longitude, airbnb_clean$latitude,
       main = "Listing Locations in NYC",
       xlab = "Longitude", ylab = "Latitude",
       col = "skyblue", pch = 20)
})

############################################################
# 6. Entire Home / Apt Price Histogram
############################################################
save_plot("entire_home_hist.png", {
  hist(entire_home$price, main = "Price: Entire Home/Apt",
       xlab = "Price", col = "salmon", border = "black")
})

############################################################
# 7. Private Room Boxplot
############################################################
save_plot("private_room_box.png", {
  boxplot(private_room$price, main = "Price: Private Room",
          ylab = "Price", col = "lightgreen", border = "black")
})

############################################################
# 8. Shared Room Location Scatter
############################################################
save_plot("shared_room_scatter.png", {
  plot(shared_room$longitude, shared_room$latitude,
       main = "Shared Room Locations",
       xlab = "Longitude", ylab = "Latitude",
       col = "orange", pch = 20)
})

############################################################
# 9. Manhattan vs Brooklyn Price Boxplot
############################################################
save_plot("manhattan_brooklyn_box.png", {
  boxplot(list(Manhattan = manhattan_prices, Brooklyn = brooklyn_prices),
          main = "Manhattan vs Brooklyn Prices",
          xlab = "Neighbourhood Group", ylab = "Price")
})

############################################################
# 10. Entire Home vs Private Room Boxplot
############################################################
save_plot("entire_vs_private_box.png", {
  boxplot(list("Entire Home/Apt" = entire_home_prices,
               "Private Room" = private_room_prices),
          main = "Entire Home/Apt vs Private Room Prices",
          xlab = "Room Type", ylab = "Price")
})

############################################################
# 11. Reviews vs Availability Scatter
############################################################
save_plot("reviews_availability_scatter.png", {
  plot(airbnb_clean$number_of_reviews, airbnb_clean$availability_365,
       main = "Reviews vs Availability", xlab = "Reviews",
       ylab = "Availability (365 days)")
})

############################################################
# 12. Benchmark Price Histogram
############################################################
save_plot("benchmark_hist.png", {
  hist(airbnb_clean$price,
       main = "Price Distribution (with Benchmark)",
       xlab = "Price", col = "lightblue", border = "black")
  abline(v = benchmark_price, col = "red", lwd = 2)
})

############################################################
# 13. Reviews vs Price Scatter
############################################################
save_plot("reviews_price_scatter.png", {
  plot(airbnb_clean$number_of_reviews, airbnb_clean$price,
       main = "Reviews vs Price",
       xlab = "Number of Reviews", ylab = "Price")
})

############################################################
# 14. Availability vs Price Scatter
############################################################
save_plot("availability_price_scatter.png", {
  plot(airbnb_clean$availability_365, airbnb_clean$price,
       main = "Availability vs Price",
       xlab = "Availability", ylab = "Price")
})

############################################################
# 15. Room Type ANOVA Boxplot
############################################################
save_plot("room_type_anova.png", {
  boxplot(price ~ room_type, data = airbnb_clean,
          main = "Price by Room Type",
          xlab = "Room Type", ylab = "Price")
})

############################################################
cat("All plots saved to the /images folder successfully! 🎉\n")
############################################################


############################################################
# End of Script
############################################################
