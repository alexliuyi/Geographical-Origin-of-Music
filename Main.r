############# Reading Data #############
music <- read.table('project.dat')
for(i in 1:70)
{
  music[,paste("feature",i,sep="")] <- music[,paste("V",i,sep="")]
  music[,paste("V",i,sep="")] <- NULL
}
colnames(music)[colnames(music)=="feature69"] <- "lat"
colnames(music)[colnames(music)=="feature70"] <- "long"

############# Creat a Training and Test Data #############
set.seed(1986)
train <- sample(650,400,replace=F)
train.music <- music[train,]
test.music  <- music[-train,]

############# Check Assumptions #############
lat.full <- glm(lat~.-long,data=train.music)
long.full <- glm(long~.-lat,data=train.music)
par(mfrow=c(1,2))
plot(train.music$lat,lat.full$residuals,xlab='Latitude',ylab='Residuals')
plot(train.music$long,long.full$residuals,xlab='Longitude',ylab='Residuals')

predict.lat.full <- predict(lat.full,test.music)
predict.long.full <- predict(long.full,test.music)
error.full.lat <- (test.music$lat-predict.lat.full)^2
error.full.long <- (test.music$long-predict.long.full)^2

music.distance.full <- mean(sqrt(error.full.lat + error.full.long))
round(music.distance.full,2)
### [1] 41.52


############# Stepwise Variables Selection #############
best.lat <- step(lat.full)
best.long <- step(long.full)
predict.lat.best <- predict(best.lat,test.music)
predict.long.best <- predict(best.long,test.music)
error.best.lat <- (test.music$lat-predict.lat.best)^2
error.best.long <- (test.music$long-predict.long.best)^2

music.distance.best <- mean(sqrt(error.best.lat + error.best.long))
round(music.distance.best,2)
### [1] 41.36 ### Best till now

############# Ridge #############
library(glmnet)
train.x.lat <- model.matrix(lat~., train.music)[,-c(69,70)]
train.y.lat <- train.music$lat
test.x.lat <- model.matrix(lat~., test.music)[,-c(69,70)]
test.y.lat <- test.music$lat

train.x.long <- model.matrix(long~., train.music)[,-c(69,70)]
train.y.long <- train.music$long
test.x.long <- model.matrix(long~., test.music)[,-c(69,70)]
test.y.long <- test.music$long

set.seed(1986)
grid <- 10 ^ seq(10, -2, length=100)
cv.ridge.music.lat <- cv.glmnet(train.x.lat, train.y.lat, lambda=grid, alpha=0)
bestlam.lat.ridge <- cv.ridge.music.lat$lambda.min
music.lat.ridge.pred <- predict(cv.ridge.music.lat, newx=test.x.lat, s=bestlam.lat.ridge)
error.lat.ridge <- (test.music$lat-music.lat.ridge.pred)^2

set.seed(1986)
cv.ridge.music.long <- cv.glmnet(train.x.long, train.y.long, lambda=grid, alpha=0)
bestlam.long.ridge <- cv.ridge.music.long$lambda.min
music.long.ridge.pred <- predict(cv.ridge.music.long, newx=test.x.long, s=bestlam.long.ridge)
error.long.ridge <- (test.music$long-music.long.ridge.pred)^2

music.distance.ridge <- mean(sqrt(error.lat.ridge+error.long.ridge))
round(music.distance.ridge,2)
### [1] 41.59

############# Lasso #############
set.seed(1986)
grid <- 10 ^ seq(10, -2, length=100)
cv.lasso.lat <- cv.glmnet(train.x.lat, train.y.lat, lambda=grid, alpha=1)
bestlam.lat.lasso <- cv.lasso.lat$lambda.min
lat.lasso.pred <- predict(cv.lasso.lat, newx=test.x.lat, s=bestlam.lat.lasso)
error.lat.lasso <- (test.music$lat-lat.lasso.pred)^2

set.seed(1986)
cv.lasso.long <- cv.glmnet(train.x.long, train.y.long, lambda=grid, alpha=1)
bestlam.long.lasso <- cv.lasso.long$lambda.min
long.lasso.pred <- predict(cv.lasso.long, newx=test.x.long, s=bestlam.long.lasso)
error.long.lasso <- (test.music$long-long.lasso.pred)^2

music.distance.lasso <- mean(sqrt(error.lat.lasso+error.long.lasso))
round(music.distance.lasso,2)
### [1] 41.41

############# PCR #############
library(pls)
set.seed(1986)
pcr.lat <- pcr(lat~.-long, data=train.music, sacle=T, validation='CV')
validationplot(pcr.lat, val.type='MSEP')
lat.pcr.pred <- predict(pcr.lat, test.music, ncomp=21)
error.lat.pcr <-(test.music$lat-lat.pcr.pred)^2

set.seed(1986)
pcr.long <- pcr(long~.-lat, data=train.music, sacle=T, validation='CV')
validationplot(pcr.long, val.type='MSEP')
long.pcr.pred <- predict(pcr.long, test.music, ncomp=53)
error.long.pcr <- (test.music$long-long.pcr.pred)^2

music.distance.pcr <- mean(sqrt(error.lat.pcr+error.long.pcr))
round(music.distance.pcr,2)
### [1] 41.16

############# PLS #############
set.seed(1986)
pls.lat <- plsr(lat~.-long, data=train.music, sacle=T, validation='CV')
validationplot(pls.lat, val.type='MSEP')
lat.pls.pred <- predict(pls.lat, test.music, ncomp=3)
error.lat.pls <-(test.music$lat-lat.pls.pred)^2

set.seed(1986)
pls.long <- plsr(long~.-lat, data=train.music, sacle=T, validation='CV')
validationplot(pls.long, val.type='MSEP')
long.pls.pred <- predict(pls.long, test.music, ncomp=6)
error.long.pls <- (test.music$long-long.pls.pred)^2

music.distance.pls <- mean(sqrt(error.lat.pls+error.long.pls))
round(music.distance.pls,2)
### [1] 40.74 ### Best till now 

############# CART #############
library(tree)
tree.lat <- tree(lat~.-long, data=train.music)
summary(tree.lat)
plot(tree.lat)
text(tree.lat,pretty=0,cex=0.5)
lat.tree.pred <- predict(tree.lat, test.music) 
error.lat.tree <- (test.music$lat - lat.tree.pred)^2

tree.long <- tree(long~.-lat, data=train.music)
summary(tree.long)
plot(tree.long)
text(tree.long,pretty=0,cex=0.5)
long.tree.pred <- predict(tree.long, test.music) 
error.long.tree <- (test.music$long - lat.tree.pred)^2

music.distance.tree <- mean(sqrt(error.lat.tree + error.long.tree))
round(music.distance.tree,2)
### [1] 50.94

############# Pruning the CART #############
set.seed(1986)
cv.lat.tree <- cv.tree(tree.lat, FUN=prune.tree)
plot(cv.lat.tree$size, cv.lat.tree$dev, type='b')
plot(cv.lat.tree$k, cv.lat.tree$dev, type='b')
prune.lat.tree <- prune.tree(tree.lat,best=2,k=5800)
lat.prune.tree.pred <- predict(prune.lat.tree, test.music) 
error.lat.prune.tree <- (test.music$lat - lat.prune.tree.pred)^2

set.seed(1986)
cv.long.tree <- cv.tree(tree.long, FUN=prune.tree)
plot(cv.long.tree$size, cv.long.tree$dev, type='b')
plot(cv.long.tree$k, cv.long.tree$dev, type='b')
prune.long.tree <- prune.tree(tree.long,best=2,k=50000)
long.prune.tree.pred <- predict(prune.long.tree, test.music) 
error.long.prune.tree <- (test.music$long - long.prune.tree.pred)^2

music.distance.prune.tree <- mean(sqrt(error.lat.prune.tree+error.long.prune.tree))
round(music.distance.prune.tree,2)
### [1] 47.62

############# CART with Bagging #############
library(randomForest)
set.seed(1986)
bag.lat <- randomForest(lat~.-long,data=train.music,mtry=68,importance=T)
lat.bag.pred <- predict(bag.lat, test.music) 
error.lat.bag <- (test.music$lat - lat.bag.pred)^2
importance(bag.lat)

set.seed(1986)
bag.long <- randomForest(long~.-lat,data=train.music,mtry=68,importance=T)
long.bag.pred <- predict(bag.long, test.music) 
error.long.bag <- (test.music$long - long.bag.pred)^2
importance(bag.long)

varImpPlot(bag.lat)
varImpPlot(bag.long)
music.distance.bag <- mean(sqrt(error.lat.bag + error.long.bag))
round(music.distance.bag,3)
### [1] 40.5 ### Best till now

############# CART with Boosting #############
library(gbm)
set.seed(1986)
lat.boost <- gbm(lat~.-long,data=train.music,distribution='gaussian',cv.folds=10, n.trees=20000,interaction.depth=1)
ntrees.lat <- which.min(lat.boost$cv.error)
lat.boost.pred <- predict(lat.boost, test.music, n.trees=ntrees.lat,interaction.depth=1) 
error.lat.boost <- (test.music$lat - lat.boost.pred)^2
set.seed(1986)
long.boost <- gbm(long~.-lat,data=train.music,distribution='gaussian', cv.folds=10, n.trees=22000,interaction.depth=1)
ntrees.long <- which.min(long.boost$cv.error)
long.boost.pred <- predict(long.boost, test.music, n.trees=ntrees.long,interaction.depth=1) 
error.long.boost <- (test.music$long - long.boost.pred)^2
music.distance.boost <- mean(sqrt(error.lat.boost + error.long.boost))
round(music.distance.boost,2)
### [1] 41.82

############# Random Forest #############
library(randomForest)
set.seed(1986)
rf.lat <- randomForest(lat~.-long,data=train.music,importance=T)
lat.rf.pred <- predict(rf.lat, test.music) 
error.lat.rf <- (test.music$lat - lat.rf.pred)^2
importance(rf.lat)

set.seed(1986)
rf.long <- randomForest(long~.-lat,data=train.music,importance=T)
long.rf.pred <- predict(rf.long, test.music) 
error.long.rf <- (test.music$long - long.rf.pred)^2
importance(rf.long)

music.distance.rf <- mean(sqrt(error.lat.rf + error.long.rf))
round(music.distance.rf,2)
### [1] 41.1 

############# MARS #############
library(earth)
set.seed(1986)
mars.lat <- earth(lat~.-long,data=train.music, pmethod = 'cv', nfold=5)
lat.mars.pred <- predict(mars.lat, test.music) 
error.lat.mars <- (test.music$long - lat.mars.pred)^2
set.seed(1986)
mars.long <- earth(long~.-lat,data=train.music,pmethod = 'cv', nfold=5)
long.mars.pred <- predict(mars.long, test.music) 
error.long.mars <- (test.music$long - long.mars.pred)^2

music.distance.mars <- mean(sqrt(error.lat.mars + error.long.mars))
round(music.distance.mars,2)
### [1] 60.05

############# Test for new data by using final model #############
music.test <- read.table('project.test.dat')          ##### Read your data
for(i in 1:70)
{
  music.test[,paste("feature",i,sep="")] <- music.test[,paste("V",i,sep="")]
  music.test[,paste("V",i,sep="")] <- NULL
}
colnames(music.test)[colnames(music.test)=="feature69"] <- "lat"
colnames(music.test)[colnames(music.test)=="feature70"] <- "long"

library(randomForest)

### testing
set.seed(1)
final.lat <- randomForest(lat~.-long,data=train.music,mtry=68,importance=T)   ### Build lat model
lat.final.pred <- predict(final.lat, music.test) 
error.lat.final <- (music.test$lat - lat.final.pred)^2
set.seed(1)
final.long <- randomForest(long~.-lat,data=train.music,mtry=68,importance=T)   ### Build long model
long.final.pred <- predict(final.long, music.test) 
error.long.final <- (music.test$long - long.final.pred)^2
music.distance.final <- mean(sqrt(error.lat.final + error.long.final))
round(music.distance.final,3)   ### Show Eudlidean distance
### [1] 36.631
