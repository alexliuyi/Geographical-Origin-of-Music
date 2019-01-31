# Geographical-Origin-of-Music

1. Purpose of the project
This problem is about using 68 features to predict the latitude and longitude for its location. All the 68 predict variables and 2 response variables are continuous variables. I would like to use regression model to predict these 2 variables and evaluate our model by measuring the mean of the Euclidean distance between the true location and the predicted location. I want to find the smallest mean of Euclidean distance.

2. Data pre-processing and checking assumptions
Before making any analysis, I will divide this dataset into training data and testing. For the training dataset, I will use random sample (seed 1986) to choose 400 observations, the rest 250 observations will be used as testing data. Because there are 2 response variables here, I would like to fit separate models for these 2 variables, and then calculate the Euclidean distance by using predicted values of each model. 
I made three assumptions:
    1. These 2 response variables have linear relationship with predict variables 
    2. These 2 response variables have constant variance
    3. There is no high influence outlier
To check these assumptions, I first fitted separate full linear regression models on each response variables. I found from the plot of residuals against response that the predicted variables seem have linear relationship with response variables. Then, I can assume the variance constant and on high influence outlier assumption hold. 
 
3. Model selection
I tried 12 models, which didn’t include spline model and GAM model, because these two kind of models did not work well for high dimension problem. After trying all the possible models, I got the test errors for each model as follow table. From the results, I found that the CART model with bagging had the smallest test error. 

Model	Full Linear Model	Best Subset Model	Ridge Model	Lasso Model	PCR Model	PLS Model	CART Model	CART with Pruning	CART with Bagging	CART with Boosting	Random Forest
Model	MARS Model
Test Error	41.52	41.36	41.59	41.41	41.68	40.97	50.94	47.62	40.5	41.82	41.16	60.5

4. Final model description
I choose our final model as the CART model with bagging. I use all the 68 features to fit bagging model. 
   
For the latitude the important features are feature 46 and feature 41 and feature 44.
For the longitude the important features are feature 2 and feature 46 and feature 49.

5. Conclusion
The Euclidean distance is 40.5, so I have the smallest test error of Euclidean distance. Although bagging typically improves the utility of a tree-base model for prediction relative to a single tree, but it will reduce the interpretability. That is, when I average over many different trees, the variable splits can change substantially, preventing interpretation. Thus, it is not clear which variables are important to the Euclidean distance. But I can conclude that feature 46 is the important feature for latitude and longitude.
