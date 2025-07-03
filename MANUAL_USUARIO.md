# Manual do Usuário: WebAtlas Socioeconômico

Bem-vindo ao WebAtlas Socioeconômico! Este dashboard interativo foi projetado para permitir uma exploração fácil e intuitiva de dados de desenvolvimento mundial ao longo do tempo.

## Visão Geral da Interface

A tela é dividida em duas áreas principais:
* **Barra Lateral de Controles (Esquerda):** Onde você ajusta todos os filtros e configurações. Os painéis de controle começam fechados; clique em "Dados", "Filtros", etc., para expandir e ver as opções.
* **Painel de Visualização (Direita):** Onde os mapas, gráficos e tabelas são exibidos.

## Funcionalidades e Passo a Passo

### 1. Selecionando a Fonte de Dados

O primeiro painel na barra lateral, **"Dados"**, permite escolher entre duas fontes de dados:

* **Didático (Padrão):** Um conjunto de dados menor e mais limpo (142 países, de 1952 a 2007 em passos de 5 anos). Ideal para ver as tendências globais de forma clara, especialmente na animação por ano.
* **Completo (Não Filtrado):** Um conjunto de dados maior com mais países e observações anuais. Reflete a complexidade de dados do mundo real, que podem ter "buracos" (anos sem dados para certos países).

### 2. Aplicando Filtros

No painel **"Filtros"**, você pode refinar sua análise:

* **Métrica do Mapa:** Escolha qual variável (PIB per Capita, Expectativa de Vida ou População) será usada para colorir os países no mapa.
* **Continente(s):** Selecione um ou mais continentes para focar sua análise. O mapa dará zoom na sua seleção.
* **Ano:** Arraste o slider para ver os dados de um ano específico. Clique no botão de "play" (▶️) para iniciar um *timelapse* e ver a evolução dos dados ao longo do tempo. A velocidade da animação é de 3 segundos por passo.

### 3. Explorando os Gráficos

No painel **"Configurações do Gráfico"**, você pode mudar a forma de visualizar os dados:

* **Tipo de Gráfico:**
    * **Dispersão:** Compare duas métricas diferentes (ex: PIB vs. Expectativa de Vida).
    * **Histograma/Pontos:** No modo de exploração, mostra a distribuição de uma métrica para os países do continente. No modo de comparação, mostra um gráfico de pontos para comparar os valores individuais dos países selecionados.
    * **Barras:** No modo de exploração, mostra um ranking dos "Top N" países para uma métrica específica. No modo de comparação, mostra as barras apenas para os países selecionados.
* **Controles de Gráfico:** Dependendo do tipo de gráfico escolhido, novas opções aparecerão para você customizar os eixos e o ranking.

### 4. Modo de Comparação (A Funcionalidade Mais Poderosa)

Este dashboard possui um modo de comparação que permite analisar países específicos lado a lado.

* **Como Ativar:** Para entrar no modo de comparação, simplesmente selecione um ou mais países de interesse. Você pode fazer isso de 3 formas:
    1.  **Clicando nos países** diretamente no **mapa** (clicar novamente em um país selecionado o remove da comparação).
    2.  **Clicando nas barras** do **gráfico de barras**.
    3.  **Selecionando uma ou mais linhas** na **tabela de dados** (use Ctrl+Clique para selecionar várias).
* **O que Acontece:**
    * O dashboard inteiro (gráficos, tabela) passará a mostrar **apenas** os dados dos países selecionados.
    * Os países selecionados serão destacados em vermelho no mapa.
    * Um novo **"Painel de Comparação"** aparecerá na parte inferior, mostrando os dados detalhados de cada país lado a lado, com suas respectivas bandeiras.
* **Como Sair:** Para sair do modo de comparação e voltar à exploração por continentes, clique no botão vermelho **"Limpar Comparação"** no topo da barra lateral, ou simplesmente clique em uma área vazia do mapa.

### 5. Outros Controles

* **Configurações da Interface:** Mude o tema visual do dashboard de "Claro" para "Escuro" e escolha se deseja ou não exibir a tabela de dados.
* **Resetar Tudo:** Clique neste botão para retornar todas as configurações do dashboard (filtros, seleções, etc.) ao seu estado inicial.

Explore e descubra as histórias que os dados têm a contar!
