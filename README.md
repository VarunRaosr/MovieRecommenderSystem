# MovieRecommenderSystem
In this project, I develop a collaborative filtering recommender (CFR) system for recommending movies. 
The basic idea of CFR systems is that, if two users share the same interests in the past, e.g. they liked the same book or the same movie,
they will also have similar tastes in the future. If, for example, user A and user B have a similar purchase history
and user A recently bought a book that user B has not yet seen, the basic idea is to propose this book to user B. 
The collaborative filtering approach considers only user preferences and does not take into account the features or contents of the items
(books or movies) being recommended. In this project, in order to recommend movies, I used a large set of user’s preferences towards
the movies from a movie rating dataset. The dataset used was from MovieLens, and is publicly available at 
http://grouplens.org/datasets/movielens/latest.  The method used here was UBCF(User Based Collaborative Filter) 
and the Similarity Calculation Method was based on Cosine Similarity. The Nearest Neighbors was set to 30.
The predicted item ratings of the user will be derived from the 5 nearest neighbors in its neighborhood.
When the predicted item ratings are obtained, the top 10 most highly predicted ratings will be returned as the recommendations.
The project involved various concepts such as k means clustering algorithm solution for recommending movies to users based on 
their selection on genre and movie interest. The front end was developed using Shiny package.  
Project was implemented in R
