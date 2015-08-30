require(shiny)
require(leaflet)
require(htmltools)

fluidPage(
  titlePanel(title = "",windowTitle = "Walkshed Explorer"),
  leafletOutput("leaf", width = "100%",height = 400),
  fixedRow(
    h1(textOutput("score"),align="center"),
    h2(textOutput("walkDesc"),align="center"),
    h2(textOutput("radius"),align="center")
  )
)