# getwd()
# setwd("C:/Users/Hp/Documents")


movies <- read.csv("movies.csv",stringsAsFactors=FALSE)

ratings <- read.csv("ratings.csv")
#install.packages("recommenderlab")## This package is used for classification algorithm and also for association algorithm
#install.packages("ggplot2")
library(recommenderlab)
library(ggplot2)

genre <- as.data.frame(movies$genres, stringsAsFactors=FALSE)##Splitting genres from movie table

genre
#install.packages("data.table")
##Fast aggregation of large data (e.g. 100GB in RAM), fast ordered joins, fast add/modify/delete of columns by group using no copies at all, list columns, a fast friendly file reader and parallel file writer. Offers a natural and flexible syntax, for faster development.

library(data.table)
genre_new <- as.data.frame(tstrsplit(genre[,1], '[|]', 
                                   type.convert=TRUE), 
                         stringsAsFactors=FALSE)##Classifies each movie into different categories

colnames(genre_new) <- c(1:10)
colnames(genre_new)
genrelist <- c("Action", "Adventure", "Animation", "Children", 
                "Comedy", "Crime","Documentary", "Drama", "Fantasy",
                "Film-Noir", "Horror", "Musical", "Mystery","Romance",
                "Sci-Fi", "Thriller", "War", "Western")##List of all possible genres in the movie table
genre_matrix <- matrix(0,10330,18)
genre_matrix ##Creating a empty matrix with 0 in all the entries        
genre_matrix[1,] <- genrelist
genre_matrix
colnames(genre_matrix) <- genrelist##giving the column names with genre list
genre_matrix
ncol(genres_new)


for (i in 1:nrow(genres_new)) {
  for (c in 1:ncol(genres_new)) {
    genremat_col = which(genre_matrix[1,] == genres_new[i,c])
    genre_matrix[i+1,genremat_col] <- 1
  }
}## i is the number of rows in genre2,c is the number of col in genre2. Compare genre_matrix with genre2 and enter value 1
genre_matrixnew <- as.data.frame(genre_matrix[-1,], stringsAsFactors=FALSE) #remove first row, which was the genre list
for (c in 1:ncol(genre_matrixnew)) {
  genre_matrixnew[,c] <- as.integer(genre_matrixnew[,c])
} #convert from characters to integers

#Create a matrix to search for a movie by genre and year
years <- as.data.frame(movies$title, stringsAsFactors=FALSE)## getting the movie names into years
install.packages("datatable")
library(data.table)
substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))## getting the last characters in a string
}
years <- as.data.frame(substr(substrRight(substrRight(years$`movies$title`, 6),5),1,4))
years
searchmatrix <- cbind(movies[,1], substr(movies[,2],1,nchar(movies[,2])-6), years, genre_matrixnew)
nrow(nchar(movies[,2])-6)
colnames(searchmatrix) <- c("movieId", "title", "year", genrelist)
write.csv(searchmatrix, "search.csv")
searchmatrix <- read.csv("search.csv", stringsAsFactors=FALSE)

# Example of search an Action movie produced in 1995:
subset(searchmatrix, Action == 1 & year == 1995)$title

## Create a user profile

binaryrating <- ratings

# ratings of 4 and 5 are mapped to 1, 
# representing likes, and ratings of 3 
# and below are mapped to -1, representing 
# dislikes:

for (i in 1:nrow(binaryrating)){
  if (binaryrating[i,3] > 3){
    binaryrating[i,3] <- 1
  }
  else{
    binaryrating[i,3] <- -1
  }
}

# convert binaryratings matrix to the correct format:

binaryrating_new <- dcast(binaryrating, movieId~userId, value.var = "rating", na.rm=FALSE)

for (i in 1:ncol(binaryrating_new)){
  binaryrating_new[which(is.na(binaryrating_new[,i]) == TRUE),i] <- 0
}
binaryratings_new = binaryrating_new[,-1] #remove movieIds col. Rows are movieIds, cols are userIds


#Remove rows that are not rated from movies dataset
movieId <- length(unique(movies$movieId)) #10329
ratingmovieIds <- length(unique(ratings$movieId)) #10325
movies_new <- movies[-which((movies$movieId %in% ratings$movieId) == FALSE),]
rownames(movies_new) <- NULL

#Remove rows that are not rated from genre_matrix2
genre_matrix3 <- genre_matrixnew[-which((movies$movieId %in% ratings$movieId) == FALSE),]
rownames(genre_matrix3) <- NULL

# calculate the dot product of the genre matrix and 
# the ratings matrix and obtain the user profiles

#Calculate dot product for User Profiles
result = matrix(0,18,668) # Here, 668=no of users/raters, 18=no of genres
for (c in 1:ncol(binaryrating_new)){
  for (i in 1:ncol(genre_matrix3)){
    result[i,c] <- sum((genre_matrix3[,i]) * (binaryrating_new[,c])) #ratings per genre
  }
}

#Convert to Binary scale

for (c in 1:ncol(result)){
  for (i in 1:nrow(result)){
    if (result[i,c] < 0){
      result[i,c] <- 0
    }
    else {
      result[i,c] <- 1
    }
  }
}

## Assume that users like similar items, and retrieve movies 
# that are closest in similarity to a user's profile, which 
# represents a user's preference for an item's feature.
# use Jaccard Distance to measure the similarity between user profiles
## Jaccard distance calculats the similarity among clusters
# The User-Based Collaborative Filtering Approach

library(reshape2)
#Create ratings matrix. Rows = userId, Columns = movieId
ratingmat <- dcast(ratings, userId~movieId, value.var = "rating", na.rm=FALSE)
ratingmat <- as.matrix(ratingmat[,-1]) #remove userIds

# Method: UBCF
# Similarity Calculation Method: Cosine Similarity
# Nearest Neighbors: 30

library(recommenderlab)
#Convert rating matrix into a recommenderlab sparse matrix
ratingmat <- as(ratingmat, "realRatingMatrix")

# Determine how similar the first four users are with each other
# create similarity matrix
similarity_users <- similarity(ratingmat[1:4, ], 
                               method = "cosine", 
                               which = "users")
as.matrix(similarity_users)
image(as.matrix(similarity_users), main = "User similarity")

# compute similarity between
# the first four movies
similarity_items <- similarity(ratingmat[, 1:4], method =
                                 "cosine", which = "items")
as.matrix(similarity_items)
image(as.matrix(similarity_items), main = "Item similarity")

# Exploring values of ratings:
vector_ratings <- as.vector(ratingmat@data)
unique(vector_ratings) # what are unique values of ratings

table_ratings <- table(vector_ratings) # what is the count of each rating value
table_ratings

# Visualize the rating:
vector_ratings <- vector_ratings[vector_ratings != 0] # rating == 0 are NA values
vector_ratings <- factor(vector_ratings)

qplot(vector_ratings) + 
  ggtitle("Distribution of the ratings")

# Exploring viewings of movies:
views_per_movie <- colCounts(ratingmat) # count views for each movie

table_views <- data.frame(movie = names(views_per_movie),
                          views = views_per_movie) # create dataframe of views
table_views <- table_views[order(table_views$views, 
                                 decreasing = TRUE), ] # sort by number of views

ggplot(table_views[1:6, ], aes(x = movie, y = views)) +
  geom_bar(stat="identity") + 
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) + 
  scale_x_discrete(labels=subset(movies2, movies2$movieId == table_views$movie)$title) +
  ggtitle("Number of views of the top movies")

#Visualizing the matrix:
image(ratingmat, main = "Heatmap of the rating matrix") # hard to read-too many dimensions
image(ratingmat[1:10, 1:15], main = "Heatmap of the first rows and columns")
image(ratingmat[rowCounts(ratingmat) > quantile(rowCounts(ratingmat), 0.99),
                colCounts(ratingmat) > quantile(colCounts(ratingmat), 0.99)], 
      main = "Heatmap of the top users and movies")


#Normalize the data
ratingmat_norm <- normalize(ratingmat)
image(ratingmat_norm[rowCounts(ratingmat_norm) > quantile(rowCounts(ratingmat_norm), 0.99),
                     colCounts(ratingmat_norm) > quantile(colCounts(ratingmat_norm), 0.99)], 
      main = "Heatmap of the top users and movies")

#Create UBFC Recommender Model. UBCF stands for User-Based Collaborative Filtering
recommender_model <- Recommender(ratingmat_norm, 
                                 method = "UBCF", 
                                 param=list(method="Cosine",nn=30))

model_details <- getModel(recommender_model)
model_details$data

recom <- predict(recommender_model, 
                 ratingmat[1], 
                 n=10) #Obtain top 10 recommendations for 1st user in dataset

recom

#recc_matrix <- sapply(recom@items, 
#                      function(x){ colnames(ratingmat)[x] })
#dim(recc_matrix)

recom_list <- as(recom, 
                 "list") #convert recommenderlab object to readable list

#Obtain recommendations
recom_result <- matrix(0,10)
for (i in 1:10){
  recom_result[i] <- as.character(subset(movies, 
                                         movies$movieId == as.integer(recom_list[[1]][i]))$title)
}


# Evaluation:
evaluation_scheme <- evaluationScheme(ratingmat, 
                                      method="cross-validation", 
                                      k=5, given=3, 
                                      goodRating=5) #k=5 meaning a 5-fold cross validation. given=3 meaning a Given-3 protocol
evaluation_results <- evaluate(evaluation_scheme, 
                               method="UBCF", 
                               n=c(1,3,5,10,15,20))
eval_results <- getConfusionMatrix(evaluation_results)[[1]]