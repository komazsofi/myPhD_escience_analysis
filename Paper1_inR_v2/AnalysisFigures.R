"
@author: Zsofia Koma, UvA
Aim: Analyse the results of the classification - feature importance and response curves
"

library(randomForest)
library(caret)

library(ggplot2)
library(gridExtra)
library(ggrepel)
library(grid)

library(reshape2)
library(dplyr)

library(sjPlot)
library(corrplot)

#source("D:/Koma/GitHub/myPhD_escience_analysis/Paper1_inR_v2/Function_Classification.R")
source("D:/GitHub/eEcoLiDAR/myPhD_escience_analysis/Paper1_inR_v2/Function_Classification.R")
#source("C:/Koma/Github/komazsofi/myPhD_escience_analysis/Paper1_inR_v2/Function_Classification.R")

# Set global variables
#setwd("D:/Koma/Paper1_v2/Run4_2019April/")
setwd("D:/Sync/_Amsterdam/02_Paper1_ReedbedStructure_onlyALS/3_Dataprocessing/Results_17April/")
#setwd("C:/Koma/Sync/_Amsterdam/02_Paper1_ReedbedStructure_onlyALS/3_Dataprocessing/Results_09April/")

# Import

#Feature tables
featuretable_l1=read.csv("featuretable_level1_b2o5.csv")
featuretable_l2=read.csv("featuretable_level2_b2o5.csv")
featuretable_l3=read.csv("featuretable_level3_b2o5.csv")

names(featuretable_l1) <- c("C_puls","C_can","S_curv","S_lin","S_plan","S_sph","S_ani","VV_sd","VV_var","VV_skew","VV_kurt","VV_cr","VV_vdr","VV_simp","VV_shan","HV_rough","HV_tpi","HV_tri",
                            "HV_sd","HV_var","H_max","H_mean","H_med","H_25p","H_75p","H_90p","layer")

names(featuretable_l2) <- c("C_puls","C_can","S_curv","S_lin","S_plan","S_sph","S_ani","VV_sd","VV_var","VV_skew","VV_kurt","VV_cr","VV_vdr","VV_simp","VV_shan","HV_rough","HV_tpi","HV_tri",
                            "HV_sd","HV_var","H_max","H_mean","H_med","H_25p","H_75p","H_90p","layer")

names(featuretable_l3) <- c("C_puls","C_can","S_curv","3S_lin","S_plan","S_sph","S_ani","VV_sd","VV_var","VV_skew","VV_kurt","VV_cr","VV_vdr","VV_simp","VV_shan","HV_rough","HV_tpi","HV_tri",
                            "HV_sd","HV_var","H_max","H_mean","H_med","H_25p","H_75p","H_90p","layer")

featuretable_l1_foranal=read.csv("featuretable_b2o5_wgr_whgr.csv")
featuretable_l1_foranal=featuretable_l1_foranal[featuretable_l1_foranal$layer==2,]

featuretable_l1_a=featuretable_l1_foranal[ ,c(1:26)]
featuretable_l1_b=featuretable_l1_foranal[ ,c(27:52)]

names(featuretable_l1_a) <- c("C_puls","C_can","S_curv","S_lin","S_plan","S_sph","S_ani","VV_sd","VV_var","VV_skew","VV_kurt","VV_cr","VV_vdr","VV_simp","VV_shan","HV_rough","HV_tpi","HV_tri",
                              "HV_sd","HV_var","H_max","H_mean","H_med","H_25p","H_75p","H_90p")

names(featuretable_l1_b) <- c("C_puls","C_can","S_curv","S_lin","S_plan","S_sph","S_ani","VV_sd","VV_var","VV_skew","VV_kurt","VV_cr","VV_vdr","VV_simp","VV_shan","HV_rough","HV_tpi","HV_tri",
                              "HV_sd","HV_var","H_max","H_mean","H_med","H_25p","H_75p","H_90p")

#RFE
load("rfe_l1.RData")
load("rfe_l2.RData")
load("rfe_l3.RData")

# Conf matrix
load("conf_m_l1.RData")
load("conf_m_l2.RData")
load("conf_m_l3.RData")

# ModelFit
load("modelFit_l1.RData")
load("modelFit_l2.RData")
load("modelFit_l3.RData")

# Way of calculating lidar metrics (boxplots)
vegetation_wgr=featuretable_l1_a[ ,c(1:2)]
vegetation_whgr=featuretable_l1_b[,c(1:2)]

vegetation_wgr_f=melt(vegetation_wgr)
vegetation_whgr_f=melt(vegetation_whgr)

vegetation_wgr_f$class <-1
vegetation_whgr_f$class <-2

vegetation_var=rbind(vegetation_wgr_f,vegetation_whgr_f)

p1=ggplot(data = vegetation_var, aes(x=variable, y=value,fill=factor(class))) + geom_boxplot(show.legend = FALSE)+
  scale_fill_manual(values = c("1" = "coral1", "2" = "cyan2"),name="Calculation type",labels=c("With ground","Without ground")) +
  xlab("Feature class: Cover") + ylab("Ratio[%]") +
  theme_bw(base_size = 17)

vegetation_wgr_h=featuretable_l1_a[ ,c(3:7)]
vegetation_whgr_h=featuretable_l1_b[,c(3:7)]

vegetation_wgr_f_h=melt(vegetation_wgr_h)
vegetation_whgr_f_h=melt(vegetation_whgr_h)

vegetation_wgr_f_h$class <-1
vegetation_whgr_f_h$class <-2

vegetation_var_h=rbind(vegetation_wgr_f_h,vegetation_whgr_f_h)

p2=ggplot(data = vegetation_var_h, aes(x=variable, y=value,fill=factor(class))) + geom_boxplot(show.legend = FALSE)+
  scale_fill_manual(values = c("1" = "coral1", "2" = "cyan2"),name="Calculation type",labels=c("With ground","Without ground")) +
  xlab("Feature class: 3D shape") + ylab("Ratio between eigenvalues") +
  theme_bw(base_size = 17)

vegetation_wgr_h=featuretable_l1_a[ ,c(8:11)]
vegetation_whgr_h=featuretable_l1_b[,c(8:11)]

vegetation_wgr_f_h=melt(vegetation_wgr_h)
vegetation_whgr_f_h=melt(vegetation_whgr_h)

vegetation_wgr_f_h$class <-1
vegetation_whgr_f_h$class <-2

vegetation_var_h=rbind(vegetation_wgr_f_h,vegetation_whgr_f_h)

p3a=ggplot(data = vegetation_var_h, aes(x=variable, y=value,fill=factor(class))) + geom_boxplot(show.legend = FALSE)+
  scale_fill_manual(values = c("1" = "coral1", "2" = "cyan2"),name="Calculation type",labels=c("With ground","Without ground")) +
  xlab("Feature class: Vertical variability") + ylab("Variability [m]") +
  theme_bw(base_size = 17)

vegetation_wgr_h=featuretable_l1_a[ ,c(12:15)]
vegetation_whgr_h=featuretable_l1_b[,c(12:15)]

vegetation_wgr_f_h=melt(vegetation_wgr_h)
vegetation_whgr_f_h=melt(vegetation_whgr_h)

vegetation_wgr_f_h$class <-1
vegetation_whgr_f_h$class <-2

vegetation_var_h=rbind(vegetation_wgr_f_h,vegetation_whgr_f_h)

p3b=ggplot(data = vegetation_var_h, aes(x=variable, y=value,fill=factor(class))) + geom_boxplot(show.legend = FALSE)+
  scale_fill_manual(values = c("1" = "coral1", "2" = "cyan2"),name="Calculation type",labels=c("With ground","Without ground")) +
  xlab("Feature class: Vertical variability") + ylab("Variability [m]") +
  theme_bw(base_size = 17)

vegetation_wgr_h=featuretable_l1_a[ ,c(16:20)]
vegetation_whgr_h=featuretable_l1_b[,c(16:20)]

vegetation_wgr_f_h=melt(vegetation_wgr_h)
vegetation_whgr_f_h=melt(vegetation_whgr_h)

vegetation_wgr_f_h$class <-1
vegetation_whgr_f_h$class <-2

vegetation_var_h=rbind(vegetation_wgr_f_h,vegetation_whgr_f_h)

p4=ggplot(data = vegetation_var_h, aes(x=variable, y=value,fill=factor(class))) + geom_boxplot(show.legend = FALSE)+
  scale_fill_manual(values = c("1" = "coral1", "2" = "cyan2"),name="Calculation type",labels=c("With ground","Without ground")) +
  xlab("Feature class: Horizontal variability") + ylab("Variability [m]") +
  theme_bw(base_size = 17)

vegetation_wgr_h=featuretable_l1_a[ ,c(21:26)]
vegetation_whgr_h=featuretable_l1_b[,c(21:26)]

vegetation_wgr_f_h=melt(vegetation_wgr_h)
vegetation_whgr_f_h=melt(vegetation_whgr_h)

vegetation_wgr_f_h$class <-1
vegetation_whgr_f_h$class <-2

vegetation_var_h=rbind(vegetation_wgr_f_h,vegetation_whgr_f_h)

p5=ggplot(data = vegetation_var_h, aes(x=variable, y=value,fill=factor(class))) + geom_boxplot(show.legend = FALSE)+
  scale_fill_manual(values = c("1" = "coral1", "2" = "cyan2"),name="Calculation type",labels=c("With ground","Without ground")) +
  xlab("Feature class: Height") + ylab("Height [m]") +
  theme_bw(base_size = 17)

p0=ggplot(data = vegetation_var, aes(x=variable, y=value,fill=factor(class))) + geom_boxplot(show.legend = TRUE)+
  scale_fill_manual(values = c("1" = "coral1", "2" = "cyan2"),name="Calculation type",labels=c("With ground","Without ground")) +
  xlab("Feature class: Cover") + ylab("Ratio[%]") +
  theme_bw(base_size = 25)

legend <- get_legend(p0)

grid.arrange(
  p2,
  p5,
  p4,
  p3a,
  p3b,
  legend,
  ncol=2,
  nrow=3,
  layout_matrix=rbind(c(1,2),c(3,4),c(5,6))
)

# Correlations
names(featuretable_l1_a) <- c("C_puls_g","C_can_g","S_curv_g","S_lin_g","S_plan_g","S_sph_g","S_ani_g","VV_sd_g","VV_var_g","VV_skew_g","VV_kurt_g","VV_cr_g","VV_vdr_g","VV_simp_g","VV_shan_g","HV_rough_g","HV_tpi_g","HV_tri_g",
                              "HV_sd_g","HV_var_g","H_max_g","H_mean_g","H_med_g","H_25p_g","H_75p_g","H_90p_g")

names(featuretable_l1_b) <- c("C_puls_v","C_can_v","S_curv_v","S_lin_v","S_plan_v","S_sph_v","S_ani_v","VV_sd_v","VV_var_v","VV_skew_v","VV_kurt_v","VV_cr_v","VV_vdr_v","VV_simp_v","VV_shan_v","HV_rough_v","HV_tpi_v","HV_tri_v",
                              "HV_sd_v","HV_var_v","H_max_v","H_mean_v","H_med_v","H_25p_v","H_75p_v","H_90p_v")

corr_gr_wgr = round(cor(featuretable_l1_a,featuretable_l1_b,method="spearman"), 2)

diag_gr_wgr=data.frame("variables"=c("C_puls","C_can","S_curv","S_lin","S_plan","S_sph","S_ani","VV_sd","VV_var",
                                     "VV_skew","VV_kurt","VV_cr","VV_vdr","VV_simp","VV_shan","HV_rough","HV_tpi",
                                     "HV_tri","HV_sd","HV_var","H_max","H_mean","H_med","H_25p","H_75p","H_90p"),
                       "correlation"=diag(corr_gr_wgr))

diag_gr_wgr=diag_gr_wgr[order(-diag_gr_wgr$correlation),]
tab_df(diag_gr_wgr,file="ex.doc")

correlationMatrix_grwgr <- cor(featuretable_l1_a,featuretable_l1_b,method="spearman")

col <- colorRampPalette(c("#77AADD", "#4477AA", "#FFFFFF", "#EE9988","#BB4444"))

corrplot(correlationMatrix_grwgr, method="color", col=col(200),  
         type="upper", 
         addCoef.col = "black", # Add coefficient of correlation
         tl.col="black", tl.srt=45, font=30, #Text label color and rotation
         # Combine with significance
         # hide correlation coefficient on the principal diagonal
         diag=TRUE)

# Corr. features
correlationMatrix <- cor(featuretable_l1[,1:26],method="spearman")
p.mat <- cor.mtest(featuretable_l1[,1:26])

col <- colorRampPalette(c("#77AADD", "#4477AA", "#FFFFFF", "#EE9988","#BB4444"))

highlyCorrelated <- findCorrelation(correlationMatrix, cutoff=0.9)
featuretable_l1_ncorr=featuretable_l1[,sort(highlyCorrelated)]
names(featuretable_l1_ncorr)

#l2
correlationMatrix_l2 <- cor(featuretable_l2[,1:26],method="spearman")
p.mat_l2 <- cor.mtest(featuretable_l2[,1:26])

col <- colorRampPalette(c("#77AADD", "#4477AA", "#FFFFFF", "#EE9988","#BB4444"))

highlyCorrelated_l2 <- findCorrelation(correlationMatrix_l2, cutoff=0.9)
featuretable_l2_ncorr=featuretable_l2[,sort(highlyCorrelated_l2)]
names(featuretable_l2_ncorr)

#l3
correlationMatrix_l3 <- cor(featuretable_l3[,1:26],method="spearman")
p.mat_l3 <- cor.mtest(featuretable_l3[,1:26])

col <- colorRampPalette(c("#77AADD", "#4477AA", "#FFFFFF", "#EE9988","#BB4444"))

highlyCorrelated <- findCorrelation(correlationMatrix_l3, cutoff=0.9)
featuretable_l3_ncorr=featuretable_l3[,sort(highlyCorrelated)]
names(featuretable_l3_ncorr)

par(mfrow=c(1,1))

corrplot(correlationMatrix, method="color", col=col(200),  
         type="upper", 
         addCoef.col = "black", # Add coefficient of correlation
         tl.col="black", tl.srt=45, #Text label color and rotation
         # Combine with significance
         p.mat = p.mat, sig.level = 0.01, insig = "blank", 
         # hide correlation coefficient on the principal diagonal
         diag=TRUE)

corrplot(correlationMatrix_l2, method="color", col=col(200),  
         type="upper", 
         addCoef.col = "black", # Add coefficient of correlation
         tl.col="black", tl.srt=45, #Text label color and rotation
         # Combine with significance
         p.mat = p.mat_l2, sig.level = 0.01, insig = "blank", 
         # hide correlation coefficient on the principal diagonal
         diag=TRUE)

corrplot(correlationMatrix_l3, method="color", col=col(200),  
         type="upper", 
         addCoef.col = "black", # Add coefficient of correlation
         tl.col="black", tl.srt=45, #Text label color and rotation
         # Combine with significance
         p.mat = p.mat_l3, sig.level = 0.01, insig = "blank", 
         # hide correlation coefficient on the principal diagonal
         diag=TRUE)

# RFE results with feature importance + all ranked feature importance
rfe_l1_df=data.frame(rfe_l1$results$Variables, rfe_l1$results$Accuracy, rfe_l1$results$AccuracySD)
rfe_l2_df=data.frame(rfe_l2$results$Variables, rfe_l2$results$Accuracy, rfe_l2$results$AccuracySD)
rfe_l3_df=data.frame(rfe_l3$results$Variables, rfe_l3$results$Accuracy, rfe_l3$results$AccuracySD)

absoluteBest_l1 <- pickSizeBest(rfe_l1$results, metric = "Accuracy", maximize = TRUE)
within5Pct_l1 <- pickSizeTolerance(rfe_l1$results, metric = "Accuracy", maximize = TRUE,tol=2.5)

absoluteBest_l2 <- pickSizeBest(rfe_l2$results, metric = "Accuracy", maximize = TRUE)
within5Pct_l2 <- pickSizeTolerance(rfe_l2$results, metric = "Accuracy", maximize = TRUE,tol=2.5)

absoluteBest_l3 <- pickSizeBest(rfe_l3$results, metric = "Accuracy", maximize = TRUE)
within5Pct_l3 <- pickSizeTolerance(rfe_l3$results, metric = "Accuracy", maximize = TRUE,tol=2.5)

p1=ggplot(rfe_l1_df,aes(x=rfe_l1$results$Variables,y=rfe_l1$results$Accuracy))+geom_point(color="black",size=3) + geom_line(color="black",size=2) + geom_vline(xintercept = within5Pct_l1, color="red", size=2) + geom_ribbon(aes(ymin=rfe_l1$results$Accuracy-rfe_l1$results$AccuracySD, ymax=rfe_l1$results$Accuracy+rfe_l1$results$AccuracySD), linetype=2, alpha=0.1) + xlab("Number of LiDAR metrics") + ylab("Overall Accuracy") + ylim(0, 1) + theme_bw(base_size = 19) + ggtitle("a)")
p2=ggplot(rfe_l2_df,aes(x=rfe_l2$results$Variables,y=rfe_l2$results$Accuracy))+geom_point(color="black",size=3) + geom_line(color="black",size=2) + geom_vline(xintercept = within5Pct_l2, color="red", size=2) + geom_ribbon(aes(ymin=rfe_l2$results$Accuracy-rfe_l2$results$AccuracySD, ymax=rfe_l2$results$Accuracy+rfe_l2$results$AccuracySD), linetype=2, alpha=0.1) + xlab("Number of LiDAR metrics") + ylab("Overall Accuracy") + ylim(0, 1) + theme_bw(base_size = 19)  + ggtitle("b)")
p3=ggplot(rfe_l3_df,aes(x=rfe_l3$results$Variables,y=rfe_l3$results$Accuracy))+geom_point(color="black",size=3) + geom_line(color="black",size=2) + geom_vline(xintercept = within5Pct_l3, color="red", size=2) + geom_ribbon(aes(ymin=rfe_l3$results$Accuracy-rfe_l3$results$AccuracySD, ymax=rfe_l3$results$Accuracy+rfe_l3$results$AccuracySD), linetype=2, alpha=0.1) + xlab("Number of LiDAR metrics") + ylab("Overall Accuracy") + ylim(0, 1) + theme_bw(base_size = 19)  + ggtitle("c)")

grid.arrange(
  p1,
  p2,
  p3,
  nrow = 1
)

t_l1 <- textGrob("Level 1: Vegetation",gp=gpar(fontsize=22, col="black", fontface="bold"))
t_l2 <- textGrob("Level 2: Wetland habitat",gp=gpar(fontsize=22, col="black", fontface="bold"))
t_l3 <- textGrob("Level 3: Reedbed habitat",gp=gpar(fontsize=22, col="black", fontface="bold"))

# Fig: every results from RFE
#l1
feaimp_l1=rfe_l1[["variables"]]

feaimp_l1_all=feaimp_l1[feaimp_l1$Variables==26,]

feaimp_l1_all_pfea <- feaimp_l1_all %>%
  group_by(var) %>%
  summarise(mean_imp = mean(Overall),sd_imp = sd(Overall))

names(feaimp_l1_all_pfea) <- c("variable","mean_imp","sd_imp" )
feaimp_l1_all_pfea_clas=add_varclass(feaimp_l1_all_pfea)

#l2
feaimp_l2=rfe_l2[["variables"]]

feaimp_l2_all=feaimp_l2[feaimp_l2$Variables==26,]

feaimp_l2_all_pfea <- feaimp_l2_all %>%
  group_by(var) %>%
  summarise(mean_imp = mean(Overall),sd_imp = sd(Overall))

names(feaimp_l2_all_pfea) <- c("variable","mean_imp","sd_imp" )
feaimp_l2_all_pfea_clas=add_varclass(feaimp_l2_all_pfea)

#l3
feaimp_l3=rfe_l3[["variables"]]

feaimp_l3_all=feaimp_l3[feaimp_l3$Variables==26,]

feaimp_l3_all_pfea <- feaimp_l3_all %>%
  group_by(var) %>%
  summarise(mean_imp = mean(Overall),sd_imp = sd(Overall))

names(feaimp_l3_all_pfea) <- c("variable","mean_imp","sd_imp" )
feaimp_l3_all_pfea_clas=add_varclass(feaimp_l3_all_pfea)

p4=ggplot(feaimp_l1_all_pfea_clas, aes(x=reorder(variable,mean_imp),y=mean_imp)) + geom_pointrange(aes(ymin=mean_imp-sd_imp, ymax=mean_imp+sd_imp,color=factor(varclass)),size=1,show.legend = FALSE) + coord_flip() + theme_bw(base_size = 19) +
  geom_hline(yintercept = feaimp_l1_all_pfea_clas$mean_imp[feaimp_l1_all_pfea_clas$variable=="C_can"], color="red", size=1.5) + ggtitle("d)") +
  xlab("LiDAR metrics") + ylab("Feature importance (MDI)") + ylim(-0.5,7) + theme(axis.text.y=element_text(angle=0,colour = c(rep("black",26-within5Pct_l1), rep("red",within5Pct_l1)))) +
  scale_color_manual(values = c("1" = "deeppink", "2" = "chocolate4", "3" = "blueviolet","4"="darkolivegreen3", "5"="blue"),name="Feature class",labels=c("Coverage (C_*)","3D shape (3S_*)", "Vertical variability (VV_*)","Height (H_*)","Horizontal variability (HV_*)"))

p5=ggplot(feaimp_l2_all_pfea_clas, aes(x=reorder(variable,mean_imp),y=mean_imp)) + geom_pointrange(aes(ymin=mean_imp-sd_imp, ymax=mean_imp+sd_imp,color=factor(varclass)),size=1,show.legend = FALSE) + coord_flip() + theme_bw(base_size = 19) +
  geom_hline(yintercept = feaimp_l2_all_pfea_clas$mean_imp[feaimp_l2_all_pfea_clas$variable=="VV_var"], color="red", size=1.5) + ggtitle("e)") +
  xlab("LiDAR metrics") + ylab("Feature importance (MDI)") + ylim(-0.5,7) + theme(axis.text.y=element_text(angle=0,colour = c(rep("black",26-within5Pct_l2), rep("red",within5Pct_l2)))) +
  scale_color_manual(values = c("1" = "deeppink", "2" = "chocolate4", "3" = "blueviolet","4"="darkolivegreen3", "5"="blue"),name="Feature class",labels=c("Coverage (C_*)","3D shape (3S_*)", "Vertical variability (VV_*)","Height (H_*)","Horizontal variability (HV_*)"))

p6=ggplot(feaimp_l3_all_pfea_clas, aes(x=reorder(variable,mean_imp),y=mean_imp)) + geom_pointrange(aes(ymin=mean_imp-sd_imp, ymax=mean_imp+sd_imp,color=factor(varclass)),size=1,show.legend = FALSE) + coord_flip() + theme_bw(base_size = 19) +
  geom_hline(yintercept = feaimp_l3_all_pfea_clas$mean_imp[feaimp_l3_all_pfea_clas$variable=="HV_rough"], color="red", size=1.5) + ggtitle("f)") +
  xlab("LiDAR metrics") + ylab("Feature importance (MDI)") + ylim(-0.5,7) + theme(axis.text.y=element_text(angle=0,colour = c(rep("black",26-within5Pct_l3), rep("red",within5Pct_l3)))) +
  scale_color_manual(values = c("1" = "deeppink", "2" = "chocolate4", "3" = "blueviolet","4"="darkolivegreen3", "5"="blue"),name="Feature class",labels=c("Coverage (C_*)","3D shape (3S_*)", "Vertical variability (VV_*)","Height (H_*)","Horizontal variability (HV_*)"))

p0=ggplot(feaimp_l1_all_pfea_clas, aes(x=reorder(variable,mean_imp),y=mean_imp)) + geom_pointrange(aes(ymin=mean_imp-sd_imp, ymax=mean_imp+sd_imp,color=factor(varclass)),size=1,show.legend = TRUE) + coord_flip() + theme_bw(base_size = 25) +
  xlab("LiDAR metrics") + ylab("Feature importance") +
  scale_color_manual(values = c("1" = "deeppink", "2" = "chocolate4", "3" = "blueviolet","4"="blue", "5"="darkolivegreen3"),name="Feature class",labels=c("Cover (C_*)","3D shape (S_*)", "Vertical variability (VV_*)","Horizontal variability (HV_*)","Height (H_*)")) +
  theme(axis.text.y=element_text(angle=0)) + theme(legend.position="bottom")

legend <- get_legend(p0)

fig4=grid.arrange(
  p1,
  p2,
  p3,
  p4,
  p5,
  p6,
  legend,
  t_l1,
  t_l2,
  t_l3,
  ncol=3,
  nrow=4,
  layout_matrix=rbind(c(8,9,10),c(1,2,3),c(4,5,6), c(7,7,7)),
  widths = c(2,2,2),
  heights = c(0.2,4,4,1)
)

ggsave("Fig3.png",plot = fig4,width = 18, height = 22)
  
# Confusion matrices

# Response curves - partial dependence plot
# level 1
imp <- importance(modelFit_l1)
impvar <- rownames(imp)[order(imp[, 3], decreasing=TRUE)]

id=1
response_l1_imp1 <- Response_l1(modelFit_l1,featuretable_l1,id)
id=3
response_l1_imp2 <- Response_l1(modelFit_l1,featuretable_l1,id)
id=2
response_l1_imp3 <- Response_l1(modelFit_l1,featuretable_l1,id)
id=4
response_l1_imp4 <- Response_l1(modelFit_l1,featuretable_l1,id)
id=5
response_l1_imp5 <- Response_l1(modelFit_l1,featuretable_l1,id)

p7=ggplot(response_l1_imp1,aes(x=class_1_x,y=class_1_y,color=factor(class))) + geom_line(size=2,show.legend = FALSE) + xlab("HV_var [m]") + ylab("Partial dependence (logit of probability)") + scale_color_manual(values = c("1" = "gray", "2" = "aquamarine4"),name="General classes",labels=c("Planar surface", "Vegetation")) + theme_bw(base_size = 20) + ggtitle("a)")
p8=ggplot(response_l1_imp2,aes(x=class_1_x,y=class_1_y,color=factor(class))) + geom_line(size=2,show.legend = FALSE) + xlab(impvar[3]) + ylab("Partial dependence (logit of probability)") + scale_color_manual(values = c("1" = "gray", "2" = "green"),name="General classes",labels=c("Planar surface", "Vegetation")) + theme_bw(base_size = 20)
p9=ggplot(response_l1_imp3,aes(x=class_1_x,y=class_1_y,color=factor(class))) + geom_line(size=2,show.legend = FALSE) + xlab(impvar[2]) + ylab("Partial dependence (logit of probability)") + scale_color_manual(values = c("1" = "gray", "2" = "green"),name="General classes",labels=c("Planar surface", "Vegetation")) + theme_bw(base_size = 20)
p10=ggplot(response_l1_imp4,aes(x=class_1_x,y=class_1_y,color=factor(class))) + geom_line(size=2,show.legend = FALSE) + xlab(impvar[4]) + ylab("Partial dependence (logit of probability)") + scale_color_manual(values = c("1" = "gray", "2" = "green"),name="General classes",labels=c("Planar surface", "Vegetation")) + theme_bw(base_size = 20)
p11=ggplot(response_l1_imp5,aes(x=class_1_x,y=class_1_y,color=factor(class))) + geom_line(size=2,show.legend = FALSE) + xlab(impvar[5]) + ylab("Partial dependence (logit of probability)") + scale_color_manual(values = c("1" = "gray", "2" = "green"),name="General classes",labels=c("Planar surface", "Vegetation")) + theme_bw(base_size = 20)

p00=ggplot(response_l1_imp3,aes(x=class_1_x,y=class_1_y,color=factor(class))) + geom_line(size=2,show.legend = TRUE) + xlab(impvar[3]) + ylab("Partial dependence (logit of probability)") + scale_color_manual(values = c("1" = "gray", "2" = "green"),name="Vegetation",labels=c("Planar surface", "Vegetation")) + theme_bw(base_size = 20)
legend_00 <- get_legend(p00)

p00_b=ggplot(response_l1_imp3,aes(x=class_1_x,y=class_1_y,color=factor(class))) + geom_line(size=2,show.legend = TRUE) + xlab(impvar[3]) + ylab("Partial dependence (logit of probability)") + scale_color_manual(values = c("1" = "gray", "2" = "aquamarine4"),name="Vegetation",labels=c("Planar surface", "Vegetation")) + theme_bw(base_size = 20) + theme(legend.position="bottom")
legend_00_b <- get_legend(p00_b)

parc_dep_l1=grid.arrange(
  p7,
  p8,
  p9,
  p10,
  p11,
  legend_00,
  nrow = 2,
  ncol=3
)

ggsave("parc_dep_l1.png",plot = parc_dep_l1,width = 12, height = 10)

# level 2
imp <- importance(modelFit_l2)
impvar <- rownames(imp)[order(imp[, 3], decreasing=TRUE)]

id=9
response_l2_imp1 <- Response_l2(modelFit_l2,featuretable_l2,id)
id=1
response_l2_imp2 <- Response_l2(modelFit_l2,featuretable_l2,id)
id=6
response_l2_imp3 <- Response_l2(modelFit_l2,featuretable_l2,id)
id=4
response_l2_imp4 <- Response_l2(modelFit_l2,featuretable_l2,id)
id=2
response_l2_imp5 <- Response_l2(modelFit_l2,featuretable_l2,id)

id=3
response_l2_imp6 <- Response_l2(modelFit_l2,featuretable_l2,id)
id=8
response_l2_imp7 <- Response_l2(modelFit_l2,featuretable_l2,id)
id=5
response_l2_imp8 <- Response_l2(modelFit_l2,featuretable_l2,id)
id=7
response_l2_imp9 <- Response_l2(modelFit_l2,featuretable_l2,id)
id=10
response_l2_imp10 <- Response_l2(modelFit_l2,featuretable_l2,id)

p13=ggplot(response_l2_imp1,aes(x=class_1_x,y=class_1_y,color=factor(class))) + geom_line(size=2,show.legend = FALSE) + xlab("H_max [m]") + ylab("Partial dependence (logit of probability)")+ scale_color_manual(values = c("1" = "darkgreen", "2" = "green1", "3" = "gold","4"="darkolivegreen4"),
                                                                                                                                                                    name="Wetland",labels=c("Forest", "Grassland","Reedbed","Shrub")) + theme_bw(base_size = 20) + ggtitle("b)")
p14=ggplot(response_l2_imp2,aes(x=class_1_x,y=class_1_y,color=factor(class))) + geom_line(size=2,show.legend = FALSE) + xlab(impvar[1]) + ylab("Partial dependence (logit of probability)")+ scale_color_manual(values = c("1" = "darkgreen", "2" = "green1", "3" = "gold","4"="darkolivegreen4"),
                                                                                                                                                                     name="Wetland",labels=c("Forest", "Grassland","Reedbed","Shrub")) + theme_bw(base_size = 20)
p15=ggplot(response_l2_imp3,aes(x=class_1_x,y=class_1_y,color=factor(class))) + geom_line(size=2,show.legend = FALSE) + xlab(impvar[6]) + ylab("Partial dependence (logit of probability)")+ scale_color_manual(values = c("1" = "darkgreen", "2" = "green1", "3" = "gold","4"="darkolivegreen4"),
                                                                                                                                                                     name="Wetland",labels=c("Forest", "Grassland","Reedbed","Shrub")) + theme_bw(base_size = 20)
p16=ggplot(response_l2_imp4,aes(x=class_1_x,y=class_1_y,color=factor(class))) + geom_line(size=2,show.legend = FALSE) + xlab("HV_rough [m]") + ylab("Partial dependence (logit of probability)")+ scale_color_manual(values = c("1" = "darkgreen", "2" = "green1", "3" = "gold","4"="darkolivegreen4"),
                                                                                                                                                                                         name="Wetland",labels=c("Forest", "Grassland","Reedbed","Shrub")) + theme_bw(base_size = 20) + ggtitle("c)")
p17=ggplot(response_l2_imp5,aes(x=class_1_x,y=class_1_y,color=factor(class))) + geom_line(size=2,show.legend = FALSE) + xlab(impvar[2]) + ylab("Partial dependence (logit of probability)")+ scale_color_manual(values = c("1" = "darkgreen", "2" = "green1", "3" = "gold","4"="darkolivegreen4"),
                                                                                                                                                                                         name="Wetland",labels=c("Forest", "Grassland","Reedbed","Shrub")) + theme_bw(base_size = 20)

p02=ggplot(response_l2_imp3,aes(x=class_1_x,y=class_1_y,color=factor(class))) + geom_line(size=2,show.legend = TRUE) + xlab(impvar[2]) + ylab("Partial dependence (logit of probability)")+ scale_color_manual(values = c("1" = "darkgreen", "2" = "green1", "3" = "gold","4"="darkolivegreen4"),name="Wetland",labels=c("Forest", "Grassland","Reedbed","Shrub")) + theme_bw(base_size = 20)
legend_02 <- get_legend(p02)

p02_b=ggplot(response_l2_imp3,aes(x=class_1_x,y=class_1_y,color=factor(class))) + geom_line(size=2,show.legend = TRUE) + xlab(impvar[2]) + ylab("Partial dependence (logit of probability)")+ scale_color_manual(values = c("1" = "darkgreen", "2" = "green1", "3" = "gold","4"="darkolivegreen4"),name="Wetland",labels=c("Forest", "Grassland","Reedbed","Shrub")) + theme_bw(base_size = 20) + theme(legend.position="bottom")
legend_02_b <- get_legend(p02_b)

parc_dep_l2a=grid.arrange(
  p13,
  p14,
  p15,
  p16,
  p17,
  legend_02,
  nrow = 2,
  ncol=3
)

ggsave("parc_dep_l2a.png",plot = parc_dep_l2a,width = 12, height = 10)

p18=ggplot(response_l2_imp6,aes(x=class_1_x,y=class_1_y,color=factor(class))) + geom_line(size=2,show.legend = FALSE) + xlab("VV_shan [index]") + ylab("Partial dependence (logit of probability)")+ scale_color_manual(values = c("1" = "darkgreen", "2" = "green1", "3" = "gold","4"="darkolivegreen4"),
                                                                                                                                                                                         name="Wetland",labels=c("Forest", "Grassland","Reedbed","Shrub")) + theme_bw(base_size = 20) + ggtitle("c)")
p19=ggplot(response_l2_imp7,aes(x=class_1_x,y=class_1_y,color=factor(class))) + geom_line(size=2,show.legend = FALSE) + xlab(impvar[8]) + ylab("Partial dependence (logit of probability)")+ scale_color_manual(values = c("1" = "darkgreen", "2" = "green1", "3" = "gold","4"="darkolivegreen4"),
                                                                                                                                                                                         name="Wetland",labels=c("Forest", "Grassland","Reedbed","Shrub")) + theme_bw(base_size = 20)
p20=ggplot(response_l2_imp8,aes(x=class_1_x,y=class_1_y,color=factor(class))) + geom_line(size=2,show.legend = FALSE) + xlab(impvar[5]) + ylab("Partial dependence (logit of probability)")+ scale_color_manual(values = c("1" = "darkgreen", "2" = "green1", "3" = "gold","4"="darkolivegreen4"),
                                                                                                                                                                                         name="Wetland",labels=c("Forest", "Grassland","Reedbed","Shrub")) + theme_bw(base_size = 20)
p21=ggplot(response_l2_imp9,aes(x=class_1_x,y=class_1_y,color=factor(class))) + geom_line(size=2,show.legend = FALSE) + xlab(impvar[7]) + ylab("Partial dependence (logit of probability)")+ scale_color_manual(values = c("1" = "darkgreen", "2" = "green1", "3" = "gold","4"="darkolivegreen4"),
                                                                                                                                                                                         name="Wetland",labels=c("Forest", "Grassland","Reedbed","Shrub")) + theme_bw(base_size = 20)
p22=ggplot(response_l2_imp10,aes(x=class_1_x,y=class_1_y,color=factor(class))) + geom_line(size=2,show.legend = FALSE) + xlab(impvar[10]) + ylab("Partial dependence (logit of probability)")+ scale_color_manual(values = c("1" = "darkgreen", "2" = "green1", "3" = "gold","4"="darkolivegreen4"),
                                                                                                                                                                                         name="Wetland",labels=c("Forest", "Grassland","Reedbed","Shrub")) + theme_bw(base_size = 20)

parc_dep_l2b=grid.arrange(
  p18,
  p19,
  p20,
  p21,
  p22,
  legend_02,
  nrow = 2,
  ncol=3
)

ggsave("parc_dep_l2b.png",plot = parc_dep_l2b,width = 12, height = 10)

#level 3
imp <- importance(modelFit_l3)
impvar <- rownames(imp)[order(imp[, 3], decreasing=TRUE)]

id=1
response_l3_imp1 <- Response_l3(modelFit_l3,featuretable_l3,id)
id=4
response_l3_imp2 <- Response_l3(modelFit_l3,featuretable_l3,id)
id=5
response_l3_imp3 <- Response_l3(modelFit_l3,featuretable_l3,id)
id=6
response_l3_imp4 <- Response_l3(modelFit_l3,featuretable_l3,id)
id=2
response_l3_imp5 <- Response_l3(modelFit_l3,featuretable_l3,id)

id=9
response_l3_imp6 <- Response_l3(modelFit_l3,featuretable_l3,id)
id=3
response_l3_imp7 <- Response_l3(modelFit_l3,featuretable_l3,id)
id=7
response_l3_imp8 <- Response_l3(modelFit_l3,featuretable_l3,id)
id=8
response_l3_imp9 <- Response_l3(modelFit_l3,featuretable_l3,id)
id=10
response_l3_imp10 <- Response_l3(modelFit_l3,featuretable_l3,id)

p23=ggplot(response_l3_imp1,aes(x=class_1_x,y=class_1_y,color=factor(class))) + geom_line(size=2,show.legend = FALSE) + xlab("H_90p [m]") + ylab("Partial dependence (logit of probability)")+ scale_color_manual(values = c("1"="tan2","2"="gold","3"="chocolate4"),name="Reedbed",labels=c("Land reed rich","Land reed poor","Water reed")) + theme_bw(base_size = 20) + ggtitle("d)")
p24=ggplot(response_l3_imp2,aes(x=class_1_x,y=class_1_y,color=factor(class))) + geom_line(size=2,show.legend = FALSE) + xlab(impvar[4]) + ylab("Partial dependence (logit of probability)")+ scale_color_manual(values = c("1"="tan2","2"="gold","3"="chocolate4"),name="Reedbed",labels=c("Land reed rich","Land reed poor","Water reed")) + theme_bw(base_size = 20)
p25=ggplot(response_l3_imp3,aes(x=class_1_x,y=class_1_y,color=factor(class))) + geom_line(size=2,show.legend = FALSE) + xlab("C_puls [%]") + ylab("Partial dependence (logit of probability)")+ scale_color_manual(values = c("1"="tan2","2"="gold","3"="chocolate4"),name="Reedbed",labels=c("Land reed rich","Land reed poor","Water reed")) + theme_bw(base_size = 20) + ggtitle("e)")
p26=ggplot(response_l3_imp4,aes(x=class_1_x,y=class_1_y,color=factor(class))) + geom_line(size=2,show.legend = FALSE) + xlab("HV_sd [m]") + ylab("Partial dependence (logit of probability)")+ scale_color_manual(values = c("1"="tan2","2"="gold","3"="chocolate4"),name="Reedbed",labels=c("Land reed rich","Land reed poor","Water reed")) + theme_bw(base_size = 20) + ggtitle("f)")
p27=ggplot(response_l3_imp5,aes(x=class_1_x,y=class_1_y,color=factor(class))) + geom_line(size=2,show.legend = FALSE) + xlab(impvar[2]) + ylab("Partial dependence (logit of probability)")+ scale_color_manual(values = c("1"="tan2","2"="gold","3"="chocolate4"),name="Reedbed",labels=c("Land reed rich","Land reed poor","Water reed")) + theme_bw(base_size = 20)

p28=ggplot(response_l3_imp6,aes(x=class_1_x,y=class_1_y,color=factor(class))) + geom_line(size=2,show.legend = FALSE) + xlab(impvar[9]) + ylab("Partial dependence (logit of probability)")+ scale_color_manual(values = c("1"="tan2","2"="gold","3"="chocolate4"),name="Reedbed",labels=c("Land reed rich","Land reed poor","Water reed")) + theme_bw(base_size = 20)
p29=ggplot(response_l3_imp7,aes(x=class_1_x,y=class_1_y,color=factor(class))) + geom_line(size=2,show.legend = FALSE) + xlab(impvar[3]) + ylab("Partial dependence (logit of probability)")+ scale_color_manual(values = c("1"="tan2","2"="gold","3"="chocolate4"),name="Reedbed",labels=c("Land reed rich","Land reed poor","Water reed")) + theme_bw(base_size = 20)
p30=ggplot(response_l3_imp8,aes(x=class_1_x,y=class_1_y,color=factor(class))) + geom_line(size=2,show.legend = FALSE) + xlab(impvar[7]) + ylab("Partial dependence (logit of probability)")+ scale_color_manual(values = c("1"="tan2","2"="gold","3"="chocolate4"),name="Reedbed",labels=c("Land reed rich","Land reed poor","Water reed")) + theme_bw(base_size = 20)
p31=ggplot(response_l3_imp9,aes(x=class_1_x,y=class_1_y,color=factor(class))) + geom_line(size=2,show.legend = FALSE) + xlab(impvar[8]) + ylab("Partial dependence (logit of probability)")+ scale_color_manual(values = c("1"="tan2","2"="gold","3"="chocolate4"),name="Reedbed",labels=c("Land reed rich","Land reed poor","Water reed")) + theme_bw(base_size = 20)
p32=ggplot(response_l3_imp10,aes(x=class_1_x,y=class_1_y,color=factor(class))) + geom_line(size=2,show.legend = FALSE) + xlab(impvar[10]) + ylab("Partial dependence (logit of probability)")+ scale_color_manual(values = c("1"="tan2","2"="gold","3"="chocolate4"),name="Reedbed",labels=c("Land reed rich","Land reed poor","Water reed")) + theme_bw(base_size = 20)

p03=ggplot(response_l3_imp3,aes(x=class_1_x,y=class_1_y,color=factor(class))) + geom_line(size=2,show.legend = TRUE) + xlab(impvar[6]) + ylab("Partial dependence (logit of probability)")+ scale_color_manual(values = c("1"="tan2","2"="gold","3"="chocolate4"),name="Reedbed",labels=c("Land reed rich","Land reed poor","Water reed")) + theme_bw(base_size = 20)
legend_03 <- get_legend(p03)

p03_b=ggplot(response_l3_imp3,aes(x=class_1_x,y=class_1_y,color=factor(class))) + geom_line(size=2,show.legend = TRUE) + xlab(impvar[6]) + ylab("Partial dependence (logit of probability)")+ scale_color_manual(values = c("1"="tan2","2"="gold","3"="chocolate4"),name="Reedbed",labels=c("Land reed rich","Land reed poor","Water reed")) + theme_bw(base_size = 20) + theme(legend.position="bottom")
legend_03_b <- get_legend(p03_b)

parc_dep_l3a=grid.arrange(
  p23,
  p24,
  p25,
  p26,
  p27,
  legend_03,
  nrow = 2,
  ncol=3
)

ggsave("parc_dep_l3a.png",plot = parc_dep_l3a,width = 12, height = 10)

parc_dep_l3b=grid.arrange(
  p28,
  p29,
  p30,
  p31,
  p32,
  legend_03,
  nrow = 2,
  ncol=3
)

ggsave("parc_dep_l3b.png",plot = parc_dep_l3b,width = 12, height = 10)

#selected parc.dep.

grid.arrange(
  p7,
  p13,
  p16,
  p23,
  p25,
  p26,
  legend_00_b,
  legend_02_b,
  legend_03_b,
  t_l1,
  t_l2,
  t_l3,
  ncol=3,
  nrow=6,
  layout_matrix=rbind(c(10,11,11),c(1,2,3),c(7,8,8),c(12,12,12),c(4,5,6),c(9,9,9)),
  widths = c(1,1,1),
  heights = c(0.2,3,0.2,0.2,3,0.2)
)
