# ===================================================================
# WebAtlas Socioeconômico do Século XX
# Autor: Adalberto Correia
# Versão Final de Produção: 2025-07-03
# ===================================================================

# ===================================================================
# 1. PACOTES E CONFIGURAÇÃO
# ===================================================================
library(shiny)
library(bslib)
library(leaflet)
library(plotly)
library(ggplot2)
library(sf)
library(dplyr)
library(gapminder)
library(DT)
library(htmltools)
library(scales)
library(countrycode)

# ===================================================================
# 2. PREPARAÇÃO DOS DADOS E FUNÇÕES AUXILIARES
# ===================================================================

# Mapa-múndi é carregado uma única vez
world_map <- st_as_sf(maps::map("world", plot = FALSE, fill = TRUE))
world_map <- st_transform(world_map, "+proj=longlat +datum=WGS84")
world_map$ID <- ifelse(world_map$ID == "USA", "United States", world_map$ID)
world_map$ID <- ifelse(world_map$ID == "UK", "United Kingdom", world_map$ID)

# Vetor nomeado para os seletores de métricas
axis_vars <- c("PIB per Capita" = "gdpPercap", "Expectativa de Vida" = "lifeExp", "População" = "pop")

# Mapeamento customizado para nomes de países não-padrão no {countrycode}
custom_map <- c('Bosnia and Herzegovina' = 'BA', 'Congo, Dem. Rep.' = 'CD',
                'Congo, Rep.' = 'CG', 'Korea, Dem. Rep.' = 'KP',
                'Korea, Rep.' = 'KR', 'Yemen, Rep.' = 'YE')

# Função para obter a tag HTML da imagem da bandeira (para UI principal)
get_flag_html <- function(country_names) {
  iso2_codes <- countrycode(country_names, origin = 'country.name', destination = 'iso2c', custom_match = custom_map)
  sapply(iso2_codes, function(code) {
    if (is.na(code)) { as.character(icon("globe")) }
    else { as.character(tags$img(src = paste0("https://flagcdn.com/w20/", tolower(code), ".png"), width = "20px", height="15px", style = "margin-right: 5px;")) }
  }, USE.NAMES = FALSE)
}

# Função que retorna apenas a sigla (código ISO2) para os tooltips dos gráficos
get_iso2_code <- function(country_names) {
  iso2_codes <- countrycode(country_names, origin = 'country.name', destination = 'iso2c', custom_match = custom_map)
  sapply(iso2_codes, function(code) {
    if (is.na(code)) { "N/A" }
    else { code }
  }, USE.NAMES = FALSE)
}

# Função para formatar as métricas de forma consistente
format_metric <- function(value, metric_name) {
  label <- names(axis_vars)[axis_vars == metric_name]
  val_formatted <- if (metric_name == "gdpPercap") {
    scales::dollar(value, big.mark = ".", decimal.mark = ",", prefix = "$")
  } else if (metric_name == "pop") {
    scales::number(value, big.mark = ".", decimal.mark = ",")
  } else if (metric_name == "lifeExp") {
    paste(round(value, 1), "anos")
  } else { as.character(round(value, 2)) }
  return(paste0("<b>", label, ":</b> ", val_formatted))
}


# ===================================================================
# 3. UI (Interface do Usuário com bslib)
# ===================================================================
ui <- page_sidebar(
  title = "WebAtlas Socioeconômico do Século XX",
  theme = bs_theme(version = 5, bootswatch = "flatly", base_font = font_google("Roboto", wght = 400)),
  
  tags$head(tags$style(HTML("
    .subtitle-bar { display: flex; justify-content: space-between; align-items: center; padding: 0.25rem 1.5rem; border-bottom: 1px solid #ddd; margin-bottom: 1rem; }
    .subtitle-right { display: flex; align-items: center; font-size: 0.9rem; }
    .subtitle-right a { margin-left: 10px; color: inherit; }
    .subtitle-right a:hover { color: #000; }
    .action-buttons { margin-top: 20px; }
  "))),
  
  tags$div(
    class = "subtitle-bar",
    tags$h5("Dashboard Interativo", class = "text-muted"),
    tags$div(class = "subtitle-right", "Adalberto Correia | Geógrafo e Cientista de Dados",
             tags$a(href = "https://github.com/Cap-alfaMike", target = "_blank", icon("github", "fa-lg")),
             tags$a(href = "https://www.linkedin.com/in/adalberto-correia-6597b134/", target = "_blank", icon("linkedin", "fa-lg")))
  ),
  sidebar = sidebar(
    title = "Controles",
    accordion(
      id = "main_accordion", open = FALSE, 
      accordion_panel("Dados", icon = icon("database"),
                      radioButtons("dataset_choice", "Fonte de Dados:",
                                   choices = c("Didático (Padrão)" = "clean", "Completo (Não Filtrado)" = "full"),
                                   selected = "clean")
      ),
      accordion_panel("Filtros", icon = icon("filter"),
                      selectInput("metric", "Selecione a Métrica do Mapa:", choices = axis_vars, selected = "gdpPercap"),
                      # ATUALIZADO: Controles inicializados com valores padrão
                      selectInput('continent', 'Selecione o(s) Continente(s)', choices = unique(gapminder::gapminder$continent), selected = "Europe", multiple = TRUE),
                      sliderInput('year', 'Selecione o Ano', min = min(gapminder::gapminder$year), max = max(gapminder::gapminder$year), value = 2007, step = 5, sep = "", animate = animationOptions(interval = 8000))
      ),
      accordion_panel("Configurações do Gráfico", icon = icon("chart-line"),
                      radioButtons("chart_type", "Tipo de Gráfico:", choices = c("Dispersão" = "scatter", "Histograma/Pontos" = "histogram", "Barras" = "bar"), selected = "scatter", inline = TRUE),
                      conditionalPanel("input.chart_type == 'bar'", selectInput("bar_metric", "Métrica para as Barras:", choices = axis_vars, selected = "gdpPercap"), sliderInput("top_n", "Número de Países (Top N):", min = 3, max = 20, value = 10, step = 1)),
                      conditionalPanel("input.chart_type == 'histogram'", selectInput("hist_metric", "Métrica para o Histograma:", choices = axis_vars, selected = "gdpPercap")),
                      conditionalPanel("input.chart_type == 'scatter'", selectInput("x_var", "Variável do Eixo X:", choices = axis_vars, selected = "gdpPercap"), selectInput("y_var", "Variável do Eixo Y:", choices = axis_vars, selected = "lifeExp"))
      ),
      accordion_panel("Configurações da Interface", icon = icon("palette"),
                      radioButtons("theme", "Tema da Aplicação:", choices = c("Claro" = "flatly", "Escuro" = "darkly"), selected = "flatly", inline = TRUE),
                      checkboxInput("show_table", "Mostrar Tabela de Dados", value = TRUE))
    ),
    div(class = "action-buttons",
        actionButton("clear_comparison", "Limpar Comparação", icon = icon("times-circle"), class = "btn-danger w-100 mb-2"),
        actionButton("reset", "Resetar Tudo", icon = icon("sync"), class = "btn-primary w-100")
    )
  ),
  layout_columns(
    col_widths = c(6, 6),
    card(full_screen = TRUE, card_header("Mapa Interativo"), leafletOutput("map", height = 450)),
    card(full_screen = TRUE, card_header(textOutput("plot_title", inline = TRUE)), plotlyOutput("plot", height = 450))
  ),
  uiOutput("comparison_panel"),
  conditionalPanel(condition = "input.show_table == true", card(card_header("Dados Filtrados"), DTOutput('table')))
)

# ===================================================================
# 4. SERVER (Lógica do Aplicativo)
# ===================================================================
server <- function(input, output, session) {
  
  comparison_countries <- reactiveVal(character(0))
  observe(session$setCurrentTheme(bs_theme(bootswatch = input$theme, base_font = font_google("Roboto", wght = 400))))
  
  gapminder_data <- reactive({
    if (input$dataset_choice == "full") gapminder::gapminder_unfiltered else gapminder::gapminder
  })
  
  observeEvent(input$dataset_choice, {
    data <- gapminder_data()
    continent_choices <- unique(data$continent)
    current_continent <- isolate(input$continent)
    selected_continent <- if (all(current_continent %in% continent_choices)) current_continent else "Europe"
    
    updateSelectInput(session, "continent", choices = continent_choices, selected = selected_continent)
    
    min_year <- min(data$year); max_year <- max(data$year)
    year_step <- if(input$dataset_choice == "clean") 5 else 1
    updateSliderInput(session, "year", min = min_year, max = max_year, value = max_year, step = year_step)
  }, ignoreInit = TRUE)
  
  filtered_data_by_continent <- reactive({ req(input$continent, input$year); gapminder_data() %>% filter(year == input$year, continent %in% input$continent) })
  filtered_data <- reactive({ if (length(comparison_countries()) > 0) { req(input$year); gapminder_data() %>% filter(year == input$year, country %in% comparison_countries()) } else { filtered_data_by_continent() } })
  
  output$map <- renderLeaflet({ leaflet() %>% addProviderTiles(providers$CartoDB.Positron, options = providerTileOptions(minZoom = 2)) %>% setView(lng = 15, lat = 30, zoom = 2) })
  
  observe({
    req(nrow(filtered_data_by_continent()) > 0)
    map_data_source <- filtered_data_by_continent()
    map_data <- world_map %>% left_join(map_data_source, by = c("ID" = "country"))
    metric_to_map <- input$metric
    metric_data_domain <- gapminder_data()[[metric_to_map]]
    pal <- colorNumeric("viridis", domain = metric_data_domain, na.color = "#bdbdbd")
    leafletProxy("map", data = map_data) %>% clearShapes() %>% clearControls() %>%
      addPolygons(fillColor = ~pal(map_data[[metric_to_map]]), weight = 1, opacity = 1, color = "white", fillOpacity = 0.7,
                  highlightOptions = highlightOptions(weight = 3, color = "#666", bringToFront = TRUE),
                  label = ~lapply(ID, function(id) {
                    country_info <- gapminder_data() %>% filter(country == id, year == input$year)
                    if(nrow(country_info) > 0) { sprintf("<strong>%s %s</strong><br/>%s<br/>%s<br/>%s", get_flag_html(country_info$country), country_info$country, format_metric(country_info$gdpPercap, "gdpPercap"), format_metric(country_info$lifeExp, "lifeExp"), format_metric(country_info$pop, "pop")) %>% HTML()
                    } else { sprintf("<strong>%s</strong><br/>Dados não disponíveis", id) %>% HTML() }
                  }),
                  layerId = ~ID) %>%
      addLegend(pal = pal, values = metric_data_domain, title = names(axis_vars)[axis_vars == metric_to_map], position = "bottomright")
  })
  
  observeEvent(comparison_countries(), {
    countries_to_highlight <- comparison_countries()
    proxy_map <- leafletProxy("map") %>% clearGroup("comparison_highlight")
    if (length(countries_to_highlight) > 0) {
      selected_polygons <- world_map %>% filter(ID %in% countries_to_highlight)
      proxy_map %>% addPolygons(data = selected_polygons, group = "comparison_highlight", color = "#FF0000", weight = 3, fillOpacity = 0.5)
      if (nrow(selected_polygons) > 0) { bounds <- st_bbox(selected_polygons); proxy_map %>% flyToBounds(bounds$xmin, bounds$ymin, bounds$xmax, bounds$ymax, options = list(padding = c(50,50))) }
    }
    rows_to_select <- which(filtered_data_by_continent()$country %in% countries_to_highlight)
    proxy_table <- dataTableProxy('table')
    if (!identical(sort(rows_to_select), sort(input$table_rows_selected))) { selectRows(proxy_table, rows_to_select) }
    if (input$chart_type == "scatter") {
      points_to_select <- which(filtered_data()$country %in% countries_to_highlight) - 1
      plotlyProxy("plot", session) %>% plotlyProxyInvoke("restyle", list(selectedpoints = list(if(length(points_to_select)>0) points_to_select else NULL)))
    }
  }, ignoreNULL = FALSE, ignoreInit = TRUE)
  
  toggle_selection <- function(current_selection, item) { if (item %in% current_selection) setdiff(current_selection, item) else c(current_selection, item) }
  observeEvent(input$map_shape_click, { comparison_countries(toggle_selection(comparison_countries(), input$map_shape_click$id)) })
  observeEvent(event_data("plotly_click", source = "bar_source"), { comparison_countries(toggle_selection(comparison_countries(), event_data("plotly_click", source = "bar_source")$x)) })
  observeEvent(event_data("plotly_selected", source = "scatter_source"), { comparison_countries(event_data("plotly_selected", source = "scatter_source")$customdata) })
  observeEvent(input$table_rows_selected, { selected_from_table <- filtered_data_by_continent()[input$table_rows_selected, ]$country; comparison_countries(selected_from_table) }, ignoreNULL = FALSE)
  observeEvent(input$clear_comparison, comparison_countries(character(0)))
  observeEvent(input$map_click, { if(is.null(input$map_shape_click)) comparison_countries(character(0)) })
  observeEvent(input$reset, { comparison_countries(character(0)); updateRadioButtons(session, "dataset_choice", selected = "clean"); updateRadioButtons(session, "chart_type", selected = "scatter"); updateSelectInput(session, "metric", selected = "gdpPercap"); updateCheckboxInput(session, "show_table", value = TRUE); updateSelectInput(session, "x_var", selected = "gdpPercap"); updateSelectInput(session, "y_var", selected = "lifeExp"); updateSelectInput(session, "bar_metric", selected = "gdpPercap"); updateSelectInput(session, "hist_metric", selected = "gdpPercap"); updateSliderInput(session, "top_n", value = 10) })
  
  output$plot_title <- renderText({ title <- if (length(comparison_countries()) > 0) { paste("Comparando", length(comparison_countries()), "Países") } else { switch(input$chart_type, "scatter" = paste(names(axis_vars)[axis_vars == input$y_var], "vs.", names(axis_vars)[axis_vars == input$x_var]), "histogram" = paste("Distribuição de", names(axis_vars)[axis_vars == input$hist_metric]), "bar" = paste("Top", input$top_n, "Países por", names(axis_vars)[axis_vars == input$bar_metric])) }; if (input$chart_type == 'histogram' && length(comparison_countries()) > 0) { paste(title, "- Gráfico de Pontos") } else { title } })
  output$plot <- renderPlotly({ df <- filtered_data(); req(nrow(df) > 0); p <- switch(input$chart_type, "scatter" = { req(input$x_var, input$y_var); hover_text <- paste0("<b>", get_iso2_code(df$country), " ", df$country, "</b><br>", format_metric(df$gdpPercap, "gdpPercap"), "<br>", format_metric(df$lifeExp, "lifeExp"), "<br>", format_metric(df$pop, "pop")); x_var <- input$x_var; y_var <- input$y_var; if(x_var == y_var & length(comparison_countries()) == 0) return(NULL); plot_ly(df, x = ~.data[[x_var]], y = ~.data[[y_var]], size = ~pop, color = ~country, text = hover_text, hoverinfo = "text", type = 'scatter', mode = 'markers', source = "scatter_source", key = ~country, customdata = ~country) %>% layout(xaxis = list(title = names(axis_vars)[axis_vars == x_var], type = if(x_var %in% c("gdpPercap","pop")) "log" else "linear"), yaxis = list(title = names(axis_vars)[axis_vars == y_var], type = if(y_var %in% c("gdpPercap","pop")) "log" else "linear"), showlegend = (length(comparison_countries()) > 0), dragmode = "select") %>% event_register("plotly_selected") }, "histogram" = { req(input$hist_metric); metric <- input$hist_metric; if (length(comparison_countries()) > 0) { hover_text <- paste0("<b>", get_iso2_code(df$country), " ", df$country, "</b><br>", format_metric(df[[metric]], metric)); plot_ly(df, x = ~.data[[metric]], y = ~reorder(country, .data[[metric]]), type = 'scatter', mode = 'markers', color = ~country, text = hover_text, hoverinfo = "text", key = ~country) %>% layout(xaxis = list(title = names(axis_vars)[axis_vars == metric]), yaxis = list(title = ""), showlegend = FALSE) } else { g <- ggplot(df, aes(x = .data[[metric]])) + geom_histogram(bins = 20, fill = "#69b3a2", color = "white", alpha = 0.8) + labs(x = names(axis_vars)[axis_vars == metric], y = "Contagem") + theme_minimal(base_size = 14); if(metric %in% c("gdpPercap", "pop")) { g <- g + scale_x_log10(labels = scales::label_number(scale_cut = scales::cut_short_scale())) }; ggplotly(g, tooltip = "x") } }, "bar" = { req(input$bar_metric); metric <- input$bar_metric; bar_df <- df; if(length(comparison_countries())==0) { bar_df <- bar_df %>% filter(!is.na(.data[[metric]])) %>% arrange(desc(.data[[metric]])) %>% slice_head(n = input$top_n) }; hover_text_bar <- paste0("<b>", get_iso2_code(bar_df$country), " ", bar_df$country, "</b><br>", format_metric(bar_df[[metric]], metric)); plot_ly(bar_df, x = ~country, y = ~.data[[metric]], type = 'bar', color = ~country, text = hover_text_bar, hoverinfo = 'text', source = "bar_source") %>% layout(xaxis = list(title = "País", categoryorder = "total descending"), yaxis = list(title = names(axis_vars)[axis_vars == metric]), showlegend = FALSE) %>% event_register("plotly_click") }); if (!is.null(p)) p else NULL })
  
  output$comparison_panel <- renderUI({ 
    selected <- comparison_countries()
    if (length(selected) == 0) return(NULL)
    country_data <- gapminder_data() %>% filter(year == input$year, country %in% selected)
    cards <- lapply(selected, function(c) {
      data_c <- country_data %>% filter(country == c)
      if (nrow(data_c) == 0) return(NULL)
      card(card_header(h5(HTML(paste(get_flag_html(c), c)))), 
           p(strong("Continente:"), data_c$continent), 
           p(HTML(format_metric(data_c$gdpPercap, "gdpPercap"))),
           p(HTML(format_metric(data_c$lifeExp, "lifeExp"))), 
           p(HTML(format_metric(data_c$pop, "pop")))
      )
    })
    tagList(hr(), h4("Painel de Comparação", style="text-align: center;"), layout_columns(col_widths = "fill", !!!cards))
  })
  
  output$table <- renderDT({
    datatable(
      filtered_data_by_continent(),
      options = list(pageLength = 10, scrollX = TRUE),
      rownames = FALSE,
      selection = 'multiple'
    )
  })
}

# ===================================================================
# 5. EXECUTAR O APLICATIVO
# ===================================================================
shinyApp(ui, server)
