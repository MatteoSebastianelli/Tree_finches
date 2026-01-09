# R 4.4.3

#load packages
library(mclust)
library(mvtnorm)
library(ellipse)
library(clustvarsel)
library(readxl)

#### 1) Import data ####
d<-as.data.frame(read_xlsx('./camarhynchus_biometries_museum_4pca_NMMs.xlsx'))
dim(d)
head(d)
summary(d)

#### 2) Transform data ####
#perform logarithmic transformation of the six traits of interest:
#Wing, Tail, Blength, Bdepth, Bwidth, Tarsus
morpho.data <- (d[,c(10:12,16,17)])
#change column names and examine resulting data frame
colnames(morpho.data)
dim(morpho.data)
summary(morpho.data)

#### 3) PCA on morphometrics ####
# Principal component analysis 
# perform PCA using the covariance matrix of the logarithmic
#transformation of the six traits of interest (Wing, Blength,Bdepth, Bwidth, Tarsus) 
morpho.data.pca <- prcomp(morpho.data, center = T, scale. = T) #PCA 

#examine PCA results
#get the list of attributes of the R object containing the PCA results
attributes(morpho.data.pca)
morpho.data.pca$scale
morpho.data.pca$center
#variance explained by each principal component: 
summary(morpho.data.pca)
#summary of the principal components: 
summary(morpho.data.pca$x)
#examine the "rotation" element of the R object containing the PCA results,
#it shows the coefficients (or "loadings") of each trait on each principal component
morpho.data.pca$rotation

#### 4) VARIABLE SELECTION - Data analysis using Gaussian mixture models on morphological axes defined by PCA on a covariance matrix, and using variable selection. ####
## BACKWARD VARIABLE SELECTION 
# starts from the model with all the available variables and at each step of the algorithm removes/adds a variable until the stopping criterion is satisfied
#backward variable selection using the PCA of the logarithmic transformation of the 5 traits of interest
#(Wing, Blength, Bdepth, Bwidth and Tarsus), and examine results:
mclust.options() #check Mclust options
OptMc <- mclust.options() #save default
mclust.options(hcUse="VARS") #change default as needed
# I set G to 16 because we can have a max of 16 morphological groups (each species in each island)
morpho.data.pca.varsel.back <- clustvarsel(morpho.data.pca$x, G=1:16, search=c("greedy"), direction = c("backward"))
attributes(morpho.data.pca.varsel.back)
summary(morpho.data.pca.varsel.back)
morpho.data.pca.varsel.back$subset # it selected pc5 but not pc4

morpho.data.pca.varsel.back$steps.info

morpho.data.pca.varsel.back$search
morpho.data.pca.varsel.back$direction

# FORWARD VARIABLE SELECTION
# starts from the empty model and at each step of the algorithm adds/removes a variable until the stopping criterion is satisfied
#forward variable selection using logarithmic transformation of the 5 traits of interest
#(Wing, Blength, Bdepth, Bwidth and Tarsus), and examine results:
mclust.options() #check Mclust options
#OptMc <- mclust.options() #save default
mclust.options(hcUse="VARS") #change default as needed
# I set G to 16 because we can have a max of 16 morphological groups
morpho.data.pca.varsel.for <- clustvarsel(morpho.data.pca$x, G=1:16, search=c("greedy"), direction = c("forward")) 
attributes(morpho.data.pca.varsel.for)
summary(morpho.data.pca.varsel.for)
morpho.data.pca.varsel.for$subset
morpho.data.pca.varsel.for$steps.info
morpho.data.pca.varsel.for$direction

#### FINAL ANALYSIS ####
#based on the results above, carry out the Mclust analysis using four characters:
#PC2, PC1, PC3 and PC5:
mclust.options() #check Mclust options and make sure hcUSE="VARS", otherwise change it.

#Run mclust analysis
Mcluster.morpho.data.pca.subset <- Mclust(morpho.data.pca$x[,c(1,2,3,5)], G=1:16)
summary(Mcluster.morpho.data.pca.subset)

#help(mclustModelNames) #in this help page there is information about model names
plot(Mcluster.morpho.data.pca.subset)
summary(Mcluster.morpho.data.pca.subset$data)
dim(Mcluster.morpho.data.pca.subset$data)

# best model
Mcluster.morpho.data.pca.subset$modelName# EEE - ellipsoidal, equal shape and orientation
Mcluster.morpho.data.pca.subset$G # morphological groups
Mcluster.morpho.data.pca.subset$BIC # Check selected models

#extract BIC values for the best model conditional on the number of groups
BIC.Best.Model.Per.G <- apply(Mcluster.morpho.data.pca.subset$BIC, 1, max, na.rm=T)

#### Add selected principal components and morphological group assignments to original dataset for plotting
d$pc1<-(morpho.data.pca$x[,1])
d$pc2<-(morpho.data.pca$x[,2])
d$pc3<-(morpho.data.pca$x[,3])
d$pc5<-(morpho.data.pca$x[,5])
d$morpho_group<-Mcluster.morpho.data.pca.subset$classification

write_xlsx(d, "./camarhynchus_biometries_museum_4pca_NMMs_output.xlsx")


