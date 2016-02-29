library(shiny)
library(shinyjs)

shinyUI(
     navbarPage("Prediction Algorithm Testing",
           tabPanel("Data",
                    fluidRow(
                        column(12,
                              h2("Wine dataset", align="center"),
                              hr()
                              )
                        ),
                    fluidRow(
                        column(4,
                               h3("Dimensions:"),
                               verbatimTextOutput("dim"),
                               br(),
                               h3("Variables:"),
                               verbatimTextOutput("names"),
                               br(),
                               useShinyjs(),
                               actionButton("infoBtn", "Info", width = '48%'),
                               actionButton("helpBtn", "Help", width = '48%'),
                               br(),
                               shinyjs::hidden(
                                   textOutput("Info")
                               ),
                               shinyjs::hidden(
                                   textOutput("Help")
                               )

                        ),
                        column(7, offset = 1,
                               h3("Additional Information"),
                               selectInput("choice","Options", c(Choose='',"Summary","Head","Exploratory Plot"), selectize = FALSE),
                               
                               hidden(
                                   sliderInput('amount', 'Choose number of observations', 
                                               min =1, max=14, value=7, step = 1, round = 0)
                               ),
                               shinyjs::hidden(
                                    verbatimTextOutput("summary")
                               ),
                               shinyjs::hidden(
                                    tableOutput("head")
                               ),

                               shinyjs::hidden(
                                   plotOutput("plot")
                               )
                        )
                    )),
               tabPanel("Algorithm",
                        fluidRow(
                            column(12,
                                   h2("Prediction Algorithm Creation", align="center"),
                                   hr(),
                                   div(numericInput("seed", "Set the seed:", 12345, width = 100),
                                   helpText("The seed will make sure the calculations are repeatable."),
                                   actionButton("calculateButton", strong("Calculate!"), width = '25%'),
                                   helpText("Clicking the 'Calculate'-button will start the prediction algorithm,
                                            this might take a few mins. At the top-right of your screen it will tell you
                                            that the calculation is in progress. When the message is gone, the 
                                            'Prediction'-tab will have updated results.", width = 200), align = "center"),
                                   hr()
                            )
                        ),
                        fluidRow(
                            column(4, offset = 2, 
                                   h3("Algorithm Selection"),
                                   selectInput("algorithm", "Options", c("rf", "rda", "gbm", "sda")),
                                   helpText("This selects the algorithm to use for the prediction."),
                                   h3("Percentage of dataset for training"),
                                   sliderInput("trainPercentage", "Choose:",
                                               min = 0.1, max = 0.9, value = 0.6, step = 0.05, round = 2)
                                   ),
                            column(4, offset = 1,
                                   h3("Resampling Method"),
                                   selectInput("method", "Method", c("cv", "boot", "repeatedcv", "adaptive_boot")),
                                   helpText("Here you can select the resampling method, which will be used."),
                                   h3("Iterations"),
                                   sliderInput("iterations", "Choose number of iterations:", 
                                               min = 0, max = 50, value = 10, step = 1, round = 0)
                                   )
                            )
                        ),
               tabPanel("Prediction",
                        fluidRow(
                            h2("Prediction Outcomes", align='center'),
                            hr(),
                            column(6, offset = 1,
                                   fluidRow(
                                       h3("Input used for prediction:"),
                                       tableOutput('input')
                                   ),
                                   fluidRow(
                                       h3("Model Results:"),
                                       tableOutput('model_results')
                                )
                            ),
                                   
                            column(2,
                                    fluidRow(
                                        h3("Training Prediction"),
                                        h4("Confusion Matrix:"),
                                        tableOutput("train_output"),
                                        h4("Statistics:"),
                                        tableOutput("train_statistics")
                                    ),
                                   fluidRow(
                                       h3("Train Prediction:"),
                                       verbatimTextOutput("train_prediction")
                                   )
                            ),
                            column(2,
                                   fluidRow(
                                       h3("Test Prediction"),
                                       h4("Confusion Matrix:"),
                                       tableOutput("test_output"),
                                       h4("Statistics:"),
                                       tableOutput("test_statistics")
                                       
                                   ),
                                   fluidRow(
                                       h3("Test Prediction:"),
                                       verbatimTextOutput("test_prediction")
                                   )
                            )
                        )
            )
    )
)