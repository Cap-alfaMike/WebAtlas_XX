# Manual do Desenvolvedor: WebAtlas Socioeconômico

Este documento detalha a arquitetura, a lógica reativa e os componentes principais do código do aplicativo Shiny WebAtlas.

## Estrutura do Projeto

O projeto consiste em um único arquivo `app.R`, que segue uma estrutura modular e comentada:

1.  **Pacotes e Configuração:** Carregamento de todas as bibliotecas necessárias.
2.  **Preparação de Dados e Funções Auxiliares:** Definição de objetos estáticos (como o `world_map`) e funções de ajuda (`get_flag_html`, `get_iso2_code`, `format_metric`) para manter o código do `server` limpo e organizado.
3.  **UI (User Interface):** Definição da interface do usuário usando o pacote `{bslib}` para um layout moderno e responsivo. A UI é construída com `page_sidebar` e os componentes são organizados em `card`s. O seletor de ano e continente são inicializados na UI, mas atualizados dinamicamente no server.
4.  **Server (Lógica do Aplicativo):** Contém toda a lógica reativa que responde às interações do usuário.
5.  **Execução do Aplicativo:** Chamada `shinyApp(ui, server)`.

O projeto é gerenciado pelo pacote `{renv}`, garantindo total reprodutibilidade do ambiente através do arquivo `renv.lock`.

## Reatividade e Fluxo de Dados

A reatividade do dashboard é controlada por um "sistema nervoso central" baseado em `reactive` e `observeEvent`.

### Reativos Principais

* `gapminder_data()`: Um `reactive` que retorna o dataset `gapminder` ou `gapminder_unfiltered` com base na seleção do `input$dataset_choice`. Este é o reativo mais fundamental e todos os outros dados derivam dele.
* `filtered_data_by_continent()`: Filtra `gapminder_data()` com base nos `input$year` e `input$continent`. Representa o "universo" de dados no modo de exploração e é a fonte de dados para a tabela `DT`.
* `comparison_countries()`: Um `reactiveVal` que armazena um vetor com os nomes dos países selecionados para o modo de comparação. Este é o **estado central** da interatividade de comparação.
* `filtered_data()`: O reativo final que alimenta os gráficos e o painel de comparação. Ele possui uma lógica condicional:
    * Se `comparison_countries()` estiver preenchido, ele retorna os dados filtrados apenas para os países selecionados.
    * Se `comparison_countries()` estiver vazio, ele retorna o resultado de `filtered_data_by_continent()`.

### Eventos e Interações

A sincronização entre os componentes é gerenciada por `observeEvent`.

* **`observeEvent(input$dataset_choice, ...)`**: Um observador crucial que reage à mudança do dataset. Ele atualiza dinamicamente as opções do seletor de continentes e os parâmetros (min, max, step) do slider de ano usando `updateSelectInput` e `updateSliderInput`.

* **`observeEvent(comparison_countries(), ...)`**: Este é o "sistema nervoso central". Ele é acionado sempre que a lista de países para comparação muda. Dentro dele:
    1.  `leafletProxy()` é usado para limpar destaques antigos e desenhar novos polígonos vermelhos no mapa, além de dar zoom (`flyToBounds`) nos países selecionados.
    2.  `dataTableProxy()` é usado para selecionar programaticamente as linhas correspondentes na tabela de dados, garantindo que a seleção visual da tabela esteja sempre em sincronia com o estado de comparação.
    3.  `plotlyProxy()` é usado para destacar os pontos no gráfico de dispersão quando em modo de seleção.

* **Fontes de Interação:** Vários `observeEvent` monitoram os cliques e seleções do usuário (no mapa, no gráfico de barras, na tabela, no gráfico de dispersão) e atualizam o `comparison_countries()`, que por sua vez aciona o observador central. A lógica é cuidadosamente construída para evitar loops de reatividade infinitos (ex: a atualização da tabela pelo proxy não aciona novamente o evento de seleção da tabela).

### Componentes Chave do Código

* **`get_flag_html()` vs `get_iso2_code()`**: O app usa uma abordagem híbrida para as bandeiras. Tags de imagem (`<img>`) são usadas na UI principal (mapa, painel de comparação), onde a renderização de HTML é robusta. Siglas de texto simples (códigos ISO) são usadas nos tooltips do Plotly, que não renderizam imagens de forma confiável.
* **`output$plot <- renderPlotly({...})`**: Utiliza uma declaração `switch(input$chart_type, ...)` para renderizar dinamicamente um dos três tipos de gráfico no mesmo `plotlyOutput`.
    * A lógica do **Histograma** usa uma abordagem híbrida: no modo de exploração, usa `ggplot2` + `ggplotly()` para criar um histograma estável. No modo de comparação, gera um gráfico de pontos com `plotly` nativo, que é mais adequado para poucos dados.
* **`event_register()`**: As funções de interatividade do Plotly (`plotly_click` e `plotly_selected`) são explicitamente registradas em seus respectivos gráficos para garantir compatibilidade com versões mais recentes dos pacotes.
