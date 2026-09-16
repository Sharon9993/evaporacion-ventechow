###############################################################
# APLICATIVO EVAPORACION VEN TE CHOW
# Modelo combinado - Hidroinformatica
###############################################################
##app
install.packages("shiny")
install.packages("shinydashboard")
install.packages("DT")
install.packages("readxl")
install.packages("ggplot2")
##

library(shiny)
library(shinydashboard)
library(DT)

source("modelo_evaporacion.R")


ui <- dashboardPage(

dashboardHeader(title="Evaporacion Ven Te Chow"),

dashboardSidebar(
fileInput("archivo","Cargar data_evap.xlsx",accept=".xlsx"),
actionButton("calcular","Calcular",class="btn-primary")
),


dashboardBody(

tabsetPanel(

tabPanel(
"Inicio",

h2("Modelo de Evaporacion Ven Te Chow"),

p("Aplicativo hidrologico para estimar la evaporacion diaria mediante el metodo combinado de Ven Te Chow."),

h4("Datos requeridos"),
tags$ul(
tags$li("Latitud y altitud"),
tags$li("Fecha de evaluacion"),
tags$li("Radiacion neta"),
tags$li("Temperatura"),
tags$li("Humedad relativa"),
tags$li("Velocidad del viento")
)

),


tabPanel(
"Metodologia",

h3("Proceso de calculo"),

p("1. Calculo astronomico: determina la posicion solar y la radiacion extraterrestre mediante el dia juliano."),

p("2. Balance energetico: utiliza la radiacion neta disponible como fuente de energia para la evaporacion."),

p("3. Demanda atmosferica: calcula el deficit de presion de vapor considerando temperatura y humedad."),

p("4. Evaporacion final: combina el aporte energetico y aerodinamico para obtener la evaporacion diaria (mm/dia).")

),


tabPanel(
"Resultados",

fluidRow(
valueBoxOutput("evap"),
valueBoxOutput("rad"),
valueBoxOutput("def")
),

DTOutput("tabla")

),


tabPanel(
"Radiacion",
plotOutput("graf_rad")
),


tabPanel(
"Temperatura",
plotOutput("graf_temp")
),


tabPanel(
"Evaporacion",
plotOutput("graf_evap")
)

)

)

)



server <- function(input,output){


resultado <- eventReactive(input$calcular,{
req(input$archivo)
calcular_evaporacion(input$archivo$datapath)
})


output$tabla <- renderDT({
resultado()$tabla
})


output$evap <- renderValueBox({
valueBox(round(resultado()$evap,3),
"Evaporacion mm/dia",
color="blue")
})


output$rad <- renderValueBox({
valueBox(round(resultado()$rad,3),
"Radiacion extraterrestre",
color="green")
})


output$def <- renderValueBox({
valueBox(round(resultado()$def,3),
"Deficit vapor KPa",
color="orange")
})


output$graf_rad <- renderPlot({
resultado()$graf_rad
})


output$graf_temp <- renderPlot({
resultado()$graf_temp
})


output$graf_evap <- renderPlot({
resultado()$graf_evap
})

}


shinyApp(ui,server)