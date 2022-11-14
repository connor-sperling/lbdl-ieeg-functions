library(RGenData)
library(factoextra)
library(psych)
library(R.matlab)
library(proxy)
library(reshape2)
library(ggplot2)
library(pvclust)

subj = 'pt6'
study = 'DA_GEN'
lock = 'stim'
band = 'LFP'
location = 'Marseille'
subjs_dir = sprintf('/Volumes/LBDL_Extern/bdl-raw/iEEG_%s/Subjs/',location)
dpth = sprintf('%s/%s/analysis/%s/bipolar/%s/ALL/data/%s/',subjs_dir,subj,study,lock,band)
data = readMat(sprintf('%s/%s_mean_sig_data.mat',dpth,subj))
#active_elecs = as.vector(data$elecs.dat)
data = data$elecs.dat
a=EFACompData(data, f.max=10, graph=TRUE)

####

N = 10
fit = principal(data, nfactors = N, rotate='varimax') #calculate PCA with rotation
df_loadings = cbind(data.frame(unclass(fit$loadings)))

#get components
scores = as.data.frame(cbind(fit$scores, 1:nrow(fit$scores))) #time x n_components 

#rename column to 'time'
timename = tail(colnames(scores),n=1) #V5
names(scores)[names(scores)==timename] <- "time" 

scores.long = melt(scores, id.vars = "time")
#scores2.long = melt(scores[,c(4:5,N+1)], id.vars = "time")
p <- ggplot(data=scores.long, aes(x = time, y = value)) + geom_line(aes(colour=variable),size=.8) + xlab('time')+ scale_colour_hue(l=40) + theme_bw(base_size = 12) + theme_classic()+ scale_size_discrete()
p + coord_fixed(ratio = 300)


#ggsave(
#  '~/Documents/research/thesis/meeting7-9examples/LFP_PC2.png',
#  plot = last_plot()
#)

d = dist(df_loadings, method = "correlation")
fit <- hclust(d, method="complete") 
plot(fit) # display dendogram
groups <- cutree(fit, k=4) # cut tree into 5 clusters
# draw dendogram with red borders around the 5 clusters 
rect.hclust(fit, k=4, border="red")


#res.pca <- prcomp(data, scale = TRUE)
#fviz_eig(res.pca)

#res.pca$rotation
