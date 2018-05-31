
# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {


  # Plot table ----------------------------------------------------------------------------------
  
  selected_years <- eventReactive(input$plot.year, {
    input$plot.year[1]:input$plot.year[2]
  })  
  
  # Map - initial part --------------------------------------------------------------------------
  
  output$mymap <- renderLeaflet({
    leaflet() %>%
      setView(lat = 41.850033, lng = -87.6500523, zoom = 3) %>% 
      addTiles() %>% 
      addLegend(position = "topright", 
                pal = leafletColors, 
                values = c("Incidents with deaths", "No deaths"))
  }) # End Map - initial part
  

  # Map - interactive part ----------------------------------------------------------------------

  observe({
    dt.plot <- dt %>% 
      filter(year %in% selected_years()) 
    
    if (nrow(dt.plot) > 0) {
      leafletProxy("mymap", data = dt.plot)  %>%
        clearMarkers() %>% 
        addCircleMarkers(lng = ~lon,
                         lat = ~lat,
                         popup = ~popup,
                         label = ~Location,
                         color = ifelse(dt.plot$Deaths > 0, myFillColors["Deaths"], myFillColors["Injuries"]),
                         opacity = 0.3,
                         fillOpacity = 0.3,
                         radius = sqrt(dt.plot$Deaths + dt.plot$Injuries) + 6
        ) 
    }
    else{
      leafletProxy("mymap", data = dt.plot)  %>%
        clearMarkers()
    }
  }) # End Map - interactive part
  

  # Value Boxes ---------------------------------------------------------------------------------

  observe({
    dt.summary_stats <- dt %>% 
      filter(year %in% selected_years()) %>% 
      summarise(incidents = n(),
                deaths = sum(Deaths, na.rm = T),
                injuries = sum(Injuries, na.rm = T))
    
    output$death_count <- renderValueBox(
      valueBox(subtitle = "Deaths", value = dt.summary_stats$deaths, icon = icon("male"),
               color = "red")
    )
    
    output$injury_count <- renderValueBox(
      valueBox(subtitle = "Injuries", value = dt.summary_stats$injuries, icon = icon("ambulance"),
               color = "yellow")
    )
    
    output$shooting_count <- renderValueBox(
      valueBox(subtitle = "Shootings", value = dt.summary_stats$incidents, icon = icon("crosshairs"),
               color = "yellow")
    )
  }) # End Value Boxes
  

  # Barcharts ------------------------------------------------------------------------------------
  observe({
    dt.plot <- dt %>% 
      filter(year %in% selected_years()) %>% 
      group_by(State) %>% 
      summarise(Deaths = ifelse(is.na(sum(Deaths, na.rm = T)), 0, sum(Deaths, na.rm = T)),
                Injuries = ifelse(is.na(sum(Injuries, na.rm = T)), 0, sum(Injuries, na.rm = T))) %>%
      mutate(Total = Deaths + Injuries) %>% 
      gather(key = category, value = count, Deaths, Injuries) %>% 
      filter(Total > 0)
 
    # Render plot if data for selected years, else: return empty ggplot
    if (nrow(dt.plot) > 0) {
      output$barchart <- renderPlot({
        dt.plot %>% 
          ggplot() +
          geom_col(aes(x = reorder(State, Total), y = count, fill = category),
                   alpha = 0.7, width = 0.8) +
          scale_fill_manual(values = myFillColors,
                            guide = guide_legend(title = NULL, keywidth = 1, keyheight = 1)) +
          xlab("State") +
          ylab("Injured and Death People") +
          coord_flip() +
          theme_minimal() +
          theme(legend.position = "bottom")
      })
      
      output$barchart.share <- renderPlot({
        dt.plot %>% 
          ggplot() +
          geom_col(aes(x = reorder(State, Total), y = count, fill = category),
                   alpha = 0.7, width = 0.8, position = "fill") +
          scale_fill_manual(values = myFillColors,
                            guide = guide_legend(title = NULL, keywidth = 1, keyheight = 1)) +
          scale_y_continuous(labels = scales::percent) +
          xlab("State") +
          ylab("Share") +
          coord_flip() +
          theme_minimal() +
          theme(legend.position = "bottom")
      })
    }
    else {
      output$barchart <- renderPlot({
        ggplot() + theme_minimal()
      })
      
      output$barchart.share <- renderPlot({
        ggplot() + theme_minimal()
      })
    }
    
  }) # End Barcharts

  # Download HTML of Article --------------------------------------------------------------------

  output$downloadArticle <- downloadHandler(
    filename = function() {
      paste("Wikipedia_Article_List_of_school_shootings_in_the_United_States_(as_of_", lastUpdate, ").html", sep = "")
    },
    content = function(file) {
      write_html(htmlArticle, file)
    }
  )
})
