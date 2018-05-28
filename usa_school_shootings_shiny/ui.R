

shinyUI(
  dashboardPage(skin = "black",
    
    # Header --------------------------------------------------------------------------------------
    
    dashboardHeader(
      title = "School Shootings in the Uninted States",
      titleWidth = 400
    ),
    # End Header
    
    # Sidebar -------------------------------------------------------------------------------------
    
    dashboardSidebar(
      width = 200, 
      sidebarMenu(
        menuItem("Dashboard", tabName = "dashboard", icon = icon("map-o")),
        menuItem("About", tabName = "about", icon = icon("info-circle"))
      ),
      br(),
      column(
          width = 12,
          p("Last Dataset Update"), 
          p(lastUpdate)
      )
    ),
    # End Sidebar
    
    # Body ----------------------------------------------------------------------------------------
    
    dashboardBody(
      tabItems(
        # Start main dashboard
        tabItem(
          tabName = "dashboard",
          fluidRow(
            box(width = 12,
                sliderInput("plot.year", label = "Years Period", min = min(dt$year), max = max(dt$year), 
                            value = c(min(dt$year), max(dt$year)), sep = "",
                            animate = animationOptions())
            )
          ),
          fluidRow(
            valueBoxOutput("shooting_count"),
            valueBoxOutput("injury_count"),
            valueBoxOutput("death_count")
          ),
          fluidRow(
            box(width = 6,
                height = 470,
                leafletOutput("mymap")
            ),
            tabBox(
              height = 470,
              tabPanel("Absolute",
                       plotOutput("barchart")
              ),
              tabPanel("Share",
                       plotOutput("barchart.share")
              )
            )
          )
        ), # End main dashboard
        # Start about tab
        tabItem(
          tabName = "about",
          fluidRow(
            box(
              title = p(icon("address-card"),"Contact"),
              h3("Thomas Schmidt"),
              h4("Data Analyst"),
              br(),
              p(strong("Web:"), a("https://somtom.github.io")),
              p(strong("Email: "), a("som_tom@web.de", href = "mailto:som_tom@web.de")),
              hr(),
              a(icon("github", "fa-2x"), href = "https://github.com/Somtom",
                style = "color:black"),
              a(icon("twitter", "fa-2x"), href = "https://twitter.com/somtom91",
                style = "color:black")
            ),
            box(
              title = p(icon("info-circle"), "About"),
              # Source
              h4(strong("Source")),
              p("The Data set originates from the Wikipedia article", 
                a("List of school shootings in the United States", 
                  href = "https://en.wikipedia.org/wiki/List_of_school_shootings_in_the_United_States"),
                "."),
              p("You can find the ",
                a("source code", 
                  href = "https://github.com/Somtom/shiny_dasbhoard_school_shootings_USA"),
                "for the shiny application on Github."),
              p("A blogpost about the data import and processing can be found",
                a("here",
                  href = "https://somtom.github.io/"),
                "."),
              br(),
              # What is it for
              h4(strong("What is this App for?")),
              p(
                "This app was built to provide a opportunity to explore the United States school
                shootings data present in the Wikipedia article's list. You are supposed
                to get a feeling for the documented indices by exploring what happened when and where.
                The dataset does not raise the claim to be complete and to include every incidents
                ever happened. Therefore it may not be appropriate to use the data for statistical 
                inference."
                ), 
              p("To keep the dashboard's data up-to-date I plan to update the data manually from
                time to time. You find the date of last data extraction, as well as a download button
                for the article from that time as html below."),
              hr(),
              # Last updated
              p(strong("Last updated: "), lastUpdate),
              downloadButton("downloadArticle", label = "Download Article")
            )
          )
        )# End about tab
      )
    ) # End Body
  )
)