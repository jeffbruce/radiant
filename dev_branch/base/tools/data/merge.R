#######################################
# Merge/Join datasets
#######################################
output$uiMergeDataset <- renderUI({
  datasetlist <- values$datasetlist
  if(length(datasetlist) < 2) return()
  mdatasets <- datasetlist[-which(input$datasets == datasetlist)]
  selectInput(inputId = "mergeDataset", label = "Merge with:",
    choices = mdatasets, selected = state_init("mergeDataset"), multiple = FALSE)
})

output$uiMerge_vars <- renderUI({

  if(is.null(input$mergeDataset)) return()
  vars1 <- varnames()
  vars2 <- colnames(values[[input$mergeDataset]])
  vars <- intersect(vars1, vars2)
  if(length(vars) == 0) return()
  vars <- vars1[vars1 %in% vars]  # need variable labels from varnames()
  selectInput("merge_vars", "Select merge-by variables:", choices  = vars,
    selected = state_multvar("merge_vars",vars), multiple = TRUE, selectize = FALSE)
})

merge_type <- c('inner_join','left_join','semi_join','anti_join')

output$uiMerge_type <- renderUI({
  selectInput("merge_type", "Merge type:", choices  = merge_type,
    selected = state_init_list("merge_type","inner", merge_type), multiple = FALSE)
})

output$ui_Merge <- renderUI({
  list(
    wellPanel(
      uiOutput("uiMergeDataset"),
      conditionalPanel(condition = "output.uiMergeDataset == null",
        HTML("<label>Only one dataset available.</label>")
      ),
      uiOutput("uiMerge_vars"),
      conditionalPanel(condition = "output.uiMerge_vars != null",
        uiOutput("uiMerge_type"),
        textInput("merge_name", "Data name:", state_init("merge_name",paste0("merged_",input$datasets))),
        actionButton('mergeData', 'Merge data')
      )
    ),
    helpAndReport('Merge','merge',inclMD("../base/tools/help/merge.md"))
  )
})

observe({
  # merging data
  if(is.null(input$mergeData) || input$mergeData == 0) return()
  isolate({
    mergeData(input$datasets, input$mergeDataset, input$merge_vars, input$merge_type,
      input$merge_name)
  })
})

mergeData <- function(datasets, mergeDataset, merge_vars, merge_type, merge_name) {

  # gettin the join-type from the string
  tmpjoin <- get(merge_type)
  values[[merge_name]] <- tmpjoin(values[[datasets]], values[[mergeDataset]], by = merge_vars)
  values[['datasetlist']] <- unique(c(merge_name,values[['datasetlist']]))
}

observe({
  if(is.null(input$mergeReport) || input$mergeReport == 0) return()
  isolate({
    inp <- list(input$datasets, input$mergeDataset, input$merge_vars, input$merge_type, input$merge_name)
    updateReportMerge(inp,"mergeData")
  })
})

output$mergePossible <- renderText({
  if(is.null(input$merge_vars))
    return("<h4>No matching variables selected</h4>")
  return("")
})


output$mergeData1 <- renderText({
  if(is.null(input$mergeDataset)) return()
  show_data_snippet(title = paste("<h3>Data:",input$datasets,"</h3>"))
})

output$mergeData2 <- renderText({
  if(is.null(input$mergeDataset)) return()
  show_data_snippet(input$mergeDataset, title = paste("<h3>Data:",input$mergeDataset,"</h3>"))
})
