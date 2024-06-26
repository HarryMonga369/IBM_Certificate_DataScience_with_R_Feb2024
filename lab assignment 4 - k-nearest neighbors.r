---
### title: "Lab 4: $K$-Nearest Neighbors"
---
# Introduction

In this lab, we will use the $K$-Nearest Neighbors method to perform classification. We will be working with the famous `iris` data set which consists of four measurements (in centimeters) for 150 plants belonging to three species of iris.

This data set was first published in a classic 1936 paper by English statistician Ronald Fisher. In that paper, multivariate linear models were applied to classify these plants. Of course, back then, model fitting was an extremely laborious process that was done without the aid of calculators or statistical software. To access this data first load the package `datasets` and then load the data set with the command `data(iris)`.


# $K$-nearest neighbors

The $K$-nearest neighbors method is based on the simple idea that observations that are "close" to each other are likely to belong to the same class. There are many ways to define this "closeness" or distance between two observations, but usually we think of an observation with $n$ numerical predictors as a point inside an $n$-dimensional Euclidean space. The distance between two observations is then just the usual Euclidean distance,

$$d(x,y) = \sqrt{(x_1 - y_1)^2 + (x_2 - y_2)^2 + \ldots + (x_n - y_n)^2  }.$$
1) Import the `iris` data set and take a look at the columns. We would like to visualize the $K$-nearest neighbor method in two dimensions, so make a data set called `iris2` consisting of  the columns `Sepal.Width`, `Petal.Width`, and `Species`.
```{r}
#install.packages("class")
library(class)
library(dplyr)
library(tidyverse)
library(ggplot2)

data("iris")
iris2<- select(iris, Sepal.Width, Petal.Width, Species)
head(iris2, 10)
```


2) Create a data set `train` consisting of 60% of the data in `iris2` and
`test` consisting of the remaining 40% of the data. **IMPORTANT: Make sure that each species is represented proportionally in the training set!** HINT: Look at the variable `species`.
```{r}
rows = 150
intTrain = 0.60 * rows
train <- sample_n(iris2,intTrain, replace = FALSE)

intTest = 0.40 * rows
test <- sample_n(iris2, intTest, replace = FALSE)
head(test, 10)
head(train,10)
```


3) Plot the points in `train` in the xy-plane colored by the `Species` labels.
```{r}
ggplot(data = train, mapping = aes(x = Sepal.Width, y = Petal.Width)) + geom_point(aes(color = Species))
```


4) As the name suggests, the $K$-nearest neighbors (KNN) method classifies a point based on the classification of the observations in the training set that are nearest to that point. If $k > 1$, then the neighbors essentially "vote" on the classification of the point. Based on your graph, if $k = 1$, how would KNN classify a flower that had sepal width 3cm and petal width 1cm? (Note, if you use the `plot()` command in base R, the colors are ordered black, red, green.)
            
           Based on the chart presented above, a flower that has a sepal width 3cm and petal width 1cm can be classified as a versicolor flower. 


5) Just to verify that we are correct, find the sepal width, petal width, and species of the observation in `train` that is closest to our flower with sepal width 3cm and petal width 1cm.
There are a lot of ways you could do this (including visual inspection!).
```{r}

nearestNeighbor <- iris2 %>% filter(Sepal.Width == 3, Petal.Width > 1, Petal.Width < 1.5)
(nearestNeighbor)

```


6) Rather than implementing this method by hand, we can use the function `knn()` in the `class` package. Download and install this package and perform the same classification we did in Problem 4. (This means that we are interested in the variables `Sepal.Width` and `Petal.Width` from the `train` dataset!) If you need more information on how to implement `knn()`, please see the R documentation. There will be four items you need to include in your `knn()` code: [1] the data frame of training set cases, [2] a data frame of test set cases, [3] true classifications of training set, saved as factors, [4] number of neighbors to consider.
```{r}
knn(train[,1:2], c(3,1), train$Species, k = 3)

```


We would like to understand how the method of $K$-nearest neighbors will classify points in the plane. That is, we would like to view the _decision boundaries_ of this model. To do this, we will use our model to classify a large grid of points in the plane, and color them by their classification. The code below creates a data frame called `grid` consisting of `r 250^2` points in the plane. 

```{r}
g1 <- rep((200:450)*(1/100), 250)
g2 <- rep((0:250)*(1/100), each = 250)
grid <- data.frame(x1 = g1,
                   x2 = g2)

grid
```


7) Classify the points in `grid` using `train` and $k = 1$. Then, plot the points in `grid` colored by their classification. HINT: Use the `knn()` function with `grid` as the test set. Then, save the output (classifications) to color them in a plot.  
```{r}
grid2 <- grid
newKnn2 <- knn(train[ ,1:2], grid2, train$Species, k = 1)
grid2$class <- newKnn2
qplot( data = grid2, x = g1, y = g2, colour = class)

```


8) Notice that the decision boundary between versicolor and virginica looks a little strange. What do you observe? Why do you think this is happening? Does using $k = 2$ make things better or worse? Why do you think that is?
```{r}
grid3 <- grid
newKnn3 <- knn(train[ ,1:2], grid3, train$Species, k = 2)
grid3$class <- newKnn3
qplot( data = grid3, x = g1, y = g2, colour = class)

```
        
        The decision boundries for knn are becoming too flexible, the result is that there is more intersectionality for the points in the first chart. However this blurry edge come at a cost. K=1 is not that bad but compared to K=2, the boundry becomes WAY too flexible, There are questionable points of intersection for all of the classes rather than just the two in the first graph. 

9) Plot the decision boundaries for a few different values of $K$ and put
the one that you think looks "best" here. (You might also try some really large
values of $K$, just to see what happens.) 
```{r}
grid4 <- grid
newKnn4 <- knn(train[ ,1:2], grid4, train$Species, k = 5)
grid4$class <- newKnn4
qplot( data = grid4, x = g1, y = g2, colour = class)

#forloop to see what does the best 

```


10) Use your value of $K$ to classify the points in `test` and place the confusion matrix here. What is the accuracy of your method? *Note.* You should "set the seed" in R by specifying `set.seed(#)` before you build your model. (In this function, replace the `#` with any number you'd like!) Because R randomly breaks ties, if you do not set the seed, you may get a different result the next time you knit your document (and your answer won't match your code).

```{r}
set.seed(12) 
knn.predict <- knn(train[,1:2], test[,1:2], train$Species, k = 5)
table(knn.predict, test$Species)

```
              
              The model is pretty accurate: 
                   mis-calssifacitions: 4

Awesome!! Your model probably did pretty well, because KNN performs really well on the `iris` data set. However, this isn't a very challenging data set for most classification methods. More challenging data sets have data on different scales and _class imbalance_ where there are very few observations belonging to a particular class. 


11) KNN can also be modified for regression and to give probabilistic predictions
like we get from logistic regression. For regression, we predict the response 
variable for our point to be the average of the response variable for the 
$K$-nearest neighbors. How would you modify the method to give a probabilistic
prediction instead of a classification?
```{r}
set.seed(12) 
knnNew <- glm(Species ~ Sepal.Width + Petal.Width, data = train, family = "binomial" )
knnNew.probs <- predict(knnNew, test, type = "response")
table(knnNew.probs, test$Species)
#with k neighbors, we can check each probability listed that the probabily of where to put each value. 
```





