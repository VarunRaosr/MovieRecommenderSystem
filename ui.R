#ui.R
library(shiny)
library(shinythemes)


#static array for genre list
genre_list <- c("Select","Action", "Adventure", "Animation", "Children", 
                "Comedy", "Crime","Documentary", "Drama", "Fantasy",
                "Film.Noir", "Horror", "Musical", "Mystery","Romance",
                "Sci.Fi", "Thriller", "War", "Western")

#shiny code to display web page
shinyUI(fluidPage(
  wellPanel("Movie Recommendation Search Engine"),
 shinythemes::themeSelector(),
  #tags$style("body {background: url(https://i.ytimg.com/vi/ifVEMkQ9BaY/maxresdefault.jpg) no-repeat center center fixed; 
             # background-size: cover;   filter:grayscale(100%);}"),
 
 tags$style("body {background: url(http://www.wallpaperup.com/wallpaper/download/858715) no-repeat center center fixed; 
             background-size: cover;   filter:grayscale(100%);}"),
 
  
  fluidRow(
    
    column(4, wellPanel(h3("Select Movie Genres You Prefer (order matters):")),
           wellPanel(
      selectInput("input_genre", "Genre #1",
                  genre_list),
      selectInput("input_genre2", "Genre #2",
                  genre_list),
      selectInput("input_genre3", "Genre #3",
                  genre_list)
      #submitButton("Update List of Movies")
    )),
    
    column(4,  wellPanel(h3("Select Movies You Like of these Genres:")),
           wellPanel(
      # This outputs the dynamic UI component
      uiOutput("ui"),
      uiOutput("ui2"),
      uiOutput("ui3")
      #submitButton("Get Recommendations")
    )),
    
    column(4,
           wellPanel(h3("You Might Like The Following Movies Too!")),
           wellPanel(
           tableOutput("table")
           #verbatimTextOutput("dynamic_value")
    ))
  )
  
  
))