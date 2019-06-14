library(tidyverse)
library(RColorBrewer)
library(ggthemes)
library(grid)
library(gridExtra)
out3 <- read_tsv("../example/example_sim_jun7_delta1_test_out3.txt",
                 col_names = c("spacer","version","type", "gen","pop","mut_pos",
                               "mutID","mut_popID","mut_freq","mut_sel")) %>%
  filter(gen > 1)



out2 <- read_tsv("../example/example_sim_jun7_delta1_test_out2.txt",
                 col_names = c("spacer","version","gen","p1_home","p2_home",
                               "p1_home_count","p2_home_count","fit_dif")) %>%
  filter(gen > 1)

#Sample fitness
out4 <- read_tsv("../example/example_sim_jun7_delta1_test_out4.txt",
                 col_names = c("spacer","version","gen","pop","id","fitness","spacer2"))

#Gene identities
out3 %>%
  filter(type == "M1") %>%
  select(mutID, mut_popID, mut_sel) %>% unique() %>%
  rename(mut_ID = mutID)-> QTL_loci

#Genotypes
out5 <- read_tsv("../example/example_sim_jun7_delta1_test_out5_processed.txt")



inner_join(QTL_loci,out5) %>%
  filter(gen > 10001) %>%
  inner_join(.,out4) -> out459

mut_s <- tibble(gen=numeric(),rel_fitness=numeric(),pop=character(),
                mut_ID=numeric(),mut_sel=numeric(),mut_popID=numeric())

for (i in 1:nrow(QTL_loci)){
  print(i)
  chosen_mut_ID = QTL_loci$mut_ID[i]
  chosen_mut_sel = QTL_loci$mut_sel[i]
  chosen_mut_popID = QTL_loci$mut_popID[i]
  out459 %>%
    filter(mut_ID == chosen_mut_ID) %>%
    group_by(gen,pop,geno) %>%
    summarize(mean_fitness = mean(fitness), n = n()) %>%
    group_by(gen,pop) %>%
    filter(n > 4) %>%
    mutate(count=n()) %>%
    filter(count == 3) -> tmp_intermediate
  if (nrow(tmp_intermediate) > 0 ){
    tmp_intermediate %>%
      summarize(rel_fitness = (mean_fitness[which(geno == 2)] - mean_fitness[which(geno == 0)])/mean_fitness[which(geno == 0)]  )  %>%
      mutate(poptmp = case_when(pop == 1 ~ "p1",
                                pop == 2 ~ "p2")) %>%
      select(-pop) %>% rename(pop = poptmp) %>%
      mutate(mut_ID = chosen_mut_ID, mut_sel = chosen_mut_sel, mut_popID = chosen_mut_popID) %>%
      ungroup()-> tmpdata
    mut_s <- rbind(mut_s, tmpdata)
  }
}


tmpdata2 %>%
  ggplot(.,aes(x=gen,y=rel_fitness,color=pop,group=pop)) + geom_line()


out3 %>%
  filter(type != "M4", type != "M5") %>%
  mutate(mut_origin = case_when(pop == "p1" & mut_popID == "1" ~ "Native",
                                pop == "p2" & mut_popID == "2" ~ "Native",
                                TRUE ~ "Introgressed")) %>%
  filter(gen == 10002) %>%
  filter(mut_freq > 0.9) %>%
  select(mutID, pop)  %>%
  mutate(early = "early") -> early_loci

out3 %>%
  filter(type != "M4", type != "M5") %>%
  mutate(mut_origin = case_when(pop == "p1" & mut_popID == "1" ~ "Native",
                                pop == "p2" & mut_popID == "2" ~ "Native",
                                TRUE ~ "Introgressed")) %>%
  full_join(.,early_loci) %>%
  filter(is.na(early)) %>%
  filter(gen == 10020 | gen == 10040 | gen == 10060 | gen == 10080 | gen == 10100) %>%
  filter(mut_freq > 0.5) %>%
  ggplot(.) +
  geom_violin(aes(x=mut_origin,y=mut_sel,fill=mut_origin)) + 
  geom_point(aes(x=mut_origin,y=mut_sel)) +
  facet_wrap(~gen)





out3 %>%
  full_join(.,mut_s) %>%
  filter(type != "M4", type != "M5") %>%
  mutate(mut_origin = case_when(pop == "p1" & mut_popID == "1" ~ "Native",
                                pop == "p2" & mut_popID == "2" ~ "Native",
                                TRUE ~ "Introgressed")) %>%
  mutate(unique_id = paste(mut_pos,".",mut_popID,sep="")) %>%
  mutate(type = case_when(type == "M1" ~ "QTL_loci",
                          TRUE ~ "RI_loci")) %>%
  mutate(pop = case_when(pop == "p1" ~ "Pop_1",
                         TRUE ~ "Pop_2")) %>%
  filter(mut_origin == "Native") %>%
  mutate(fitness_category = case_when(rel_fitness > 2 ~ "2+",
                                      rel_fitness >1 & rel_fitness <= 2 ~ "1 - 2",
                                      rel_fitness > 0.5 & rel_fitness <= 1 ~"0.5 - 1",
                                      rel_fitness > 0.1 & rel_fitness <= 0.5 ~ "0.1 - 0.5",
                                      rel_fitness > -0.1 & rel_fitness <= 0.1 ~ "-0.1 - 0.1",
                                      rel_fitness > -0.5 & rel_fitness <= -0.1 ~ "-0.5 - -0.1",
                                      rel_fitness <= 0.5 ~ "-0.5",
                                      TRUE ~ "NA")) %>%
  #filter(mut_freq > 0.1 & mut_freq < 0.9) %>%
  ggplot(.,aes(x=rel_fitness,y=mut_freq,group=mutID,color=mut_sel)) + 
  geom_point(alpha=0.5,size=2) +
  theme_few() + 
  scale_color_distiller(name="qtl_strength",palette = "RdBu",limits=c(-3.5,3.5)) +
  ylab("Allele frequency") + 
  xlab("s (fitness)") +
  theme(legend.position="bottom") +
  labs(tag = "B")

out3 %>%
  full_join(.,mut_s) %>%
  filter(gen >10002) %>%
  filter(type != "M4", type != "M5") %>%
  mutate(mut_origin = case_when(pop == "p1" & mut_popID == "1" ~ "Native",
                                pop == "p2" & mut_popID == "2" ~ "Native",
                                TRUE ~ "Introgressed")) %>%
  mutate(unique_id = paste(mut_pos,".",mut_popID,sep="")) %>%
  mutate(type = case_when(type == "M1" ~ "QTL_loci",
                          TRUE ~ "RI_loci")) %>%
  mutate(pop = case_when(pop == "p1" ~ "Pop_1",
                         TRUE ~ "Pop_2")) %>%
  filter(mut_origin == "Introgressed") %>%
  mutate(qtl_category = case_when(mut_sel < 0 ~"Negative",
                                  mut_sel > 2 ~ "Strongly Positive",
                                  mut_sel > 0 ~ "Positive",
                                  TRUE ~ "NA")) %>%
  #filter(mut_freq > 0.1 & mut_freq < 0.9) %>%
  #filter(mut_freq < 0.9) %>%
  ggplot(.,aes(x=rel_fitness,color=qtl_category,fill=qtl_category)) + 
  geom_density(alpha=0.5,size=2) +
  theme_few() + 
  scale_color_manual(name="QTL direction",values=c("#377EB8", "#FF7575","#B30C0C")) +
  scale_fill_manual(name="QTL direction",values=c("#377EB8", "#FF7575","#B30C0C")) +
  ylab("Density") + 
  xlab("s (fitness)") +
  theme(legend.position="bottom") +
  labs(tag = "B") +
  geom_vline(xintercept = 0,linetype="dotted")



out3 %>%
  full_join(.,mut_s) %>%
  filter(type != "M4", type != "M5") %>%
  mutate(mut_origin = case_when(pop == "p1" & mut_popID == "1" ~ "Native",
                                pop == "p2" & mut_popID == "2" ~ "Native",
                                TRUE ~ "Introgressed")) %>%
  mutate(unique_id = paste(mut_pos,".",mut_popID,sep="")) %>%
  mutate(type = case_when(type == "M1" ~ "QTL_loci",
                          TRUE ~ "RI_loci")) %>%
  mutate(pop = case_when(pop == "p1" ~ "Pop_1",
                         TRUE ~ "Pop_2")) %>%
  filter(mut_origin == "Introgressed") %>%
  group_by(mutID, pop) %>%
  mutate(meanfitness = mean(rel_fitness,na.rm=T)) %>%
  ggplot(.,aes(x=gen,y=mut_freq,group=mutID,color=meanfitness)) + 
  geom_line(alpha=0.7,size=2) +
  theme_few() + 
  scale_color_distiller(name="s",palette="RdBu") +
  facet_grid(pop~.) +
  ylab("Allele frequency") + 
  xlab("Generation") +
  theme(legend.position="bottom") +
  labs(tag = "B")


out3 %>%
  full_join(.,mut_s) %>%
  filter(type != "M4", type != "M5") %>%
  mutate(mut_origin = case_when(pop == "p1" & mut_popID == "1" ~ "Native",
                                pop == "p2" & mut_popID == "2" ~ "Native",
                                TRUE ~ "Introgressed")) %>%
  mutate(unique_id = paste(mut_pos,".",mut_popID,sep="")) %>%
  mutate(type = case_when(type == "M1" ~ "QTL_loci",
                          TRUE ~ "RI_loci")) %>%
  mutate(pop = case_when(pop == "p1" ~ "Pop_1",
                         TRUE ~ "Pop_2")) %>%
  group_by(mutID, pop) %>%
  mutate(meanfitness = mean(rel_fitness,na.rm=T)) %>%
  ggplot(.,aes(meanfitness)) + 
  geom_histogram(aes(fill=mut_origin),alpha=0.5,position="identity") +
  theme_few() +
  scale_color_brewer(name="s",palette="RdBu") 





pop_colors <- brewer.pal(5,"Set1")[c(3,5)]

plot_RI <- out2 %>%
  filter(gen != 1) %>%
  gather(pop,percent, p1_home:p2_home) %>% 
  ggplot(aes(x=gen,y=1-percent,color=pop)) + geom_line(size=3) +
  geom_line(aes(x=gen,y=fit_dif/max(fit_dif)),color="black",linetype="dotted",size=2) +
  theme_bw() + 
  scale_color_manual(values=pop_colors,name="Population",
                     labels=c("Pop_1", "Pop_2")) +
  xlab("Generation") +
  ylab("Introgressed ancestry") +
  theme(legend.position="bottom") +
  scale_y_continuous(sec.axis = sec_axis(~.,name="Reproductive isolation")) +
  labs(tag = "A")




plot_linkage <- out3 %>%
  mutate(mut_origin = case_when(pop == "p1" & mut_popID == "1" ~ "Native",
                                pop == "p2" & mut_popID == "2" ~ "Native",
                                TRUE ~ "Introgressed")) %>%
  mutate(unique_id = paste(mut_pos,".",mut_popID,sep="")) %>%
  mutate(type = case_when(type == "M1" ~ "QTL_loci",
                          TRUE ~ "RI_loci")) %>%
  mutate(pop = case_when(pop == "p1" ~ "Pop_1",
                         TRUE ~ "Pop_2")) %>%
  filter(mut_origin == "Introgressed") %>%
  filter(mut_sel > 0.5) %>%
  ggplot(.,aes(x=gen,y=mut_freq,group=mutID,color=as.factor(type))) + geom_line(alpha=0.4,size=1) +
  theme_few() + scale_color_brewer(name="Introgressed mutation type", palette = "Set1") +
  facet_grid(pop~.) +
  ylab("Allele frequency") + 
  xlab("Generation") +
  theme(legend.position="bottom") +
  labs(tag = "B")

pop_colors <- brewer.pal(5,"Set1")[c(3,5)]

plot_introgression <- out3 %>%
  filter(type != "M1") %>% 
  mutate(mut_origin = case_when(pop == "p1" & mut_popID == "1" ~ "Native",
                                pop == "p2" & mut_popID == "2" ~ "Native",
                                TRUE ~ "Introgressed")) %>%
  mutate(unique_id = paste(mut_pos,".",mut_popID,sep="")) %>%
  filter(gen %% 20 == 0 | gen == 10001) %>% 
  mutate(pop = case_when(pop == "p1" ~ "Pop_1",
                         TRUE ~ "Pop_2")) %>%
  filter(pop == "Pop_1" ) %>%
  ggplot(.) + geom_bar(aes(x=mut_pos,y=mut_freq,fill=as.factor(mut_popID)),stat="identity",position="stack") +
  geom_bar(data=out3 %>%
             filter(type != "M1") %>% 
             mutate(mut_origin = case_when(pop == "p1" & mut_popID == "1" ~ "Native",
                                           pop == "p2" & mut_popID == "2" ~ "Native",
                                           TRUE ~ "Introgressed")) %>%
             mutate(unique_id = paste(mut_pos,".",mut_popID,sep="")) %>%
             filter(gen %% 20 == 0 | gen == 10001) %>% 
             mutate(pop = case_when(pop == "p1" ~ "Pop_1",
                                    TRUE ~ "Pop_2")) %>%
             filter(pop == "Pop_2" ) %>%
             mutate(mut_popID = fct_rev(as.factor(mut_popID))),
           aes(x=mut_pos,y=-mut_freq,fill=as.factor(mut_popID)),stat="identity",position="stack") +
  theme_few() + scale_fill_manual(values = pop_colors,name="Neutral allele origin",
                                  labels=c("Pop_1", "Pop_2")) +
  facet_grid(.~gen) +
  geom_hline(yintercept=0) +
  ylab("Neutral allele frequency") +
  xlab("Position") +
  theme(axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.text.y=element_blank(),
        legend.position="bottom") +
  labs(tag = "C")


curve.fun <- function(x) {
  sin(3.141593 * x / 1000) * 5
}

plot_phenosum <- out3 %>%
  mutate(direction = case_when(mut_sel > 0 ~ "pos",
                               mut_sel < 0 ~ "neg")) %>%
  mutate(mut_origin = case_when(pop == "p1" & mut_popID == "1" ~ "Native",
                                pop == "p2" & mut_popID == "2" ~ "Native",
                                TRUE ~ "Introgressed")) %>%
  mutate(pop = case_when(pop == "p1" ~ "Pop_1",
                         TRUE ~ "Pop_2")) %>%
  group_by(pop,mut_origin,gen) %>%
  summarise(count=sum(mut_freq*mut_sel*2,na.rm=T)) %>% 
  ggplot(.,aes(x=gen,y=count)) + geom_bar(aes(x=gen,y=count,fill=as.factor(mut_origin)),stat="identity",position="stack") +
  scale_fill_manual(values=c("grey","black"),name="Mutation origin") +
  theme_few() + 
  geom_segment(aes(x=10000,xend=10100,y=0,yend=100),color=brewer.pal(3,"Set1")[1]) +
  facet_grid(pop~.) +
  xlab("Generation") +
  ylab("Phenotype")+
  theme(legend.position="bottom") +
  labs(tag = "D")





pdf("Documents/adaptive_introgression/example_sim_delta1.plots.v2.pdf",width=15,height=8)


grid.arrange( plot_RI,plot_introgression,plot_phenosum,plot_linkage,
              #nrow=3,
              top = textGrob("Example simulation, Delta = 1",gp=gpar(fontsize=20,font=2)),
              layout_matrix = rbind(c(1,4),
                                    c(2,3)))
dev.off()


#Back up plots
out3 %>%
  group_by(pop,mut_popID,gen) %>%
  summarise(representation=sum(mut_freq)) %>%
  ggplot(.,aes(x=gen,y=representation,color=pop,linetype=as.factor(mut_popID))) + geom_line() +
  theme_bw() + scale_color_brewer(palette = "Set1") +
  ylab("Summed mutation frequency")

out3 %>%
  mutate(direction = case_when(mut_sel > 0 ~ "pos",
                               mut_sel < 0 ~ "neg")) %>%
  group_by(pop,mut_popID,gen,direction) %>%
  summarise(count=sum(mut_freq)) %>% 
  spread(direction, count) %>%
  ggplot(.) + geom_bar(aes(x=gen,y=pos),stat="identity",fill=brewer.pal(3,"Set1")[1]) +
  geom_bar(aes(x=gen,y=-neg),stat="identity",fill=brewer.pal(3,"Set1")[2]) +
  theme_few() + 
  facet_grid(pop~mut_popID,labeller = label_both) +
  ggtitle("Mutation counts")

out3 %>%
  filter(type == "M1") %>% 
  filter(mut_freq > 0.01) %>%
  mutate(mut_uniqueID = paste(mut_pos,mut_popID,mut_sel)) %>% 
  ggplot(.,aes(x=gen,y=mut_freq,group=mut_uniqueID,color=mut_sel)) + geom_line(alpha=0.6) +
  theme_few() + scale_color_distiller(palette = "Spectral",name="Mutation Effect") +
  facet_grid(pop~mut_popID,labeller = label_both) +
  ggtitle("Mutation trajectory") +
  xlab("Generation") +ylab("Allele frequency")
