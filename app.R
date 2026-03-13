if (dir.exists(".Rlib")) {
  .libPaths(c(".Rlib", .libPaths()))
}

library(shiny)
library(bslib)
library(dplyr)
library(plotly)
library(readr)
library(DT)

# Load data
sales_df <- read_csv("data/raw/sales_and_customer_insights.csv", show_col_types = FALSE)

regions <- sort(unique(sales_df$Region))
categories <- sort(unique(sales_df$Most_Frequent_Category))

# UI
ui <- page_fillable(
  title = "Salescope — Customer Retention & Churn Insights (R)",
  theme = bs_theme(
    bootswatch = "lumen",
    primary = "#0d6efd",
    success = "#198754",
    danger = "#dc3545",
    info = "#0dcaf0"
  ),
  layout_sidebar(
    sidebar = sidebar(
      title = "Filters",
      tags$em("Focus the dashboard by region, purchase category, and churn risk."),
      selectInput(
        inputId  = "region",
        label    = "Region",
        choices  = c("All", regions),
        selected = "All"
      ),
      checkboxGroupInput(
        inputId  = "category",
        label    = "Most Frequent Category",
        choices  = categories,
        selected = categories
      ),
      sliderInput(
        inputId = "churn_range",
        label   = "Churn Probability Range",
        min     = 0,
        max     = 1,
        value   = c(0, 1),
        step    = 0.01
      ),
      actionButton("reset", "Reset Filters"),
      open = "desktop"
    ),
    layout_columns(
      tags$div(
        style = "margin: 0; padding: 0.25rem 0 0.5rem 0;",
        tags$h3(style = "margin: 0;", "Salescope — Customer Retention Overview"),
        tags$p(
          style = "margin: 0.1rem 0 0 0;",
          tags$small(tags$em("Review customer value and churn risk for the selected filters."))
        )
      )
    ),
    layout_columns(
      value_box(
        title = "Average Lifetime Value",
        value = textOutput("kpi_ltv"),
        theme = "success",
        p(tags$em("Average expected revenue from customers in the current view."))
      ),
      value_box(
        title = "Average Churn Probability",
        value = textOutput("kpi_churn"),
        theme = "danger",
        p(tags$em("Average likelihood that these customers will stop buying."))
      ),
      value_box(
        title = "Customers in View",
        value = textOutput("kpi_count"),
        theme = "info",
        p(tags$em("Number of customers matching the filters."))
      ),
      fill = FALSE
    ),
    layout_columns(
      card(
        card_header("Lifetime Value vs Days Between Purchases"),
        plotlyOutput("scatter_ltv_days", height = "400px"),
        full_screen = TRUE
      ),
      card(
        card_header("Filtered Customer Data"),
        DT::DTOutput("table_preview"),
        full_screen = TRUE
      ),
      col_widths = c(6, 6)
    )
  )
)

# Server
server <- function(input, output, session) {
  filtered_df <- reactive({
    df <- sales_df
    if (input$region != "All") {
      df <- df %>% filter(Region == input$region)
    }
    if (length(input$category) > 0) {
      df <- df %>% filter(Most_Frequent_Category %in% input$category)
    }
    df <- df %>%
      filter(
        Churn_Probability >= input$churn_range[1],
        Churn_Probability <= input$churn_range[2]
      )
    df
  })

  observeEvent(input$reset, {
    updateSelectInput(session, "region", selected = "All")
    updateCheckboxGroupInput(session, "category", selected = categories)
    updateSliderInput(session, "churn_range", value = c(0, 1))
  })

  output$kpi_ltv <- renderText({
    df <- filtered_df()
    if (nrow(df) == 0) {
      return("—")
    }
    paste0("$", formatC(mean(df$Lifetime_Value), format = "f", digits = 2, big.mark = ","))
  })

  output$kpi_churn <- renderText({
    df <- filtered_df()
    if (nrow(df) == 0) {
      return("—")
    }
    sprintf("%.1f%%", mean(df$Churn_Probability) * 100)
  })

  output$kpi_count <- renderText({
    n <- nrow(filtered_df())
    if (n < 50) {
      paste0(format(n, big.mark = ","), " (low sample)")
    } else {
      format(n, big.mark = ",")
    }
  })

  output$scatter_ltv_days <- renderPlotly({
    df <- filtered_df()
    if (nrow(df) == 0) {
      return(plot_ly() %>% layout(title = "No data for current filters"))
    }
    plot_ly(
      data = df,
      x = ~Lifetime_Value,
      y = ~Time_Between_Purchases,
      type = "scatter",
      mode = "markers",
      color = ~Retention_Strategy,
      hoverinfo = "text",
      text = paste(
        "LTV:", round(df$Lifetime_Value, 2),
        "<br>Days:", df$Time_Between_Purchases,
        "<br>Churn:", round(df$Churn_Probability, 2),
        "<br>Region:", df$Region
      )
    ) %>%
      layout(
        xaxis  = list(title = "Customer Lifetime Value ($)"),
        yaxis  = list(title = "Days Between Purchases"),
        legend = list(title = list(text = "Retention Strategy"))
      )
  })

  output$table_preview <- DT::renderDT(
    {
      filtered_df() %>%
        select(
          Customer_ID, Region, Most_Frequent_Category,
          Lifetime_Value, Churn_Probability, Retention_Strategy
        ) %>%
        head(100)
    },
    options = list(pageLength = 10),
    rownames = FALSE
  )
}

# Create app
shinyApp(ui = ui, server = server)
