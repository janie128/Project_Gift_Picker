# Data Science Project: Gift Recommendation
## Gift Recommendation System Based on Customer Reviews
  
Choosing a perfect gift is difficult. We usually browse through product descriptions in hopes of finding something suitable. However, I believe that customer reviews more realistically represent a product, yet a comprehensive evaluation of all reviews would take far too much time. Therefore, I propose to build a gift recommendation system, based on customer reviews.  

This project is in its exploratory stage.  

### Visualization:
Two visualizations have been explored and prepared as ShinyApps:  
1. <a href="https://janiec.shinyapps.io/reviewCount/" target="blank">Product review counts</a>  
2. <a href="https://janiec.shinyapps.io/keywords/" target="blank">Example case keywords</a>  

### File Descriptions:
`exploratory_analysis.R` contains an R script with preliminary analysis of review data, along with examples cases and the script for accessing Amazon API and web scraping to obtain that data.  
`data_source.md` contains detailed description of the data sources.  
`keywords/ui.R`, `keywords/server.R` contain the scripts for the shiny app for visualizing keywords of test cases.  
`reviewCount/ui.R`, `reviewCount/server.R` contain the scripts for the shiny app for visualizing review counts of Amazon products.  

  
### Data Source:
A detailed description of data sources can be found <a href="data_source.md" target="blank">here</a>.
