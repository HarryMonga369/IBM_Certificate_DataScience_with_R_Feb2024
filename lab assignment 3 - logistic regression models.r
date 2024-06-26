---
### title: "Lab 3: Logistic Regression Models"
---

# Introduction

In the previous lab, we used a linear model to predict the value of a numerical response variable. However, often, we will want to predict the value of a _categorical_ (or _qualitative_) response variable $Y$. Predicting the category of a response variable is a process known as _classification_.

For our first classification method, we will use a type of _generalized linear model_ called a _logistic regression model_. If we have a _binomial random variable_, a random variable with just two possible outcomes (0 or 1), logistic regression gives us the probability that each outcome occurs based on some predictor variables $X$. Specifically, the form of the simple logistic regression equation with only one predictor variable is

$$P(Y = 1 | X)  = \dfrac{e^{\beta_0 + \beta_1X}}{1 + e^{\beta_0 + \beta_1X}}$$

In other words, this function gives us the probability that the outcome variable $Y$ belongs to category 1 given a particular value for the predictor variable $X$. Notice that the function above will always be between 0 and 1 for any values of $\beta_0$, $\beta_1$, and $X$, which is what allows us to interpret this as a probability. Of course, the probability that the outcome variable is equal to 0 is just $1 - P(Y = 1 | X)$. Rearranging the formula above, we have

$$\log \left (\dfrac{P(Y = 1 | X) }{1 - P(Y = 1 | X) } \right ) = \beta_0 + \beta_1X.$$

and we see why logistic regression is considered a type of generalized _linear_ regression. The quantity on the left is called the _log-odds_ or _logit_, and so logistic regression models the log-odds as a linear function of the predictor variable. The coefficients are chosen via the _maximum likelihood criterion_, which you can read more about in the book in Section 4.3.2 if you would like.


# Logistic Regression Lab 

In this lab, we will practice applying logistic regression by working again with the weather data. As in the prior lab, we will build models on the data up through 2013, and then will evaluate the performance of those models on newer (2014-2016) data.

In contrast to our previous linear regression models, which predicted temperature (a continuous variable), we will now attempt to predict whether or not a (month’s observed average high) temperature will be above normal. 


1) Just like in the Multiple Linear Regression lab, create a data frame in R called `WeatherData` consisting of the data from `MonthlyWeatherData`. Then, using the `ifelse()` function, create a vector that is 1 when the observed average temperature (`WeatherData$Observed`) for the month is above normal (`WeatherData$Normal`) and 0 when it is below normal (HINT: Use `?ifelse` in the Console if you need to see how `ifelse()` works.) Add the vector you created to the `WeatherData` data frame as a column called `Binomial`.
```{r}
WeatherData <- read.csv("/Users/sewii/Documents/CLASSES_Spring2022/Data325_AppliedDataScience/MonthlyWeatherData.csv", header=TRUE)
library(dplyr)


Binomial <- ifelse(WeatherData$Normal <= WeatherData$Observed, 1, 0 )
WeatherData <- cbind(WeatherData, Binomial)#above normal = 1 
WeatherData 

```


2) Add another column to the data set called `Deg_From_Norm` that is the number of degrees the temperature in the first seven days of the month is _above_ the normal temperature for that month. 
```{r}
Deg_From_Norm <-(WeatherData$First7D - WeatherData$Normal )
WeatherData <- cbind( WeatherData, Deg_From_Norm)
WeatherData
```


3) Split the data into `WeatherTrain` (the first 60 observations) and `WeatherTest` (the last 32 observations).
```{r}
WeatherTrain <- slice(WeatherData, n = 1:60)
WeatherTest <- slice_tail(WeatherData, n = 32 )
WeatherTrain
WeatherTest
```


4) Using the data from `WeatherTrain` and the `glm()` function, build a logistic regression model to predict whether or not a month will be above normal based only on the how many degrees the first seven days are above normal. NOTE: There are lots of models that are "generalized linear models." To use a logistic model, you must specify `family = binomial` in the `glm()` function.
```{r}
Weather_glm  <- glm( Binomial ~ Deg_From_Norm, data = WeatherTrain,family = "binomial")
Weather_glm
```


5) Use the `predict()` function to evaluate your model with integers from -20 to 20. NOTE: To use `predict()` the `newdata` must be a data frame where the columns have the same names as the those in the data frame you used to train your model.
```{r}
new_data <- data.frame(Deg_From_Norm = c(-20:20))  #why is is -20:20 
new_data['predicted'] <- predict(Weather_glm, new_data, type = "response")
new_data
```


6) Create a plot with the integers from -20 to 20 on the x-axis and the predicted probabilities on the y-axis. Give the plot some descriptive labels.
```{r}
plot(x = c(-20:20), y = new_data$predicted, xlab = "Degrees from the Normal Tempeture", ylab = "Predicted Probabilites of Weather", main = "Predicting the Difference in Weather from the Normal Tempeture")

```


7) Estimate the input that would be needed to give an output of 0.75. What does
this mean in the context of the model?

      In order for the weather to have a 0.75 or a 75% probabiliry of the weather the predicted tempeture must be be around 10 degrees from the normal tempeture. 
      
For a classification problem, we want a prediction of which class the outcome variable belongs to. In order to get a prediction from a binomial logistic regression model, we define a _threshold_. If the output
of the model is above the threshold, then we predict class 1, and if it is below the threshold we predict class 0. 

8) Using a threshold value of 0.5, obtain a vector of class predictions for the data set `WeatherTrain`. HINT: the `ifelse` function might be useful here.
```{r}
probabilityWeather <- predict(Weather_glm, WeatherTrain, type = "response")
classWeatherTrain <- ifelse(probabilityWeather  > 0.5, 1, 0)
classWeatherTrain
```


9) Use the `table()` function to construct a _confusion matrix_ for your predictions. What is the accuracy of your predictions? How many false positives (months incorrectly classified as above average) are there?
```{r}

#binomial = actual temps  
#classWeatherTrain = predicted temps
table(WeatherTrain$Binomial, classWeatherTrain)
37/60
```
 false positives : 12
 false negatives: 11
 mis-calssifacitions: 23 (bad)
 
          There is a 61.6% accuracy in this prediction. 

10) A threshold of 0.5 isn't necessarily the best choice for the threshold. Experiment with other values for the threshold to see if you can obtain any greater accuracy on the training set.
```{r}
classWeatherTrain2 <- ifelse(probabilityWeather  > 0.2, 1, 0)
table(WeatherTrain$Binomial, classWeatherTrain2)

classWeatherTrain3 <- ifelse(probabilityWeather  > 0.8, 1, 0)
table(WeatherTrain$Binomial, classWeatherTrain3)

classWeatherTrain4 <- ifelse(probabilityWeather  > 0.6, 1, 0)
table(WeatherTrain$Binomial, classWeatherTrain2)

classWeatherTrain5 <- ifelse(probabilityWeather  > 0.7, 1, 0)
table(WeatherTrain$Binomial, classWeatherTrain2)
```

 
 true positives : 11
 true negatives: 28
 miscalssifacitions: 11 (GOOD 0.6)
 

11) Regardless of the model used, there is at least one flawed assumption inherent in using the temperatures from a month’s first seven days to predict the temperature for the rest of the month. What is the issue? 
(Hint: think about seasons)

          Because the data is periodic, the tempetures are always going to alternate regularly in the summer and the winter. Making a prediction by the week will give us an in-acaurate picture of what the tempeture should look like during these seasons.   
