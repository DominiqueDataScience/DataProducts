library(shiny)
library(shinyjs)
library(UsingR)
library(caret)
library(ggplot2)
library(curl)
library(data.table)
library(rda)
library(sda)
library(gbm)
library(randomForest)
library(e1071)
library(klaR)


wine_url <- "http://ocw.mit.edu/courses/sloan-school-of-management/15-097-prediction-machine-learning-and-statistics-spring-2012/datasets/wine.csv"
dataWine <- "./data/wine.csv"
if (!file.exists("./data")) {
    dir.create("./data")
}
if (!file.exists(dataWine)) {
    download.file(wine_url, destfile=dataWine, method="curl")
}
raw_data <- read.csv(dataWine)

attributes <- c("Class", "Alcohol", "Malic acid", "Ash", "Alcalinity of ash", "Magnesium", "Total phenols", "Flavanoids",
                "Nonflavanoid phenols", "Proanthocyanins", "Color intensity", "Hue", "OD280/OD315 of diluted wines", "Proline")
names(raw_data) <- attributes
raw_data$Class <- as.factor(raw_data$Class)
raw_data[,6] = as.numeric(as.character(raw_data[,6]))
raw_data[,14] = as.numeric(as.character(raw_data[,14]))


shinyServer(
    function(input, output) {
        
        observeEvent(input$infoBtn, {
            toggle("Info", anim=TRUE)
            hide("Help")
        })
        output$Info <- renderText({
            paste("The Wine dataset can be found at MIT OpenCourseWare Datasets:","http://ocw.mit.edu/courses/sloan-school-of-management/15-097-prediction-machine-learning-and-statistics-spring-2012/datasets/","including a description text.", sep = "\n")
        })
        
        observeEvent(input$helpBtn, {
            toggle("Help", anim=TRUE)
            hide("Info")
        })
        output$Help <- renderText({
            paste("This App is meant to do some Prediction Algorithm Testing.","The first tab 'Data' contains information about the dataset.","In the second tab 'Algorithm' you can choose the algorithm to use.", "The last tab will show the output of the prediction algorithm.", sep = "\n")
        })
        
        output$dim <- renderPrint(dim(raw_data))
        output$names <- renderText(paste(names(raw_data),sep="", collapse=", "))
        output$summary <- renderPrint({
            summary(raw_data)
        })
        
        amount <- reactive({})
        output$head <- renderTable({head(raw_data, input$amount)})
        
        output$plot <- renderPlot(plot(raw_data$Class, raw_data$Alcohol, 
                                                  xlab='Class of Wine', ylab= 'Alcohol (%)', 
                                                  main = 'Wine: Alcohol percentage vs Class'))
        
        
        observeEvent(input$choice, {
            if(input$choice == "Summary")
            {
                toggle("summary")
                hide("head")
                hide("plot")
                hide("amount")
            }
            else if(input$choice == "Head")
            {
                toggle("head")
                toggle("amount")
                hide("plot")
                hide("summary")
            }
            else if(input$choice == "Exploratory Plot") 
            {
                toggle("plot")
                hide("amount")
                hide("summary")
                hide("head")
            }
        })
        
        set.seed <- reactive(input$seed)

        observeEvent(input$calculateButton, 
                { 
                isolate({
                withProgress({
                     setProgress(message = "Calculation in progress, please wait...")
                    inTrain <- createDataPartition(y=raw_data$Class, p=input$trainPercentage, list=FALSE)
                    training <- raw_data[inTrain,]
                    testing <- raw_data[-inTrain,]
                    
                    model <- train(Class ~ ., method = input$algorithm, data = training,
                                   trControl = trainControl(method = input$method, number = input$iterations))
                    
                    output$model_results <- renderTable(model$results,
                                                            options = list(scrollX = TRUE))
                    
                    trainPrediction <- predict(model, training)
                    trainOutput <- confusionMatrix(trainPrediction, training$Class)
                    
                    output$train_output <- renderTable(trainOutput$table)
                    output$train_statistics <- renderTable(
                        table <- data.table(Statistic=names(trainOutput$overall),Value=trainOutput$overall)
                    )
                    output$train_prediction <- renderText(trainPrediction)
                    
                    testPrediction <- predict(model, testing)
                    testOutput <- confusionMatrix(testPrediction, testing$Class)
                    output$test_output <- renderTable(testOutput$table)
                    output$test_statistics <- renderTable(
                        table2 <- data.table(Statistic=names(testOutput$overall),Value=testOutput$overall)
                    )
                    output$test_prediction <- renderText(testPrediction)
                    
                    output$input <- renderTable(
                        table_input <- data.table("Variable"=c("Seed","Algorithm","Train Percentage","Resampling","Iteration"),
                                                  "Value"=c(input$seed,input$algorithm,input$trainPercentage,
                                                            input$method,input$iterations))
                    )
     
                    })
                 })
            }
        )

    }
)