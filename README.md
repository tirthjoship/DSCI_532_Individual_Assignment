# Salescope — Individual Assignment (Shiny for R)

Re-implementation of our group project [Salescope](https://github.com/UBC-MDS/DSCI-532_2026_10_Salescope) in Shiny for R (the group project is in Shiny for Python). Uses the [Sales and Customer Insights](https://www.kaggle.com/datasets/imranalishahh/sales-and-customer-insights) dataset from Kaggle.

The app lets you filter customers by region, purchase category, and churn probability range. Three value boxes update to show the average lifetime value, average churn rate, and number of customers matching your filters. Below that there's a scatter plot of lifetime value vs. days between purchases (coloured by retention strategy) and a scrollable table of the filtered rows.

**Deployed app:** https://019cd653-e8a3-560d-97eb-75821de1ea7c.share.connect.posit.cloud/

---

## Run it locally

Clone the repo, then install the R packages:

```r
Rscript install.R
```

Or just run this directly from the R console:

```r
install.packages(c("shiny", "bslib", "dplyr", "plotly", "readr"))
```

The data file (`data/raw/sales_and_customer_insights.csv`) is already in the repo. To start the app:

```r
shiny::runApp("app.R")
```

---

## Deploying to Posit Connect Cloud

1. Sign in at [connect.posit.cloud](https://connect.posit.cloud) and create a new content item.
2. Connect to GitHub and point it at this repo (or upload the folder directly).
3. Make sure `app.R` and the `data/` folder are in the root.
4. Hit **Deploy**. Once it's live, copy the URL.
5. Paste that URL in the **Deployed app** line above.
6. Add the same URL in the repo's **About** section (Settings → About → Website).
7. Make sure the repo is set to **Public**.
8. Submit the repo link on Gradescope.
