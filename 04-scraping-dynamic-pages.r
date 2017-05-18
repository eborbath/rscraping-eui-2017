### -----------------------------
### simon munzert
### scraping with selenium
### -----------------------------

## peparations -------------------

source("00-course-setup.r")
wd <- getwd()



## web inspection tools ---------

# Chrome, Firefox:
# right-click on element, then "Inspect Element"

# Safari:
# Settings --> Advanced --> Show Develop menu in menu bar
# Web inspector tools visible in menu bar - the console is most useful

# Edge:
# go to google.com/chrome/ or mozilla.org/en-US/firefox/new/ and download Chrome/Firefox
# next: see above


## let's go to the buzzfeed.com page again and see dynamic webpages in action
browseURL("https://www.buzzfeed.com/?country=us")


## setup R + RSelenium -------------------------

# install current version of Java
browseURL("https://www.java.com/en/download/")
  
# install current version of Firefox browser
browseURL("https://www.mozilla.org/en-US/firefox/new/") # might not always work, probably go with version 48 instead?

# install dev version of RSelenium
devtools::install_github("ropensci/RSelenium")

# note: on a Windows or Linux machine, using Docker might be useful; see
vignette("RSelenium-docker", package = "RSelenium") 


## example --------------------------

url <- "http://www.iea.org/policiesandmeasures/renewableenergy/"
browseURL(url)
content <- read_html(url)

# set up connection via RSelenium package
# documentation: http://cran.r-project.org/web/packages/RSelenium/RSelenium.pdf

# retrieve Selenium Server binary if necessary
checkForServer() ## deprecated; but gives advice on how to source/start a server

# start server
startServer()  ## deprecated

# my solution on a Mac: 
  # install latest Java Development Kit (JDK)
  # install selenium standalone server, current beta
  # open Terminal, navigate to folder where standalone server file is deposited
  # check whether processes run on port 4444 with lsof -i:4444; potentially kill them using PID
  # run the following line in Terminal: java -jar selenium-server-standalone-3.0.0-beta4.jar
  # open Firefox developer tools before sending stuff!




# assume gecko driver is not in our path (assume windows and we downloaded to docs folder)
# if the driver is in your PATH the javaargs call is not needed

# connect to server
remDr <- remoteDriver(remoteServerAddr = "localhost", port = 4444, browserName = "firefox") 

# open connection; Firefox window should pop up
remDr$open() 

# navigate to data request page
remDr$navigate(url) 

# open web inspector tools (on a Mac with my setup, the following code did not work without it)

# open regions menu
css <- 'div.form-container:nth-child(2) > ul:nth-child(2) > li:nth-child(1) > span:nth-child(1)'
regionsElem <- remDr$findElement(using = 'css', value = css)
openRegions <- regionsElem$clickElement() # click on button


# selection "European Union"
css <- 'div.form-container:nth-child(2) > ul:nth-child(2) > li:nth-child(1) > ul:nth-child(3) > li:nth-child(5) > label:nth-child(1) > input:nth-child(1)'
euElem <- remDr$findElement(using = 'css', value = css)
selectEU <- euElem$clickElement() # click on button

# set time frame
css <- 'div.form-container:nth-child(6) > select:nth-child(2)'
fromDrop <- remDr$findElement(using = 'css', value = css) 
clickFrom <- fromDrop$clickElement() # click on drop-down menu
writeFrom <- fromDrop$sendKeysToElement(list("2000")) # enter start year


css <- 'div.form-container:nth-child(6) > select:nth-child(3)'
toDrop <- remDr$findElement(using = 'css', value = css) 
clickTo <- toDrop$clickElement() # click on drop-down menu
writeTo <- toDrop$sendKeysToElement(list("2010")) # enter end year

# click on search button
css <- '#main > div:nth-child(1) > form:nth-child(4) > button:nth-child(14)'
searchElem <- remDr$findElement(using = 'css', value = css)
resultsPage <- searchElem$clickElement() # click on button

# store index page
output <- remDr$getPageSource(header = TRUE)
write(output[[1]], file = "iea-renewables.html")

# close connection
remDr$closeServer()

# parse index table
content <- read_html("iea-renewables.html", encoding = "utf8") 
tabs <- html_table(content, fill = TRUE)
tab <- tabs[[1]]

# add names
names(tab) <- c("title", "country", "year", "status", "type", "target")
head(tab)




#######################
### IT'S YOUR SHOT! ###
#######################

# 1. go to the following webpage and find all Starbucks stores in Chicago that have free WiFi!
# 2. now do the same using Selenium!
# 3. download the data, import it into R and try to plot the stores on a map!

browseURL("http://www.starbucks.com/store-locator/search/location/chicago")



