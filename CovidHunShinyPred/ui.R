#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)


# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Hungarian share of positive covid test and fatality in time"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            sliderInput("LagDay",
                        "Lag of Positive test share (%):",
                        min = 0,
                        max = 14,
                        value = 0),
            sliderInput("MA",
                        "Moving average:",
                        min = 1,
                        max = 14,
                        value = 1)
        ),

        # Show a plot of the generated distribution
        mainPanel(
            plotOutput("distPlot")
        )
    )
))
