meta_ktsp_ui <- function(id, label = "MetaPredict") {
    ns <- NS(id)
    tabPanel("MetaPredict", value=id,
             sidebarLayout(
                 sidebarPanel(
                   h3("MetaPredict"),
                   tags$hr(),
                   h4("Summary Table"),
                     br(),br(),
                     tableOutput(ns("summaryTable")),
                     tags$hr(),
                    bsCollapsePanel("About", "This MetaPredict panel serves as an UI for MetaPredict package.
  The MetaPredict is a  meta-analysis version of the TSP algorithm that combines multiple transcriptomic studies to build a prediction model and shows improved prediction accuracy as compared to single study analysis.",
                   a(strong("Tutorials"), href="https://github.com/metaOmics/tutorial/
blob/master/metaOmics_turtorial.pdf",target="_blank"),
                               style = "primary"),
                   bsCollapsePanel("Glossary", strong("TSP"), " top scoring pair", br(),
                                   strong("VO"), " variance optimization",
                                   style = "default"),
                    tags$hr(),
                     bsCollapsePanel("Advanced Options",
                       tagList(
                     selectInput(ns("methods"), label = "Methods for MetaPredict",
                                 choices = list("Mean score" = "Mean score", "Fisher" = "Fisher", "Stouffer" = "Stouffer"),selected = "Mean score"),
                     br(),
                     fluidRow(column(8, numericInput(ns("kMax"), "Max number of top scoring pairs (K)", value=29))),
                     fluidRow(column(8,numericInput(ns("core"), "Number of cores for parallel computing", value=1)))
            ), style="info"
          ),
                     selectizeInput(ns("twoLabels"), label = "Please select TWO labels to train", choices = NULL,multiple=TRUE),
                     br(),
                     selectizeInput(ns("trainStudy"), label = "Please select studies for training (for a total of m studies, training data should be m-1 studies).", choices = NULL,multiple=TRUE),
                     br(),
                     selectizeInput(ns("testStudy"), label = "Please select only ONE study for testing", choices = NULL,multiple=TRUE),
                     tags$hr(),
                     actionButton(ns("ktspTrain"),"Train model", icon= icon("rocket"),class="btn-success btn-run"),
                     tags$hr(),
                     fluidRow(column(6, numericInput(ns("K"),"Number of top scoring pairs (K)",value=29))),
                     actionButton(ns("ktspTest"),"Predict", icon= icon("rocket"),class="btn-success btn-run")
                 ),
                 mainPanel(
                     h4("Gene pair table"),
                     tableOutput(ns("genePairTable")),
                                          tags$hr(),
                                        #                     h4("Label confusion matrix"),
                     textOutput(ns("confusionTitle")),
                     tags$head(tags$style("#confusionTitle{color: black;
                                 font-size: 26px;
                                 }"
                                          )),
                     tableOutput(ns("confusionTable")),
                     br(),
                     textOutput(ns("confusionSens")),
                     textOutput(ns("confusionSpec")),
                     tags$hr(),
                     
                     h4("K diagnostic plot"),
                     textOutput(ns("voExplain")),
                     plotOutput(ns("voPlot"))
                 )
             )
             )
}
