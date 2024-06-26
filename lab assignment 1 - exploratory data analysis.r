---
### title: "Lab 1: Exploratory Data Analysis"
---
Adapted from "Start teaching with R," created by R Pruim, N J Horton, and D Kaplan, 2013
and "Interactive and Dynamic Graphics for Data Analysis," by Dianne Cook and Deborah
F. Swayne.

# Introduction

One of the most important components of data science is exploratory data analysis.
One definition, which comes from [this article](https://towardsdatascience.com/exploratory-data-analysis-8fc1cb20fd15)
(though it's probably not the original source) explains exploratory data analysis as the following:


*"Exploratory Data Analysis refers to the critical process of performing initial 
investigations on data so as to discover patterns, spot anomalies, to test hypotheses and to check assumptions with the help of summary statistics and graphical representations."*


Before you begin your exploratory analysis, you may already have a particular 
question in mind. For example, you might work for an online retailer and want
to develop a model to predict which purchased items will be returned. Or, you 
may not have a particular question in mind. Instead, you might just be asked to 
look at browsing data for several customers and figure out some way to 
increase purchases. In either case, before you construct a fancy model, you
need to explore and understand your data. This is how you gain new insights 
and determine if an idea is worth pursuing.


## Understanding your data

Today we will be working with the `TIPS` dataset which is in the `regclass` package. The data in the `TIPS` dataset is information recorded by one waiter about each tip he received over a period of a few months working in a restaurant. We would like to use this data to address the question, _``What factors affect tipping behavior?"_ Please prepare your answers to the following questions using the Lab Submission Guidelines posted on our course Moodle page. 

1. Install the `regclass` package by either typing `install.packages("regclass")` in the console or by clicking "Tools > Install Packages" and selecting the package. 

Once you have done this, the R chunk below will load the package and dataset. Notice that a bunch of unnecessary output is included when you knit the document. Change the R chunk options so that this is not displayed.

Edit the code below to display only necessary output. You may need to Google to find the exact code you need! 
```{r message=FALSE, warning=FALSE, include=FALSE}
#install.packages("regclass")
library(regclass)
library(dplyr)
library(mosaic) 
library(Stat2Data)
#library(tidyverse)

data("TIPS")
```


When exploring a new dataset, it's important to first understand the basics. What format is our data in? What types of information are included in the dataset? How many observations are there? (These are rhetorical questions!)


2. In R, datasets are usually stored in a 2-dimensional structure called a *data frame*. You can get an idea of the structure of a dataset using the syntax `str(dataset)` and you can peak at the first few rows and columns with `head(dataset)`. Use these functions in the R chunk below to better understand the data. How many tips are recorded in this dataset? Which days of the week did the waiter work? (Answer these questions in the chunk below.)

```{r}
str(TIPS) #basic info about the data set 
head(TIPS, 10) #view the first few rows of the dataset 
count(TIPS)
summary(TIPS)
```
    
    From the TIPS dataset we can see that: 
      Tips are recorded in this dataset:
        244 tips are recorded in the data set
     Days of the week did the waiter works:
        Friday, Saturday, Sunday, Thursday 
    
Often, a dataset will come with a *code book* which gives more complete information about the structure of the data, the meaning of variables, and how the data were collected. In this case, most of the column names are pretty self explanatory.

Variable | Description
-------- | --------------------------------------------------------------------
`TipPercentage` | the gratuity, as a percentage of the bill
`Bill` | the cost of the meal in US dollars
`Tip` | the tip in US dollars
`Gender` | gender of the bill payer
`Smoker` | whether the party included smokers
`Weekday` | day of the week
`Time`  | time the bill was paid
`PartySize` | size of the party

3. Even though the column names are self-explanatory, we might have more questions about the data. For example, we might conjecture that people tip differently for breakfast and lunch, but our data only tells us if the bill was paid at "Day" or "Night." State another reasonable conjecture about a factor that might affect tipping behavior. What additional information would be helpful to explore that conjecture?

    On average do people tip differently based on the bill payers gender? 

```{r}
TIPS %>% group_by(Tip, Gender) %>% count()
tally(~Gender, data = TIPS) #number of male compared to female workers
```
        
        From this we gather that there are more males pay the bill compared to females 

# Numerical Summaries

Now we'd like to start looking closely at the dataset to develop some ideas about what factors might affect tipping. The basic descriptive statistics have obvious names, like `mean, median, sd, IQR, quantile`, etc. A quick shortcut function is `summary()`, which computes several numerical summaries all at once.We can apply these functions to an entire data frame or a specific column of the data fame.

4. Use some of these summaries to answer the following. How many smokers are in the dataset? How fancy do you think restaurant is? Is it possible to tell from this summary how many different shifts the waiter worked? Why or why not?

```{r}
summary(TIPS)
TIPS %>% group_by(Time)
```

      How many smokers are in the dataset? 
          There are 93 smokers in the data set 
      How fancy do you think restaurant is? 
          Not very the bill mean is around 20 dollars and the median is only 17. 
      Is it possible to tell from this summary how many different shifts the waiter worked?  Why or why not?
          We can tell what day and time the waiter worked, so I would say yes. For example on Sunday the waiter worked the night shift  
     

As we start to explore different questions, we might want to know things about interactions between variables. For instance, are tips larger during the day or at night? Or does gender or smoking status matter for how much people spend and how much they tip? You can calculate statistics within groups by including grouping variables and using `aggregate` like this:

```{r}
aggregate(Tip ~ Time, data = TIPS, FUN = median)
aggregate(cbind(Bill, TipPercentage) ~ Gender + Smoker, data = TIPS, FUN = mean)
```


The `~` (tilde) symbol appears in a lot of functions. In R, a **formula** is an expression involving `~` that provides slots for laying out how you want to relate variables: `y ~ x` means "$y$ versus $x$", "$y$ depends on $x$", "$y$ explained by" $x$, or "break down $y$ by $x$". In the top case above, you're saying "break Tip down by Time" or "perform this function on the Tip, conditioned on Time." 

5. Calculate the variance of the tip percentage broken down by day of the week. HINT: Use `FUN = var` in the aggregate function. Do you notice anything unusual? Explore the data and determine a possible cause for this.  

```{r}
aggregate(TipPercentage ~ Weekday, data = TIPS, FUN = var)
```


For categorical variables, we can create tables as follows:

```{r}
table(TIPS$Smoker, TIPS$Gender)
xtabs(~ Smoker + Gender, data = TIPS)
```


6. Which day of the week has the highest *percentage* of tables that are smokers?

```{r}
xtabs(~Smoker + Weekday, data = TIPS)
#proportion = yes /total ppl

```

      The higest percentage of smokers is on Thursday
      
## Graphical Summaries

Graphical summaries are a key tool in exploratory data analysis to help you understand your data.  They also help you communicate insights about your data to others. 

For example, we might want to display relationships about some of our categorical variables. So we could start by graphing different party sizes in our dataset. (if you are familiar with the ggplot2 package, you could also use pie charts and graphs from there, too!)

```{r fig.height=5, fig.width=5}
party_size_table <- table(TIPS$PartySize)
pie(x = party_size_table, labels = 1:6)
```

Or we could explore the question about the percentage of tables that are smokers on different days of the week visually (the command `ECHO = FALSE` makes it so code doesn't print). (You could also use ggplot2 here!) Warning: If you have errors running the legend function, it may be caused by showing your chunk output inline. Use the cog near the Knit button to select, "Chunk Output in Console" to have your console viewer show the barplot with a legend.  

```{r, echo = FALSE}
barplot(xtabs(~ Smoker + Weekday, data = TIPS), 
        main = "Party Size",
        names.arg = levels(TIPS$Weekday),
        xlab = "Party size",
        ylab = "Number", 
        col =  c("goldenrod", "cornflowerblue"))
legend("topright", c("Smoker", "Non-smoker"), fill = c("goldenrod", "cornflowerblue"))
```

We might summarize a numerical variable with a histogram. For example, here is a histogram of all of the tips in the dataset.

```{r fig.height=4, fig.width=5}
hist(TIPS$Tip, breaks = 100, main = "Tips, 100 bins")
```

7. Notice that there are a few "spikes" in the histogram above. What do you think is causing this?

    Saturdays Tips 

We can also summarize this numerical data broken down by one of the categorical variables using boxplots. 

```{r fig.height=4, fig.width=5}
boxplot(Tip ~ Weekday, data = TIPS, main = "Tips by Day of the Week",
   xlab = "Day of the Week", ylab = "Tips")
```


Or we can visualize the relationship between a lot of our numerical variables at once.

```{r}
pairs(~ Bill + TipPercentage + Tip, data = TIPS, main = "Scatterplot Matrix for TIPS")
```


8) Are there any clear linear relationships in the scatterplot above? What do you think is the explanation for these relationships? 

      There is not a clear relationship between any of the variables  There is a weak positive relationship between the Bill & Tip and Tip Percentage & Tip 

There are lots of other interesting graphical summaries available for interpreting and displaying data. In addition, there are lots of R packages that allow you to draw these graphics and to further customize some of the ones we discussed here. In your projects, you are welcome to use any of these that you think are appropriate. 


9) State a reasonable conjecture about tipping behavior that you would like to explore in the dataset. For example, you might think that people on dates tip more or that the waiter gets smaller tips when he has too many tables. Give *at least* one numerical and one graphical summary to explore this conjecture. Is there any evidence to support your conjecture? 

      On average people in groups tip more.Based on the results of the EDA, tables with less than 2 people give less tips compared to tables with more than 2 people.  
      
```{r}
TIPS %>% group_by(PartySize) %>% count() 
TIPS %>% group_by(Tip) %>% count()
TIPS %>% group_by(Tip) %>% count()
gf_point(Tip~ PartySize, data = TIPS)

```
      


It's okay if your conjecture is not supported or if you are just wrong--that's often the case in exploratory data analysis!


