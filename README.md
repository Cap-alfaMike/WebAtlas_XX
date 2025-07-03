# WebAtlas_XX
Dashboard interativo em R/Shiny para exploração de dados socioeconômicos globais do dataset Gapminder.


# WebAtlas Socioeconômico do Século XX

**Autor:** Adalberto Correia

---

## Visão Geral

Este projeto é um dashboard interativo desenvolvido em R com o framework Shiny para a exploração visual e comparativa de dados socioeconômicos do dataset Gapminder.

**[https://geodtsci.shinyapps.io/webSIG/]**



Para uma explicação detalhada de todas as funcionalidades, consulte o **[Manual do Usuário](MANUAL_USUARIO.md)**.

Para detalhes técnicos sobre a implementação e arquitetura do código, consulte o **[Manual do Desenvolvedor](MANUAL_DESENVOLVEDOR.md)**.

---

### Como Executar Localmente

Este projeto utiliza o pacote `{renv}` para garantir a reprodutibilidade do ambiente.

1.  **Pré-requisitos:**
    * [R](https://cran.r-project.org/) e [RStudio](https://posit.co/download/rstudio-desktop/) instalados.
    * Git instalado.

2.  **Clone o Repositório:**
    ```bash
    git clone [https://github.com/Cap-alfaMike/NOME_DO_SEU_REPOSITORIO.git](https://github.com/Cap-alfaMike/NOME_DO_SEU_REPOSITORIO.git)
    cd NOME_DO_SEU_REPOSITORIO
    ```

3.  **Restaure o Ambiente:**
    * Abra o arquivo `.Rproj` no RStudio.
    * Execute o seguinte comando no console para instalar todos os pacotes necessários:
    ```r
    renv::restore()
    ```

4.  **Execute o Aplicativo:**
    ```r
    shiny::runApp()
    ```
