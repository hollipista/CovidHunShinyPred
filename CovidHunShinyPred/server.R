#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(shiny)
library(gsheet)
library(tidyverse)
library(imputeTS)
library(fpp2)
library(xts)
library(dygraphs)
library(plotly)
set.seed(1234)
covidhu<-gsheet2tbl('https://docs.google.com/spreadsheets/d/1e4VEZL1xvsALoOIq9V2SQuICeQrT5MtWfBm32ad7i8Q')

covidhu<-covidhu[,c(1,3,12,17,18,19,20,21,33)]

names(covidhu)[1] <- "Date"
names(covidhu)[2] <- "NewCases"
names(covidhu)[3] <- "ActiveInfected"
names(covidhu)[4] <- "PositiveTestSHR"
names(covidhu)[5] <- "Fatality"
names(covidhu)[6] <- "Recovered"
names(covidhu)[7] <- "Hospitalized"
names(covidhu)[8] <- "VentilatorTreated"
names(covidhu)[9] <- "Vaccinated"

covidhu <- covidhu %>% filter(Date > as.Date("2020-04-15"))

covidhuts<-covidhu

covidhuts$PositiveTestSHR<-as.numeric(sub(",",".",sub("%", "", covidhu$PositiveTestSHR)))

covidhuts$PositiveTestSHR<-na.interpolation(as.numeric(covidhuts$PositiveTestSHR), option = "linear")
covidhuts$Hospitalized<-na.interpolation(as.numeric(covidhuts$Hospitalized), option = "linear")
covidhuts$VentilatorTreated<-na.interpolation(as.numeric(covidhuts$VentilatorTreated), option = "linear")
covidhuts$Vaccinated[is.na(covidhuts$Vaccinated)] <- 0

covidhuts <- xts(covidhuts[,-1], covidhuts[,1],order.by=covidhuts$Date)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    output$distPlot <- renderPlot({

        # generate df
        rollmean2 = stats::lag(rollmean(covidhuts[,3], k = input$MA, fill = NA),input$LagDay)
        fatality = rollmean(covidhuts$Fatality, k = input$MA, fill = NA)
        df<-as.data.frame(cbind(fatality,rollmean2))
        df<-cbind(df,as.Date(row.names(df)))
        colnames(df)[3]<-"Date"

        # draw
        ggplot(df, aes(x=Date)) +
            geom_line(aes(y = Fatality), color = "darkred", size = 1) + 
            geom_line(aes(y = df[,2]), color="steelblue", size = 1) 

    })
    
    output$txtOutput = renderText({
        paste0("Correlation: ", input$variable)
    })
})
