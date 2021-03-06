library(ecospat)
library(raster)

library(ggplot2)
library(gridExtra)

get_legend<-function(myggplot){
  tmp <- ggplot_gtable(ggplot_build(myggplot))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  return(legend)
}

# Global
workingdirectory="C:/Koma/Sync/_Amsterdam/_PhD/Chapter3_wetlandniche/3_Dataprocessing/Niche_v11/"
setwd(workingdirectory)

grw_pca12 <- readRDS("grw_kdens_r.rds")
kk_pca12 <- readRDS("kk_kdens_r.rds")
sn_pca12 <- readRDS("sn_kdens_r.rds")

grw_pca12_df <- as.data.frame(grw_pca12[["z.uncor"]], xy = TRUE)
grw_pca12_backg_df<- as.data.frame(grw_pca12[["Z"]], xy = TRUE)

kk_pca12_df <- as.data.frame(kk_pca12[["z.uncor"]], xy = TRUE)
kk_pca12_backg_df<- as.data.frame(kk_pca12[["Z"]], xy = TRUE)

sn_pca12_df <- as.data.frame(sn_pca12[["z.uncor"]], xy = TRUE)
sn_pca12_backg_df<- as.data.frame(sn_pca12[["Z"]], xy = TRUE)

grw_pca12_df$species <- "Great reed warbler"
kk_pca12_df$species <- "Reed warbler"
sn_pca12_df$species <- "Savi's warbler"

grw_pca12_backg_df$species <- "Absence"
kk_pca12_backg_df$species <- "Absence"
sn_pca12_backg_df$species <- "Absence"

pca12_gr_kk=rbind(grw_pca12_df,kk_pca12_df)
pca12_gr_sn=rbind(grw_pca12_df,sn_pca12_df)
pca12_kk_sn=rbind(kk_pca12_df,sn_pca12_df)

eq_grw_kk <- readRDS("eq.test_gr_k.rds")
eq_grw_s <- readRDS("eq.test_gr_s.rds")
eq_k_s <- readRDS("eq.test_k_s.rds")

######
p1=ggplot(data=pca12_gr_kk)+stat_contour(aes(x=x, y=y, z=layer,fill=species), geom="polygon", bins=5,breaks=c(0,0.25,0.5,0.75,1), alpha=.3,show.legend = FALSE)+
  theme_bw(base_size = 15)+xlab("PCA 1")+ylab("PCA 2")+scale_fill_manual(values=c("goldenrod4","green3"),name="Species")+
  ggtitle("a)")

eq_grw_kk_df=as.data.frame(eq_grw_kk[["sim"]][["D"]])
names(eq_grw_kk_df)<- "SimD"
#eq_grw_kk[["p.D"]]=0.0099

p2=ggplot(data=eq_grw_kk_df,aes(x = SimD))+geom_density(fill = "lightblue")+
  geom_vline(aes(xintercept = eq_grw_kk[["obs"]][["D"]]), linetype = "solid",color="red",size=2)+theme_bw(base_size = 15)+
  xlab(paste("D \n mean sim.D=",round(mean(eq_grw_kk[["sim"]][["D"]]),2),"\n sd sim.D=",round(sd(eq_grw_kk[["sim"]][["D"]]),2),"\n obs.D=",round(eq_grw_kk[["obs"]][["D"]],2),"\n p.value= ",round(eq_grw_kk[["p.D"]],4),sep=""))+ylab("Density")

forlegp1=ggplot(data=pca12_gr_kk)+stat_contour(aes(x=x, y=y, z=layer,fill=species),geom="polygon", bins=4, alpha=.3,show.legend = TRUE)+
  theme_bw(base_size = 15)+xlab("PCA 1")+ylab("PCA 3")+scale_fill_manual(values=c("goldenrod4","green3"),name="Species")+theme(legend.position = "left")
legend_p1 <- get_legend(forlegp1)

p22=grid.arrange(
  legend_p1,
  p2,
  ncol = 1, nrow = 2
)

fig3a=grid.arrange(p1,p22,ncol = 2, nrow = 1,widths = c(2, 1))

######
p1=ggplot(data=pca12_gr_sn)+stat_contour(aes(x=x, y=y, z=layer,fill=species), geom="polygon", bins=5,breaks=c(0,0.25,0.5,0.75,1), alpha=.3,show.legend = FALSE)+
  theme_bw(base_size = 15)+xlab("PCA 1")+ylab("PCA 2")+scale_fill_manual(values=c("goldenrod4","deeppink"),name="Species")+
  ggtitle("b)")

eq_grw_kk_df=as.data.frame(eq_grw_s[["sim"]][["D"]])
names(eq_grw_kk_df)<- "SimD"

p2=ggplot(data=eq_grw_kk_df,aes(x = SimD))+geom_density(fill = "lightblue")+
  geom_vline(aes(xintercept = eq_grw_s[["obs"]][["D"]]), linetype = "solid",color="red",size=2)+theme_bw(base_size = 15)+
  xlab(paste("D \n mean sim.D=",round(mean(eq_grw_s[["sim"]][["D"]]),2),"\n sd sim.D=",round(sd(eq_grw_s[["sim"]][["D"]]),2),"\n obs.D=",round(eq_grw_s[["obs"]][["D"]],2),"\n p.value= ",round(eq_grw_s[["p.D"]],4),sep=""))+ylab("Density")

forlegp1=ggplot(data=pca12_gr_sn)+stat_contour(aes(x=x, y=y, z=layer,fill=species),geom="polygon", bins=4, alpha=.3,show.legend = TRUE)+
  theme_bw(base_size = 15)+xlab("PCA 1")+ylab("PCA 3")+scale_fill_manual(values=c("goldenrod4","deeppink"),name="Species")+theme(legend.position = "left")
legend_p1 <- get_legend(forlegp1)

p22=grid.arrange(
  legend_p1,
  p2,
  ncol = 1, nrow = 2
)

fig3b=grid.arrange(p1,p22,ncol = 2, nrow = 1,widths = c(2, 1))

######
levels(pca12_kk_sn$species) = c("Savi's warbler", "Reed warbler")

p1=ggplot(data=pca12_kk_sn)+stat_contour(aes(x=x, y=y, z=layer,fill=species), geom="polygon", bins=5,breaks=c(0,0.25,0.5,0.75,1), alpha=.3,show.legend = FALSE)+
  theme_bw(base_size = 15)+xlab("PCA 1")+ylab("PCA 2")+scale_fill_manual(values=c("green3","deeppink"),name="Species")+
  ggtitle("c)")

eq_grw_kk_df=as.data.frame(eq_k_s[["sim"]][["D"]])
names(eq_grw_kk_df)<- "SimD"

p2=ggplot(data=eq_grw_kk_df,aes(x = SimD))+geom_density(fill = "lightblue")+
  geom_vline(aes(xintercept = eq_k_s[["obs"]][["D"]]), linetype = "solid",color="red",size=2)+theme_bw(base_size = 15)+
  xlab(paste("D \n mean sim.D=",round(mean(eq_k_s[["sim"]][["D"]]),2),"\n sd sim.D=",round(sd(eq_k_s[["sim"]][["D"]]),2),"\n obs.D=",round(eq_k_s[["obs"]][["D"]],2),"\n p.value= ",round(eq_k_s[["p.D"]],4),sep=""))+ylab("Density")

#geom_label(aes(x=eq_k_s[["obs"]][["D"]]+0.008, label="Observed D", y=40), colour="red", angle=0)

forlegp1=ggplot(data=pca12_kk_sn)+stat_contour(aes(x=x, y=y, z=layer,fill=species),geom="polygon", bins=4, alpha=.3,show.legend = TRUE)+
  theme_bw(base_size = 15)+xlab("PCA 1")+ylab("PCA 3")+scale_fill_manual(values=c("deeppink","green3"),name="Species",labels=c("Savi's warbler", "Reed warbler"))+theme(legend.position = "left")
legend_p1 <- get_legend(forlegp1)

p22=grid.arrange(
  legend_p1,
  p2,
  ncol = 1, nrow = 2
)

fig3c=grid.arrange(p1,p22,ncol = 2, nrow = 1,widths = c(2, 1))

fig3=grid.arrange(
  fig3a,
  fig3c,
  fig3b,
  ncol = 1, nrow = 3
)

ggsave("Fig3_a_pc12.png",plot = fig3,width = 15, height = 15)

