---
### title: "Lab 8: Random Forests"
---


# Introduction

In this lab, we will practice using the random forest method to perform classification and to make numerical predictions. In addition, we will talk more about _cross validation_ and _parameter tuning._

We will be using the famous Titanic data set which includes data for many passengers on the Titanic, including whether or not they survived.

The files have already been cleaned up a bit for you and are split into testing and training sets available on Moodle.

The categories in the data represent, in order: 
* whether the passenger survived (1) or died (0), 
* Ticket Class (1 = 1st, 2 = 2nd, 3 = 3rd),
* Sex, 
* Age (NA if unknown), 
* Siblings/spouses on board,
* Parents/children on board,
* Fare paid, 
* Port of Embarkation (either Cherbourg, Queenstown, or Southampton).

# Random Forest Lab

Let's start with some simple exploratory data analysis and reasonable conjectures about who might have survived the Titanic.

1) Load the two data sets. Based on the characteristics above, which two or three features do you think are going to be most important for predicting survival? Give a brief justification for each. **Your datasets should both have 8 columns! Remove the variable 'X' if it exists after importing!**

```{r message=FALSE, warning=FALSE}
library(class)
library(dplyr)
library(tidyverse)
library(ggplot2)
library(rpart)
library(rpart.plot)
library(Stat2Data)
```


```{r}
set.seed(4)
test <- read.csv("/Users/sewii/Documents/CLASSES_Spring2022/Data325_AppliedDataScience/Titanic_test.csv")
train <- read.csv("/Users/sewii/Documents/CLASSES_Spring2022/Data325_AppliedDataScience/Titanic_train.csv")
train <-test <-test[,-1]
train[,-1]
head(test, 10)
head(train,10)

#I suspect that survived , sex, pclass, parch will be the most important for predicting survival

```
            
        


2) In the training data set, what percentage of the male passengers survived? What percentage of the female passengers survived?

```{r}
xtabs(~Survived + Sex, data = train)
#count(Survived, x = train)

percent_Male = 89/274	
percent_Female =  185 / 274

percent_Male 
percent_Female

#32.4% of Male passangers survived, and 67.5% of female passangers survived
```
          
            

There are some missing age values in the testing and training data sets. One option would be to just toss out all of this data, but you can lose a lot of data this way. Another approach is to _impute_ the missing data. This means that we just fill in a best guess for each missing data point in the test and train sets. 

3) Replace all of the missing age values in **both** the test and train sets with the median age of **all** the passengers for which age data is available in both data sets. The function `is.na()` applied to a vector will return a logical vector indicating the location of `NA` values. 

```{r}

train$Age[is.na(train$Age)] <- mean(train$Age, na.rm = T) 
test$Age[is.na(test$Age)] <- mean(test$Age, na.rm = T) 

head(train, 10)
head(test,10)
```


4) Build a classification tree using the function `rpart()` on the training set to predict who will survive. (You might need to convert the `Survived` column of both the test and train sets to a factor column using `as.factor()`). Plot your classification tree below.

```{r}


reg_tree <- rpart(as.factor(Survived)~., data = train)
rpart.plot(reg_tree)



```

5) Apply your model to the test set to predict who will survive. Print the confusion matrix below. What is the accuracy of this tree model? Remember to use `type = "class"`. 

```{r}

TreePrediction <- predict(reg_tree, newdata = test, type = "class")

table(TreePrediction, test$Survived)
#  145/178 predictions are made correctly with this model. In other words this tree model is 81% accurate  

```



## Random Forests

One way to improve the predictive power of regression and classification trees is to build many trees and then either average the resulting predictions (for regression trees) or letting the trees "vote" on the resulting classification (for classification trees). 

In order for this to be effective, we need for each tree to be slightly different to give us different information about the data. 

This can be achieved with a method called _bootstrap aggregation_ (also called _bagging_). In this approach, we build multiple trees, each training on only a portion of the available data points (selected randomly, with replacement). Overall, this has a tendency to reduce the variance we get by training on different subsets of the data (more details are given in Section 8.2.1 of your textbook).

Another thing we can do, is when building each tree, restrict the training data to a random subset of the available factors. This is known as a _random forest_ approach. Random, since the subsets of the variables are random, and forest, well, because there are lots of trees. By training the trees on different subsets of the factors, we decorrelate the resulting trees and prevent single factors from dominating (Random Forests are described in more detail in Section 8.2.2).

6) To build a random forest for the Titanic data set, 
* Uncomment the code below
* Put in your training data as the data set.
* Choose the number of factors to consider at each step by specifying `mtry` (between 1 and 7 makes sense since we have 7 factors).
* Choose the number of trees to build by specifying `ntree`. 

If you use `ntree = 1`, then your random forest is just a classification tree. If you do not specify the number of trees, the default is 500! In general, the predictive accuracy improves as you increase the number of trees, but only up to a certain point.


```{r include=FALSE}
 library(randomForest)
```


```{r}
rf_model <- randomForest(as.factor(Survived) ~ .,
                          data =  train   , # your training data
                          mtry =  5   , # number of factors
                          ntree = 250   , # number of trees
                          importance = TRUE,
                          type = "class")
rf_model
```


One appealing aspect of a random forest approach is that it inherently determines which factors are valuable (without requiring a preliminary factor selection process). For this reason, it is generally not necessary to restrict the variable set ahead of time to avoid overfitting. 

7) Uncomment the code below to view the variable importance for the model above. Does this ranking of important factors agree with your initial impressions from Problem 1?
```{r}
varImpPlot(rf_model)

#In problem 1, I assumed that sex, pclass, parch will be the most important for predicting survival. Using the model below, I see that the factor with the smallest mean  decreased accuracy is Embarked, then age and SibSp.  This tells us that Embarked, Age, and SibSp are the most important variables for predicting survival. 
```

The importance of each factor is determined by the percentage increase in either accuracy or the GINI index (a different measure of accuracy based on the "area under the curve") when that factor is excluded during the tree building process.


## Cross Validation and Parameter Tuning

As we have seen in previous labs, there is a difference between the _train error_ and the _test error_. When we are building a predictive model, we really want a model that minimizes the _test error_. One way we have addressed this is by splitting our data into a test set and a training set. This allows us to build models on the training set and then compare their performance on the test set. 

However, the major problem with this approach is that the accuracy might vary greatly depending on the random split of our data into testing and training sets.

8) Below is a _for loop_ that splits the original `Titanic` data set into train/test sets 50 different times. The train and test sets are called `t1` and `t2` respectively. 

Uncomment and add to the loop code to 
* Build a classification tree on `t1` to predict `Survived` 
* Predict the `Survived` values in `t2` using your model.
* Save the accuracy of the model as `acc[i]` (this will store the accuracy from each split in the vector `acc`).

```{r}
Titanic_train <- train
Titanic_test <- test 


Titanic <- rbind(Titanic_train, Titanic_test)

acc <- rep(0, 50)
for (i in 1:50){
  index <- sample(1:dim(Titanic)[1], replace = FALSE, .6*dim(Titanic)[1] )
  t1 <- Titanic[ index, ]
  t2 <- Titanic[-index, ]

   # Add your code here
  class_tree <- rpart(as.factor(Survived)~., data = t1)
  classTreePrediction <- predict(class_tree, newdata = t2, type = "class")
  table1 <- table( t2$Survived, classTreePrediction)
  acc[i] <- sum(diag(table1))/sum(table1) # divide the accuracy by the toal 

}

acc
```


9) Create a histogram of the accuracy of your model below on different train/test
splits. What is the lowest and highest accuracy value that you observe?

```{r}
hist(acc)
#the lowest accuracy observed us 0.70 and the highest is 0.85 

```

Many predictive models have parameters that we can change, or _tune_, to get better predictions. For example, in $K$-nearest neighbors, we can change the number of neighbors $K$ to get different predictions for our data. The process of _parameter tuning_ is the process of selecting the values of these parameters that maximize accuracy for our particular data set. 

In order to tune the parameters, we need a good estimate of the accuracy of the model for each set of parameters. However, the example in the previous problems shows us that just splitting our data once can't really tell us how accurate our model is. For this reason, we use _cross validation_. This is essentially what you did in in the for loop above -- we split the data multiple times and average the accuracy. Then, we can choose the parameters for the model to maximize the mean accuracy. (Technically, $k$-fold cross validation is a little different, because we split the data into $k$ _folds_ and then build the model $k$ times, using each fold once as the test set and using all of the other data as the training set).

There are a lot of packages in R with functions for automatic parameter tuning. Probably the easiest function for tuning a random forest model is the `train` function from the `caret` package.

10) Install this package and uncomment the code below to load it. For tuning a random forest model, we are mostly interested in finding the best value of `mtry`, the number of variables used at each split when building the trees. 

Uncomment the rest of the code to obtain a tuned random forest model. The `train()` function will automatically perform cross-validation with the selected values of `mtry` and save the best model as `tuned_model`.


```{r message=FALSE, warning=FALSE, include=FALSE}
library(caret)
```


```{r}
# This function may take a little while to run!
tuned_model <- train(x = Titanic_train[ , 2:8], y = as.factor(Titanic_train$Survived)
                     , tuneGrid = data.frame(mtry = 1:7) 
                     , ntree = 250 # number of trees (passed to random forest)
                     , method = "rf")

tuned_model
```

11) You can manually `tune` the number of trees in your random forest (`ntree`) by trying out a few different values. When you have your best model, use it to predict who will survive in `Titanic_test` and report the accuracy.

```{r}
set.seed(3)
tuned_model <- train(x = Titanic_train[ , 2:8], y = as.factor(Titanic_train$Survived)
                     , tuneGrid = data.frame(mtry = 3) # must be between 1 : variables 
                     , ntree = 200 #340 # number of trees (passed to random forest)
                     , method = "rf")

tuned_model
#340    0.78955
#500     0.7719022
#200     0.7918933
#100     0.7850712

# I chose Mtry to be 3 and ntree to be 200 and this was the best model. It has an accuracy of  0.7803349, which is higher than the project presented above. 
```

Most likely, this is greater than the accuracy of your classification tree model from Problem 5. But maybe not. There is still some randomness involved and it is always possible that on a particular data set, one method will outperform another. Still, by tuning parameters and doing cross-validation, we give ourselves the best chance of creating an accurate model. 

