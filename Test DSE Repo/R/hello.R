#' @export
hello_g <- function() {
  print("Hello, world! This is Greg")
}

#' @export
runIR <- function() {

dependencies <- c("shiny", "shinydashboard", "RCurl", "tidyverse", "plotly", "shinycssloaders",
                  "aTSA", "vars", "broom", "urca", "shinyanimate")
  
for (x in dependencies) {
  if(x %in% rownames(installed.packages()) == T) {
    library(x, character.only = T)
  } else {
    install.packages(x)
    library(x, character.only = T)
    Sys.sleep(5)
  }
}


# test --------------------------------------------------------------------

withConsoleRedirect <- function(containerId, expr) {
  # Change type="output" to type="message" to catch stderr
  # (messages, warnings, and errors) instead of stdout.
  txt <- capture.output(results <- expr, type = "output")
  if (length(txt) > 0) {
    insertUI(paste0("#", containerId), where = "beforeEnd",
             ui = paste0(txt, "\n", collapse = "")
    )
  }
  results
}

# read data ---------------------------------------------------------------
  d <- getURL("https://raw.githubusercontent.com/unimi-dse/8a65fae3/master/data/term_structure.csv")
  data <- read_csv(d)
  
  data_gathered <- data[,c("date", "m2", "y2")] %>%
    gather(key="type", value="value", -date) %>%
    mutate(type = as.factor(type))

  spreads <- data %>% 
    mutate(spreads = y2-m2)

# cointegration test ------------------------------------------------------
  
  # linear regression model
  mod <- lm(y2 ~ m2, data = data)
  dflm <- augment(mod) %>%
    mutate(date=data$date)
  
  adfred <- adf.test(dflm$.resid, nlag = 3)

# analysis ----------------------------------------------------------------

  mysample <- data[, c("m2", "y2")]
  # VARselect(mysample, lag.max = 10, type = "const")
  cointtest <- ca.jo(mysample, K=2, spec = "transitory", type="eigen")
  # cajorls(cointtest)
  
# source ui ---------------------------------------------------------------
  script <- getURL ("https://raw.githubusercontent.com/unimi-dse/8a65fae3/master/modules/ui.R",
                    ssl.verifypeer = FALSE)
  eval(parse(text = script))

# server side -------------------------------------------------------------
server <- function(input, output, session) {
  
  
  output$menu <- renderMenu({
    
  sidebarMenu(id="tabs",
              menuItem("Home", tabName = "tab_1", icon=icon("home")),
              menuItem("Inspection", tabName = "tab_2", icon=icon("search")),
              menuItem("Analysis", tabName = "tab_3", icon=icon("chart-line")),
              menuItem("Conclusion", tabName = "tab_4", icon=icon("calendar-check"))
              )
    })
  
  
  output$distPlot <- renderPlotly({
    plot <- ggplot(data_gathered, aes(x=date, y=value, col = type)) +
      geom_line()
    ggplotly(plot)
  })
  
  observe({
    withConsoleRedirect("adfm2", {
      adf.test(data$m2, nlag = 3)
    })
  })
  
  observe({
    withConsoleRedirect("adfy2", {
      adf.test(data$y2, nlag = 3)
    })
  })
  
  observe({
    withConsoleRedirect("adfspreads", {
      adf.test(spreads$spreads, nlag = 3)
    })
  })
  
  output$table_3 <- renderPlot({
    grid.table(z_1, theme= ttheme_default(base_size = 18) )
  })
  
  output$spreadsplot <- renderPlotly({
    plot <- ggplot(spreads, aes(x=date, y=spreads)) +
      geom_line()
    ggplotly(plot)
  })
  
  output$lm_plot <- renderPlotly({
      ggplotly(
        ggplot(dflm, aes(x = m2, y = y2)) +
        geom_line(aes(y=.fitted), color="lightgrey") +
        geom_segment(aes(xend = m2, yend = .fitted), alpha = .2) +
        geom_point(aes(color = abs(.resid))) + # size also mapped
        scale_color_continuous(low = "black", high = "red") +
        guides(color = FALSE, size = FALSE)
      )
  })
  
  output$lm_resid <- renderPlotly({
    plot <- ggplot(dflm, aes(x = date, y = .resid)) + 
      geom_line()
    ggplotly(plot)
  })
  
  observe({
    withConsoleRedirect("console", {
      adf.test(dflm$.resid, nlag = 3)
    })
  })
  
  observe({
    withConsoleRedirect("laglength", {
      print(VARselect(mysample, lag.max = 10, type = "const"))
    })
  })
  
  observe({
    withConsoleRedirect("VEC", {
      print(cajorls(cointtest))
    })
  })
  
  observeEvent(input$tabs,{
        startAnim(session, 'effect_1', 'slideInUp')
    })
  observeEvent(input$tabs,{
    startAnim(session, 'effect_2', 'slideInUp')
  })
  observeEvent(input$tabs,{
    startAnim(session, 'effect_3', 'slideInUp')
  })
  observeEvent(input$tabs,{
    startAnim(session, 'effect_4', 'slideInUp')
  })
  
}
  
  
# run app -----------------------------------------------------------------
  runApp( shinyApp(ui, server), launch.browser = T )

}

