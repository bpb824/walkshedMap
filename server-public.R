require(walkscoreAPI)
require(shiny)
require(leaflet)
require(ggvis)
require(sp)

source("walkshed.R")

####IMPORTANT:
#You will need to substitute your Walkscore API key below and then rename this file 'server.R'. 
#Walkscore API Keys can be found at https://www.walkscore.com/professional/api.php
api_key = "your api key"

function(input, output, session) {
  
  output$score=renderText({"Click a spot on the map."})
  output$walkDesc=renderText({"Click a spot on the map!!!"})
  output$radius=renderText({""})
  
  pal <- colorNumeric(
    palette = c("Red","Yellow","Green"),
    domain = c(0,100)
  )
  
  output$leaf <- renderLeaflet({
    map = leaflet()%>%
      setView(-122.6662589, 45.5317385, zoom = 13) %>%
      addProviderTiles("CartoDB.DarkMatter",
                       options = providerTileOptions(noWrap = TRUE)
      ) %>% addLegend(position = "bottomright", pal =pal, values = c(0,100),title ="Walkscore")
  })
  clicks <<-0
  
  observeEvent(input$leaf_click,{
    clicks <<- clicks+1
    print(paste0("Click number ",clicks))
    if(!is.null(input$leaf_click) & length(input$leaf_click)>0){
      lat = input$leaf_click$lat
      lng = input$leaf_click$lng
      
      score = getWS(lng,lat,api_key)
      result <-walkshedMod(lng,lat,api_key)
      
      if(score$status==1 & result$status==1){
        output$score=renderText({
          paste0("Walkscore = ",score$walkscore)
        })
        output$walkDesc=renderText({
          score$description
        })
        output$radius=renderText({
          paste0("Walk Radius = ",result$radius," miles")
        })
        
        color = pal(score$walkscore)
        
        poly = Polygons(list(Polygon(result$coordinates)),1)
        spatialPoly = SpatialPolygons(list(poly),proj4string = CRS("+init=epsg:4326"))
        
        proxy = leafletProxy("leaf",data = spatialPoly) %>% addPolygons(layerId="poly",fillOpacity = 0.5,stroke=FALSE,fillColor = color)
      }else{
        output$score=renderText({
          "Results unavailable here. Try another spot."
        })
        output$walkDesc=renderText({
          ""
        })
        output$radius=renderText({
          ""
        })
      }
      
    }
  })
  
}
