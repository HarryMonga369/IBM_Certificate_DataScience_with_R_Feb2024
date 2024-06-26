---
### title: "Lab 2: Multiple Linear Regression"
---

# Introduction

Linear regression is a simple method for predicting a quantitative response variable $Y$ on the basis of multiple predictors. That is, we assume that 

$$Y = \beta_0 + \beta_1 X_1 + \beta_2X_2 + \ldots + \beta_n X_n.$$

Based on this model, given values $x_1, \ldots, x_n$ for the predictors, we predict the response variable to be 

$$\hat y = \beta_0 + \beta_1 x_1 + \beta_2x_2 + \ldots + \beta_n x_n.$$
For the $i$th observation, the difference between the true response $y_i$ and our predicted response $\hat y_i$ is $e_i = y_i - \hat y_i$, which we call the $i$th _residual_. The coefficients of a linear model are usually chosen using the _least squares criterion_. That is, if we have $m$ observations on which to base our model, we choose the values of $\beta_0, \beta_1, \ldots, \beta_n$ to minimize the _Mean Squared Error_ (MSE), which is defined as $$(e_1^2 + e_2^2 + \ldots + e_m^2)/m.$$ 



There is a lot of statistical theory behind multiple linear regression which is explored in depth in other courses. The basis of this theory is the assumption that the true relationship between 
the predictors and the response variable is given by

$$Y = \beta_0 + \beta_1 X_1 + \beta_2X_2 + \ldots + \beta_n X_n + \epsilon$$

where $\epsilon$ is a mean-zero random error term. Based on these assumptions, there are a number of metrics for assessing which variables are important in our model, which we can learn from the `summary()` function in R. For the purposes of this course, we should know that the coefficients tell us how a one unit change in one of the predictors affects the response. We should also know that the p-values tell us how confident we can be that one of the coefficients is different from zero, where p-values close to 0 imply high confidence and p-values close to 1 imply low confidence.


# Multiple Linear Regression Lab 

In this lab, you will practice multiple linear regression by working with a simple weather data set. The data associated with this lab are in the file `MonthlyWeatherData.csv`, which contains
8+ years of monthly high temperature data (in degrees Fahrenheit) in Wooster, Ohio. The `Normal` column gives the normal average high for that month (based on the last decade). The `First7D` column contains the observed average high for only the first seven days of the month, and the `Observed` column contains the observed average high for the entire month. 

1) Create a data frame in R called `WeatherData` consisting of the data from 
`MonthlyWeatherData.csv`. (Import the dataset and make any necessary changes to display it accurately. The resulting dataset should have 92 rows and 5 columns.)

```{r include=FALSE}
WeatherData <- read.csv("/Users/sewii/Documents/CLASSES_Spring2022/Data325_AppliedDataScience/MonthlyWeatherData.csv", header=TRUE)
library(dplyr)
```

When doing empirical modeling, we should set aside a portion of our data to be used at the end in assessing the performance of our final model(s). Thus, we usually have a _training_ set of data we build our model on and a _test_ or _hold out_ set that we use to assess performance. With time-dependent data, we set aside the most-recent data (but would choose randomly if time was not a factor). (If you do not completely understand the idea of training and test sets, please reach out! This concept will serve as a basis for many (if not most) methods you'll be learning about this semester!)

2) For this lab, we will use only data up through 2013 as our training set. Create a data frame in R called `WeatherTrain` consisting of this data (the first 60 observations). Briefly explain why the `Normal` column is periodic, but the other columns are not.
????????????????????????
```{r}
WeatherTrain <- WeatherData %>% filter(Year <= 2013)
summary(WeatherTrain)
unique(WeatherData$Normal)
#unique(WeatherData$First7D)#compare to the values of Normal 
#unique(WeatherData$Observed)#compare to the values of Normal 
```
            
            Normal is periodic because the varible can only be one of speific valuse: 
                32.6 35.7 49.9 61.5 73.5 79.8 83.3 82.0 75.1 62.1 51.0 40.4
              The other varibales can be anything.

In predictive modeling, we often begin with a simple baseline model, to which we compare other models. Any more complicated model must outperform the baseline model to be considered useful.
In this case, there are two obvious baseline models we might use. The first would be to predict the final average high for the entire month from just the `Normal` value. The other would be to predict the final average high for the entire month from just the first seven day average (`First7D`). 

3) Which of the two models suggested do you think would be a better baseline model? Why? 

        I think the model that uses the Normal value would be better becasue it has more information. Using just the first 7days every month would only give us infomation about the first seven days of every month, while the Normal would give us a more realistic view of the data every month. 
        
4) Compute the mean squared error (MSE) associated with the two baseline models (just use the data in `WeatherTrain`). Save these as `mse_normal` and `mse_first`. Which seems like the better baseline model?

```{r}
mse_normal <- mean(summary(lm(Observed~Normal, data = WeatherTrain))$residuals^2)
mse_first <- mean(summary(lm(Observed~First7D, data = WeatherTrain))$residuals^2)
mse_normal
mse_first
```

      Mse_normal seems like the better base line model  
  
The above result does not mean the information on the first seven days is predictively useless. Rather, we need to pair that short-term data together with our prior expectations (in this case, the normal temperatures) to get a better prediction of each month’s final average temperature.

5) Build a two-input linear model for the final average high temperature, by using the syntax `lm(Y ~ X1 + X2, data)`. Save your model as `lmfit1`. What are the coefficients associated with each factor? Note that the other term is the intercept. (Remember, you can use `summary()` to call the coefficients of your model.)
????????????????

```{r}
lmfit1 <-lm(Observed ~ First7D + Normal, data = WeatherData)
summary(lmfit1)
```
          
      
          
          
6) One coefficient is substantially larger than the other. Given that each column has numbers that are approximately the same in magnitude, what does this tell us about the relative importance of the two factors? Does this agree with your analysis of the potential baseline models? (HINT: Compare with your answers from Question 4.)

      Normal has a greater than the coeifficent of First7D and a smaller p-value,it tells us that Normal is a better predictor of final tempeture highs compared to the first 7 days of the month   This agress with the analysis of potential baseline models. 

The phenomenon observed here is common in nearly all kinds of empirical modeling situations. As the sample size increases, the averages generally move toward expected levels. This phenomenon is called _regression to the mean_.


7) If you apply the `names()` function to the linear model you built, you will see that R stores a lot of information about the model. Access the `residuals` of the model and use them to find the MSE of your model (on the training data). Save this value as `mse1`. How much better is this model than the "normal" baseline model (by % reduction in MSE)?

```{r}
names(lmfit1)
mse1 <- mean(lmfit1$residuals^2)
mse_normal- mse1
```

      This model is much better than the the normal baseline model by 3.200441% reduction in MSE. 
      
We can also build models using _categorical_ predictors instead of just numerical predictors. 

8) Build a linear model called `lmfit2` to predict `Observed` using only the `First7D` and `Month` columns. And then use `summary()` function to look at the regression coefficients. 

```{r}
lmfit2 <- lm(Observed ~ First7D + Month, data = WeatherData)
summary(lmfit2)
```

9) Notice that there is a coefficient listed for eleven months. When you build a linear model with a categorical variable, R will introduce a _baseline_ which serves as a category of comparison for the other categories. The baseline is the one month that is not listed in the summary output. Which month serves as a baseline?
          
          April is the baseline. 
          
10) Compute the MSE of this new model and save it as `mse2`. Is this better or worse than the MSE for `lmfit1`? Why do you think this is?

```{r}
mse2 <- mean(lmfit2$residuals^2)
mse2
```
          
          This model is worse by about 5%. This could be because there are more coeiffiecnts and some of them are not significant additions to the model. 
          
Of course, the best model is not necessarily the one that fits our training data the best. Such a model may _overfit_ the data, and we actually want a model that gives us the best predictions when applied to our test set. 

11) Create a data frame in R called `WeatherTest` consisting of the most recent 32 observations of `WeatherData`. This will be your test set. (Make sure there is no overlap with `WeatherTrain`!)

```{r}
WeatherTest <- WeatherData %>% arrange(desc(Year))
WeatherTest <- slice(WeatherTest, 1:32)
```


12) Compute the MSE of the normal base model and the two linear models applied to the *test* set. To get predictions from the linear models, use the syntax `predict(model, newdata)` where `newdata` is the data you want predictions for. Which of the three models performs best? Why do you think this is in terms of how complicated the models are?

```{r}
#mse_normal_Test <- mean(summary(lm(Observed~Normal, data = WeatherTest))$residuals^2)
#mse1_Test <- mean(lmfit1$residuals^2)
#mse2_Test <- mean(lmfit2$residuals^2)

#mse_normal_Test
#mse1_Test
#mse2_Test



p1 <- predict(lm(Observed ~ First7D + Normal, data = WeatherTrain), WeatherTest) #lmfit1 model  
p2 <- predict(lm(Observed ~ First7D + Month, data = WeatherTrain), WeatherTest) #lmfit2 model 

mean1 = sum((p1 - WeatherTest$Observed)^2)/32
mean2 = sum((p2 - WeatherTest$Observed)^2)/32
p1
p2
 mean1
 mean2

#predict(lm(Observed~Normal, data = WeatherTest), WeatherTest) #normal model 
#predict(lm(Observed~Normal, data = WeatherTest), WeatherTest, interval = "confidence") #normal model 
```

      lmfit1 or the first linear model is the best performs the best compared to the other two models. Despite the second model having the best MSE, the confidence intervals are larger compred to the first linear model which has the smallest confidence intervals and MSE. 
