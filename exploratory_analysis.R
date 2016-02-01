library(jsonlite)
library(dplyr)
library(tm)
library(ggplot2)

reviews <- stream_in(file("./data/reviewsToys.json"))
metadata <- stream_in(file("./data/metaToys.json"))

# Remove unnecessary variables
reviews <- reviews %>% select(asin, rating=overall, reviewTitle=summary, reviewText)
metadata <- metadata %>% select(asin, title, price)

totalRaw <- inner_join(metadata, reviews, by="asin")

# Number of reviews per product. Filter out products with reviews less than 3
reviewCount <- totalRaw %>% count(asin) %>% arrange(desc(n)) %>% filter(n > 5)
qplot(reviewCount$n, geom="histogram", fill=I("blue"), col=I("red"), alpha = I(.3), binwidth=5,
      main="Distribution of Review Counts per Product", xlab="Review Count", ylab="Frequency", xlim=c(0,300))

# Original data filtered out products with reviews less than 10
reviewCount <- reviewCount %>% filter(n >= 10)
reviewRep <- subset(totalRaw, totalRaw$asin %in% reviewCount$asin)

# Words that do not contribute to keywords and should be removed from review contents
positive <- read.csv("./data/positive words.csv", stringsAsFactors = FALSE)
negative <- read.csv("./data/negative words.csv", stringsAsFactors = FALSE)
positiveWords <- removePunctuation(c(positive[,1]))
negativeWords <- removePunctuation(c(negative[1:2000,1]))
negativeWords2 <- removePunctuation(c(negative[2001:4782,1]))
rmWords <- c("year","old","can","one","bought","will","things","really","got","get",
             "just","much","even","also","use","put","buy","many","product","time",
             "little","need","done","lot","lots","first","set","everything","something")

# Function for generating vector of words in each review (return is class char vector)
reviewToWordsFn <- function(text){
  text_source <- VectorSource(text)
  textCorpus <- Corpus(text_source)
  textCorpus <- tm_map(textCorpus, content_transformer(tolower))
  textCorpus <- tm_map(textCorpus, removePunctuation)
  textCorpus <- tm_map(textCorpus, removeWords, stopwords("English"))
  textCorpus <- tm_map(textCorpus, removeWords, positiveWords)
  textCorpus <- tm_map(textCorpus, removeWords, negativeWords)
  textCorpus <- tm_map(textCorpus, removeWords, negativeWords2)
  textCorpus <- tm_map(textCorpus, removeWords, rmWords)
  textCorpus <- tm_map(textCorpus, stripWhitespace)
  dtm <- as.matrix(DocumentTermMatrix(textCorpus, control=list(wordLengths=c(1,Inf))))
  return(dtm)
}

puncCorrect <- function(tempReviews){
  # Account for reviews that forgot to put spaces after punctuation, 
  # so there will still be space between words after punctuation is removed.
  tempReviews <- lapply(tempReviews, function(x) {gsub("&#34;", " ", x)}) # Amazon reviews code for " gone bad
  tempReviews <- lapply(tempReviews, function(x) {gsub(",", " ", x)})
  tempReviews <- lapply(tempReviews, function(x) {gsub("\\.", " ", x)})
  tempReviews <- lapply(tempReviews, function(x) {gsub("\\?", " ", x)})
  tempReviews <- lapply(tempReviews, function(x) {gsub("!", " ", x)})
  tempReviews <- lapply(tempReviews, function(x) {gsub(";", " ", x)})
  tempReviews <- lapply(tempReviews, function(x) {gsub(":", " ", x)})
  tempReviews <- lapply(tempReviews, function(x) {gsub("&", " ", x)})
  tempReviews <- lapply(tempReviews, function(x) {gsub("-", " ", x)})
  tempReviews <- lapply(tempReviews, function(x) {gsub("/", " ", x)})
  tempReviews <- unlist(tempReviews)
  return(tempReviews)
}

# Test case for the toy Snap Circuits
test <- reviewRep[reviewRep$asin=="B00008BFZH",5:6]
tempReviews <- paste(test$reviewTitle, test$reviewText, sep=" ")
tempReviews <- puncCorrect(tempReviews)
testDTM <- reviewToWordsFn(tempReviews)
rm(tempReviews)
freq <- sort(colSums(as.matrix(testDTM)), decreasing=TRUE)
testWords <- data.frame(word=names(freq), freq=freq, stringsAsFactors = FALSE)
# For colour difference in plot
testWords$colour <- "no"
testWords[testWords$word == "learning","colour"] <- "yes"
testWords <- testWords[testWords$freq>1,]
write.csv(testWords, file="testWords.csv", row.names=FALSE)

# Test case for the toy Scientific Explorer My First Mind Blowing Science Kit

# Lots more recent reviews availble now. Update reviews by getting data from Amazon API & web scraping.

# ==================== Amazon API ====================
library(digest)
library(RCurl)
library(XML)

# Personal info
AWSAccessKeyId <- "********"
AWSsecretkey <- "********"
associateTag <- "********"

if(!is.character(AWSsecretkey)){
  message('The AWSsecretkey should be entered as a character vector, ie be quoted')
}

endPoint <- "webservices.amazon.com"
uri <- "/onca/xml"

service <- "AWSECommerceService"
operation <- "ItemSearch"

responseGroup <- "ItemIds"

keywords <- "science"
searchIndex <- "All"

pb.txt <- Sys.time()
pb.date <- as.POSIXct(pb.txt, tz = Sys.timezone)
timestamp <- strtrim(format(pb.date, tz = "GMT", usetz = TRUE, "%Y-%m-%dT%H:%M:%S.000Z"), 24)

# MUST SORT. R fails to sort strings by ASCII order without touching system locale.
urlParamMap <- list()
urlParamMap <- c(urlParamMap, "AWSAccessKeyId" = AWSAccessKeyId)
urlParamMap <- c(urlParamMap, "AssociateTag" = associateTag)
urlParamMap <- c(urlParamMap, "Keywords" = keywords)
urlParamMap <- c(urlParamMap, "Operation" = operation)
urlParamMap <- c(urlParamMap, "ResponseGroup" = responseGroup)
urlParamMap <- c(urlParamMap, "SearchIndex" = searchIndex)
urlParamMap <- c(urlParamMap, "Service" = service)
urlParamMap <- c(urlParamMap, "Timestamp" = timestamp)

urlParams <- list()
for (paramKey in names(urlParamMap)) {
  paramValue <- urlParamMap[[paramKey]]
  urlParams <- c(urlParams, paste(curlEscape(paramKey), curlEscape(paramValue), sep = "="))
}
urlParamsStr <- paste(urlParams, collapse = '&')

unsignedUrl <- paste("GET\n",
                     endPoint,"\n",
                     uri,"\n",
                     urlParamsStr,
                     sep = "")

signature <- base64(hmac(AWSsecretkey, 
                         unsignedUrl, 
                         algo = "sha256",
                         serialize = FALSE,  
                         raw = TRUE))

signedUrl <- paste("http://",endPoint,uri,"?",
                   urlParamsStr,
                   "&Signature=",curlEscape(signature),
                   sep = "")
result <- getURL(signedUrl)

parsedResult <- xmlToList(result)
items <- parsedResult[["Items"]][names(parsedResult[["Items"]]) == "Item"]

asins <- list()
for (item in items) {
  asins <- c(asins, item[["ASIN"]])
}
# ======================================================

# ==================== Web Scraping ====================
library(rvest)

# arg 1: product ID, e.g. B000BURAP2
# arg 2: page index
pageUrlTemplate <- "http://www.amazon.com/product-reviews/%s/?pageNumber=%d"

pageButtonsCss <- ".page-button a"
reviewTitlesCss <- ".a-color-base"
reviewTextsCss <- ".review-text"

# Function for parsing the html page and extracting data of interest
extractReviewFn <- function(pageUrl) {
  page <- read_html(pageUrl)
  
  extractedTitles <- html_text(html_nodes(page, reviewTitlesCss))
  extractedTexts <- html_text(html_nodes(page, reviewTextsCss))
  
  extractedFromPage <- data.frame(
    title = extractedTitles,
    text = extractedTexts)
  return(extractedFromPage)
}

scrapeReviewFn <- function(productId) {
  scrapedReviews <- data.frame(
    title = character(),
    text = character())
  
  # Look into the first page to see how many review pages this product has
  pageUrl <- sprintf(pageUrlTemplate, productId, 1);
  page <- read_html(pageUrl)
  pageIndices <- as.numeric(html_text(html_nodes(page, pageButtonsCss)))
  # The last page index is the number of pages
  numPages <- pageIndices[length(pageIndices)]
  
  print(sprintf("Number of review pages for product %s: %d", productId, numPages))
  for (pageIndex in 1:numPages) {
    pageUrl <- sprintf(pageUrlTemplate, productId, pageIndex);
    scrapedReviews <- rbind(scrapedReviews, extractReviewFn(pageUrl))
    print(sprintf("Done scraping page %d out of %d.", pageIndex, numPages))
  }
  
  # Cast the extracted factors into characters
  scrapedReviews$title <- as.character(scrapedReviews$title)
  scrapedReviews$text <- as.character(scrapedReviews$text)
  return(scrapedReviews)
}

productId <- asins[1] # B000BURAP2
scrapedReviews <- scrapeReviewFn(productId)

# ======================================================

test2 <- scrapedReviews
tempReviews <- paste(test2$title, test2$text, sep=" ")
tempReviews <- puncCorrect(tempReviews)
test2DTM <- reviewToWordsFn(tempReviews)
rm(tempReviews)
freq2 <- sort(colSums(as.matrix(test2DTM)), decreasing=TRUE)
test2Words <- data.frame(word=names(freq2), freq=freq2, stringsAsFactors = FALSE)
# For colour difference in plot
test2Words$colour <- "no"
test2Words[test2Words$word == "learning","colour"] <- "yes"
test2Words <- test2Words[test2Words$freq>1,]
write.csv(test2Words, file="test2Words.csv", row.names=FALSE)

p1 <- ggplot(subset(testWords, freq>=200), aes(word, freq)) +
  geom_bar(stat="identity", alpha=0.8, aes(fill=colour)) +
  ggtitle("Snap Circuit Reviews Keywords") + ylab("Frequency") +
  theme(plot.title = element_text(lineheight=.8, face="bold",size=16)) +
  theme(axis.text.x=element_text(angle=45, hjust=1, size=16), axis.title.x = element_blank()) +
  theme(legend.position="none")

p2 <- ggplot(subset(test2Words, freq>=48), aes(word, freq)) +
  geom_bar(stat="identity", alpha=0.8, aes(fill=colour)) +
  ggtitle("Science Kit Reviews Keywords") + ylab("Frequency") +
  theme(plot.title = element_text(lineheight=.8, face="bold",size=16)) +
  theme(axis.text.x=element_text(angle=45, hjust=1, size=16), axis.title.x = element_blank()) +
  theme(legend.position="none")

library(Rmisc)
png(filename="keywords.png", width=700, height=1100)
multiplot(p1,p2,cols=1)
dev.off()
