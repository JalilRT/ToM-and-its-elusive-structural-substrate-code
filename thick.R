setwd("/home/jalil/Documents/struc_datos/")
library(tibble)
library(Hmisc)
library(dplyr)
library(ggplot2)
library(plyr)
library(devtools)
library(ggthemr)
library(corrplot)
library(rstatix)

##colors 
col <- colorRampPalette(c("#495c63", "#65767b", "#FFFFFF","#93c6d4","#3d6470"))

###ROIS SST-RMET - 69 ####
#left
rois_cat<-read.csv("fs_thick/ROIs_catROIs_aparc_a2009s_thickness.csv")
nero_cat<- select(as.tibble(rois_cat[3:ncol(rois_cat)]), starts_with('l'))
cat.lg<-colMeans(nero_cat)
##right
rois_cat_r<-read.csv("fs_thick/ROIs_catROIs_aparc_a2009s_thickness.csv")
nero_cat_r<- select(as.tibble(rois_cat_r[4:ncol(rois_cat_r)]), starts_with('r'))
cat.rg<-colMeans(nero_cat_r)

cat.rl<-data.frame(cat.lg,cat.rg)
cat<-cat.rl %>% mutate(mean=rowMeans(cbind(cat.lg,cat.rg), na.rm=T))
cat<-data.frame(cat.rl[,0],cat)

r.cat.sd<-sapply(nero_cat_r,sd,na.rm=TRUE)
l.cat.sd<-sapply(nero_cat,sd,na.rm=TRUE)
cat.sd<-data.frame(l.cat.sd,r.cat.sd)
cat.sd<-cat.sd %>% mutate(mean=rowMeans(cbind(l.cat.sd,r.cat.sd), na.rm=T))

cat<-data.frame(cat,cat.sd)
#write.csv(cat,"cat.csv", row.names = T)
#View(cat[3])               

rois_fs<-read.csv("fs_thick/lh_ROIs_fsROIs_aparc_a2009s_thicknes.csv")
nero_fs<- select(as.tibble(rois_fs), starts_with('l'))
fs.lg<-colMeans(nero_fs[,-1])
##right
rois_fs_r<-read.csv("fs_thick/rh_ROIs_fsROIs_aparc_a2009s_thicknes.csv")
nero_fs_r<- select(as.tibble(rois_fs_r), starts_with('r'))
fs.rg<-colMeans(nero_fs_r[,-1])
fs.rl<-data.frame(fs.lg,fs.rg)
fs<-fs.rl %>% mutate(mean=rowMeans(cbind(fs.lg,fs.rg), na.rm=T))
fs<-data.frame(fs.rl[,0],fs)

r.fs.sd<-sapply(nero_fs_r[,-1],sd,na.rm=TRUE)
l.fs.sd<-sapply(nero_fs[,-1],sd,na.rm=TRUE)
fs.sd<-data.frame(l.fs.sd,r.fs.sd)
fs.sd<-fs.sd %>% mutate(mean=rowMeans(cbind(l.fs.sd,r.fs.sd), na.rm=T))

fs<-data.frame(fs,fs.sd)
#write.csv(fs,"fs.csv", row.names = T)
#View(fs[3])

fs.cat<-merge(cat[3],fs[3],by="row.names")
colnames(fs.cat)[2]<-"cat"
colnames(fs.cat)[3]<-"fs"

CT<-read.csv("fs_thick/fscat.csv")

#### SST 91 ####

rois_cat_91<-read.csv("vbm12/Results_cortical/ROIs_catROIs_aparc_a2009s_thickness.csv")
nero_cat_91<- select(as.tibble(rois_cat_91[3:ncol(rois_cat_91)]), starts_with('l'))
cat.lg_91<-colMeans(nero_cat_91)
##right
rois_cat_r_91<-read.csv("vbm12/Results_cortical/ROIs_catROIs_aparc_a2009s_thickness.csv")
nero_cat_r_91<- select(as.tibble(rois_cat_r_91[4:ncol(rois_cat_r_91)]), starts_with('r'))
cat.rg_91<-colMeans(nero_cat_r_91)

cat.rl_91<-data.frame(cat.lg_91,cat.rg_91)
cat_91<-cat.rl_91 %>% mutate(mean=rowMeans(cbind(cat.lg_91,cat.rg_91), na.rm=T))
#View(cat_91[3])               

rois.ct_91<-read.csv("cat_vol/rois_ct_91.csv")
rois.ct_91<-rois.ct_91[-1]
roi.m.ct_91<-cor(rois.ct_91)
p.mat<-cor.mtest(roi.m.ct_91)
col <- colorRampPalette(c("#495c63", "#65767b", "#FFFFFF","#93c6d4","#3d6470"))
png("Ct_cor_sst91.png", width = 25, height = 20, units = "cm",res = 300)
corrplot(roi.m.ct_91, method="color", col=col(200),  
         type="upper", tl.col="black", tl.srt=45, 
         p.mat = p.mat, sig.level = 0.001, insig = "blank", diag=FALSE,
         addgrid.col = "gray")
dev.off()



### CT #############

ggthemr("fresh")

names(CT)
CTT<-read.csv("fs_thick/fsc_at_final.csv")
legend_ord <- factor(CTT$Software, levels = rev(levels(CTT$Software)))
mu <- ddply(CTT, "Software", summarise, grp.mean=mean(CT))
CT_his<-ggplot(CTT, aes(x=CT, fill=Software, color=Software)) +
  geom_histogram(aes(y=..density..),position="identity", alpha=0.7)+geom_density(alpha=0.42)+
  geom_vline(data=mu, aes(xintercept=grp.mean, color=Software),
             linetype="dashed")+
  theme(legend.position="top")+
  labs(x="Cortical Thickness", y = "Density")
CT_his+
  scale_fill_discrete(breaks=legend_ord)+
  scale_color_discrete(breaks=legend_ord)
ggsave("CT_his.png", width = 20, height = 15, units = "cm")

cat.sbm.rois<-CTT %>% filter(Software=="CAT12-SBM")
Fs.cort.rois<-CTT %>% filter(Software=="FreeSurfer")
t.test(CT~Software, CTT, alternative="two.sided", var.equal=TRUE)
var.test(CT~Software, CTT) #no homogenea
shapiro_test(CTT$CT)

CTT %>% wilcox_test(CT~Software, alternative = "two.sided", mu = 0,
            paired = FALSE)%>%
  adjust_pvalue(method = "bonferroni")
CTT %>% wilcox_effsize(CT~Software, alternative = "two.sided", mu = 0,
                       paired = FALSE)
CTT %>% cohens_d(CT~Software, var.equal = FALSE)

legend_ord <- factor(CT$Software, levels = rev(levels(CT$Software)))

CT_bars<-ggplot(CT, aes(x=names, y=CT, fill=legend_ord,color=legend_ord))+
  geom_bar(stat="identity", position=position_dodge())+ 
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
        legend.position = "top")+
  labs(x="Structures",y="Cortical Thickness (mm)")+
  scale_color_manual(values=c("black", "black"),name="Software")+
  scale_fill_manual(values=c("#233b43","#65adc2"),name="Software")
CT_bars+
  geom_errorbar(aes(ymin=CT-sd, ymax=CT+sd),
                width=.15,                    # Width of the error bars
                position=position_dodge(.9))

ggsave("CT_bars.png", width = 25, height = 18, units = "cm")
  
############ ROIs VOLUME
library(corrplot)

####SST###
rois<-read.csv("cat_vol/rois.csv")

naro<-c("SST","IPL/TPJ-L_CAT12","Pcu-L1_CAT12","dmPFC-L_CAT12","AnG-L_CAT12","LOC-R_CAT12","mFC-L_CAT12","MTG-R_CAT12",
        "Pcu-L2_CAT12","TL-L_CAT12","IPL/TPJ-L_FSL","Pcu-L1_FSL","dmPFC-L_FSL","AnG-L_FSL","LOC-R_FSL",
        "mFC-L_FSL","MTG-R_FSL","Pcu-L2_FSL","TL-L_FSL")
roi.m<-cor(rois)
colnames(roi.m)<-naro
rownames(roi.m)<-naro

cor.test(rois$Pcu_CAT12,rois$Pcu_FSL)
cor.mtest <- function(mat, ...) {
  mat <- as.matrix(mat)
  n <- ncol(mat)
  p.mat<- matrix(NA, n, n)
  diag(p.mat) <- 0
  for (i in 1:(n - 1)) {
    for (j in (i + 1):n) {
      tmp <- cor.test(mat[, i], mat[, j], ...)
      p.mat[i, j] <- p.mat[j, i] <- tmp$p.value
    }
  }
  colnames(p.mat) <- rownames(p.mat) <- colnames(mat)
  p.mat
}


p.mat<-cor.mtest(rois) 

col <- colorRampPalette(c("#495c63", "#65767b", "#FFFFFF","#93c6d4","#3d6470"))
sst.res2<-rcorr(as.matrix(rois, type = c("pearson")))
sst.p.adj<-p.adjust(sst.res2$P, method = "fdr", n = length(sst.res2$P))
sst.resAdj <- matrix(sst.p.adj, ncol = dim(sst.res2$P)[1])

png("Vol_cor.png", width = 25, height = 20, units = "cm",res = 300)
corrplot(roi.m, method="color", col=col(200),  
         type="upper", tl.col="black", tl.srt=45, 
         p.mat = p.mat, sig.level = 0.001, insig = "blank", diag=FALSE,
         addgrid.col = "gray")
dev.off()

##RMET
rois.rmet<-read.csv("cat_vol/rois_rmet.csv")
roi.m.rmet<-cor(rois.rmet)
colnames(roi.m.rmet)<-c("RMET",naro)
row.names(roi.m.rmet)<-c("RMET",naro)
p.mat<-cor.mtest(roi.m.rmet)

rmet.res2<-rcorr(as.matrix(rois.rmet, type = c("pearson")))
rmet.p.adj<-p.adjust(rmet.res2$P, method = "fdr", n = length(rmet.res2$P))
rmet.resAdj <- matrix(rmet.p.adj, ncol = dim(rmet.res2$P)[1])

png("Vol_cor_rmet.png", width = 25, height = 20, units = "cm",res = 300)
corrplot(roi.m.rmet, method="color", col=col(200),  
         type="upper", tl.col="black", tl.srt=45, 
         p.mat = p.mat, sig.level = 0.001, insig = "blank", diag=FALSE,
         addgrid.col = "gray")
dev.off()

##scatter
roi2<-read.csv("cat_vol/roi2.csv")
ggplot(roi2, aes(x=SST, y=CT, color=Area, shape=Area)) + geom_point()+
  geom_smooth(method=lm, se=FALSE, fullrange=TRUE)

###### comparison
library(tidyr)
library(reshape2)
library(Rmisc)
rois.fsl.cat<-read.csv("cat_vol/rois.csv")
fsl.cat<-colMeans(rois.fsl.cat)
fsl.cat.sd<-sapply(rois.fsl.cat,sd,na.rm=TRUE)
fsl.cat.ms<-data.frame(fsl.cat,fsl.cat.sd)
#write.csv(fsl.cat.ms,"fsl_cat_ms.csv")

rois.vbm<-read.csv("cat_vol/roisVol.csv")
vol_legend_ord <- factor(rois.vbm$Software, levels = rev(levels(rois.vbm$Software)))

dfwc <- summarySEwithin(rois.vbm, measurevar="Volume", withinvars="Software",
                        idvar="Structures", na.rm=FALSE, conf.interval=.95)

rois.vbm$Structures<-c("IPL/TPJ-L","PCu-L1","dmPFC-L","AnG-L","LOC-R","mFC-L","MTG-R","PCu-L2","TL-L",
                       "IPL/TPJ-L","PCu-L1","dmPFC-L","AnG-L","LOC-R","mFC-L","MTG-R","PCu-L2","TL-L")
CT_bars<-ggplot(rois.vbm, aes(x=Structures, y=Volume, fill=vol_legend_ord,color=vol_legend_ord)) +
  geom_bar(stat="identity", position="dodge")+ 
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
        legend.position = "top")+
  labs(x="Structures",y="Volume")+
  scale_color_manual(values=c("black", "black"),name="Software")+
  scale_fill_manual(values=c("#233b43","#65adc2"),name="Software")
CT_bars +
  geom_errorbar(aes(ymin=Volume-(sd), ymax=Volume+(sd)),
                width=.15,                    # Width of the error bars
                position=position_dodge(.9))

ggsave("Vol_bars.png", width = 20, height = 15, dpi=300,units = "cm")


####### CT ROIS ########
rois.ct<-read.csv("cat_vol/rois_ct.csv")
roi.m.ct<-cor(rois.ct)
cor.test(rois.ct$IFG_CAT12,rois.ct$IFG_FS)
cor.test(rois.ct$MFG_CAT12,rois.ct$MFG_FS)

p.mat<-cor.mtest(roi.m.ct)

ct.sst.res2<-rcorr(as.matrix(rois.ct, type = "pearson"))
ct.sst.p.adj<-p.adjust(ct.sst.res2$P, method = "fdr", n = length(ct.sst.res2$P))
ct.sst.resAdj <- matrix(ct.sst.p.adj, ncol = dim(ct.sst.res2$P)[1])

png("Ct_cor_rmetsst.png", width = 25, height = 20, units = "cm",res = 300)
corrplot(roi.m.ct, method="color", col=col(200),  
         type="upper", tl.col="black", tl.srt=45, 
         p.mat = p.mat, sig.level = 0.001, insig = "blank", diag=FALSE,
         addgrid.col = "gray")
dev.off()


####### ROIS vbm
rois.vbm<-read.csv("cat_vol/roisVol.csv")
mu <- ddply(rois.vbm, "Software", summarise, grp.mean=mean(Volume))
Vol_des<-ggplot(rois.vbm, aes(x=Volume, fill=Software, color=Software)) +
  geom_histogram(aes(y=..density..),position="identity", alpha=0.7)+geom_density(alpha=0.42)+
  geom_vline(data=mu, aes(xintercept=grp.mean, color=Software),
             linetype="dashed")+
  theme(legend.position="top")+
  labs(x="Cortical Thickness", y = "Density")
Vol_des+scale_color_manual(values=c("black", "black", "#56B4E9"))

var.test(Volume~Software, rois.vbm)

t.test(Volume~Software, rois.vbm)
cohensD(Volume~Software, rois.vbm)

rois.vbm %>% group_by(Software) %>% shapiro_test(Volume)
rois.vbm %>% group_by(Software) %>% identify_outliers(Volume)
rois.vbm %>% t_test(Volume~Software, alternative="less", paired = F)
rois.vbm %>% cohens_d(Volume~Software, mu = 0, paired = FALSE)
rois.vbm %>% wilcox_test(Volume~Software, alternative = "two.sided", mu = 0,
                    paired = FALSE)%>%
  adjust_pvalue(method = "bonferroni")
rois.vbm %>% wilcox_effsize(Volume~Software, alternative = "two.sided", mu = 0,
                       paired = FALSE)

rois.vbm$id <- rep(1:9, 2)

library(ez)
ezANOVA(data = rois.vbm, dv = .(Volume), wid = .(id), within = .(Software), detailed = TRUE, type = 1)

CTT$id <- rep(1:74, 2)
ezANOVA(data = CTT, dv = .(CT), wid = .(id), within = .(Software), detailed = TRUE, type = 1)
  