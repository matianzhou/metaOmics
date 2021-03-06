meta_qc_server <- function(input, output,session) {
    library(MetaQC)    
    ns <- NS("meta_qc")
    
   getOption <- function(input) {

    data(pathway) ## c2.all
    #data(prostate8) 
          
     opt <- list() 
      
#    if(length(input$useExample)>0 && input$useExample == T) {     	
#     	 study <- prostate8
#         n <- length(study$data)
#       opt$DList <- study$data
#       opt$colLabel <- study$dataLabel
#     } else {
     	 study <- DB$active
         n <- length(study@datasets)
         opt$DList <- study@datasets
        
         colLabel=list()
         for(i in 1:n){
             tmp=as.vector(unlist(study@clinicals[[i]]))
             colLabel[[i]]=as.numeric(tmp==tmp[1])
        }

        opt$colLabel <- colLabel
#     }
    
     opt$GList <- pathway[[1]]   
     #opt$overlapGenes <- input$overlap.gene
     opt$filterGenes <- input$filter.gene
     opt$cutRatioByMean <- input$filter.mean.gene
     opt$cutRatioByVar <- input$filter.var.gene
     opt$pvalCutGene <- input$pvalue.cut.gene
     opt$pvalAdjustGene <- input$adjust.pvalue.gene
     opt$pvalCutPath <- input$pvalue.cut.pathway
     opt$pvalAdjustPath <- input$adjust.pvalue.pathway   
     #opt$filterPathway <- input$filter.pathway
     opt$minNumGenes <- input$size.min
     opt$maxNumGenes <- input$size.max
     opt$B <- input$permutation

    return(opt)
  }

  ##########################
  # Reactive Values        #
  ##########################
  DB <- reactiveValues(active=DB.load.active(db))
  QC <- reactiveValues(result = NULL)

  ##########################
  # Validation             #
  ##########################
  validate <- function() {
    if(length(DB$active) == 0 )
      warning(MSG.no.active)
  }

  ##########################
  # Observers              #
  ##########################
  observeEvent(input$tabChange, {
     DB$active <- DB.load.active(db)
     DB$working <- paste(DB.load.working.dir(db), "MetaQC/", sep="")
     DB$transpose <- lapply(DB$active@datasets,t)
  })


  observeEvent(input$run, {
    wait(session, "Running MetaQC analysis, might take a few minutes")
    opt <- getOption(input)

   try({
      QC$result <- suppressWarnings(do.call(MetaQC, getOption(input)))
      QC$result$scoreTable <- signif(QC$result$scoreTable,digits=4) #= Peng =#
      QC$result$SMR <- signif(QC$result$SMR,digits=4) #= Peng =#
      print(QC$result$scoreTable)
      dir.path <- paste(DB.load.working.dir(db), "MetaQC", sep="/")
      if (!file.exists(dir.path)) dir.create(dir.path)
      file.path <- paste(dir.path, "result.rds", sep="/")
      saveRDS(QC$result, file=file.path)
      sendSuccessMessage(session, paste("result.rds written to", file.path))
      summary <- cbind(QC$result$scoreTable,QC$result$SMR)
      colnames(summary)[ncol(summary)] <- "SMR"
      file.path <- paste(dir.path, "summaryTable.csv", sep="/")
      write.csv(summary, file=file.path)
      #write.csv(QC$result$SMR, file=paste(dir.path, "SMR.csv", sep="/"))
      sendSuccessMessage(session, paste("summary written to", file.path), unique=T)      
      
      biplot.path <- paste(dir.path, "biplot.png", sep="/")
      png(biplot.path)
         plotMetaQC(QC$result$scoreTable)
      dev.off()
      
      sendSuccessMessage(session, paste("PCA biplot saved to", dir.path))

     output$biplot <- renderImage(      
          list(src=biplot.path, contentType='image/png', alt="biplot"), 
            deleteFile=FALSE
        )
      
      done(session) 
      
     },session)  
     
#      wait(session, "Plotting PCA biplot")

#   try({
#      
#      done(session) 
#  },session)

})

  ##########################
  # Render output/UI       #
  ##########################

  output$summaryTable <- renderTable({
        if(!is.null(DB$active)){
            table <- matrix(NA, length(DB$active@datasets), 2 )
            colnames(table) <- c("#Genes","#Samples")
            rownames(table) <- names(DB$transpose)
            for (i in 1:length(DB$transpose)){
                table[i,2] <- dim(DB$transpose[[i]])[1]
                table[i,1] <- dim(DB$transpose[[i]])[2]
            }
            return(table)
        }
    })

  output$summary <- DT::renderDataTable(DT::datatable({
    table <- QC$result$scoreTable
    SMR <- QC$result$SMR
    summary <- cbind(table,SMR)
    return(summary)
  }))

  output$filter.mean <- renderUI({
    if (input$filter.gene == T) {
      numericInput(ns("filter.mean.gene"), "cut lowest (xx*100)th percentile by mean", value=0.3)
    }
  })

  output$filter.var <- renderUI({
    if (input$filter.gene == T) {
      numericInput(ns("filter.var.gene"), "cut lowest (xx*100)th percentile by variance", value=0.3)
    }
  })

  output$downloadCsv <- downloadHandler(
    filename=function(){"metaQC.result.csv"},
    content=function(file) {
      summary <- cbind(QC$result$scoreTable,QC$result$SMR)
      write.csv(summary, file=file)
    }
  )

  output$min <- renderUI({
    #if (input$filter.pathway == T) {
      numericInput(ns("size.min"), "pathway min gene size", 5)
    #}
  })

  output$max <- renderUI({
    #if (input$filter.pathway == T) {
      numericInput(ns("size.max"), "pathway max gene size", 200)
    #}
  })  
   	        
#  output$srcSelect <- renderUI({
#     radioButtons(ns("useExample"), 'Use Example Dataset:', inline=T,
#        c(Yes=T, No=F), T
#      )
#  })
       
}
