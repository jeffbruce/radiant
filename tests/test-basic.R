# starting testing
context("basic")

library(RSelenium)
library(testthat)

remDr <- remoteDriver()
remDr$open(silent = TRUE)
appURL <- "http://127.0.0.1:4475"

test_that("can connect to app", {
  remDr$navigate(appURL)
  appTitle <- remDr$getTitle()[[1]]
  expect_equal(appTitle, "Radiant - Marketing Research")
})

test_that("controls are present", {
  webElems <- remDr$findElements("css selector", ".control-label")
  appCtrlLabels <- sapply(webElems, function(x){x$getElementText()})
  expect_equal(appCtrlLabels[[1]], "Datasets:")
  expect_equal(appCtrlLabels[[2]], "Load data:")
  expect_equal(appCtrlLabels[[3]], "")
  expect_equal(appCtrlLabels[[4]], "Save data:")
  expect_equal(appCtrlLabels[[5]], "Remove data from memory:")
})

currentTabLabels <- c("Data","Random","Base","Regression","Maps","Factor","Cluster", "Conjoint","R","Quit","Help","Manage","View","Visualize","Explore","Merge","Transform")

test_that(paste("tabs and nav elements are all present:",paste(currentTabLabels,collapse=" ")), {
  webElems <- remDr$findElements("css selector", ".nav a")
  appTabLabels <- sapply(webElems, function(x){x$getElementText()})
  appTabLabels <- unlist(appTabLabels)
  appTabLabels <- appTabLabels[appTabLabels != ""]
  expect_equal(appTabLabels, currentTabLabels)
})

remDr$close()
