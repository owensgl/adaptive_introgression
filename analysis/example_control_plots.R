library(tidyverse)
library(RColorBrewer)
library(ggthemes)
library(grid)
library(gridExtra)
out3 <- read_tsv("Documents/adaptive_introgression/example_sim_jan29_control_out3.txt",
                 col_names = c("spacer","version","type", "gen","pop","mut_pos",
                               "mut_popID","mut_freq","mut_sel")) %>%
  filter(gen > 1)

out2 <- read_tsv("Documents/adaptive_introgression/example_sim_jan29_control_out2.txt",
                 col_names = c("spacer","version","gen","p1_home","p2_home",
                               "fit_dif","spacer2")) %>%
  filter(gen > 1)


pop_colors <- brewer.pal(5,"Set1")[c(3,5)]
plot_RI <- out2 %>%
  filter(gen != 1) %>%
  gather(pop,percent, p1_home:p2_home) %>% 
  ggplot(aes(x=gen,y=1-percent,color=pop)) + geom_line(size=3) +
  geom_line(aes(x=gen,y=fit_dif),color="black",linetype="dotted",size=2) +
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
  ggplot(.,aes(x=gen,y=mut_freq,group=unique_id,color=as.factor(type))) + geom_line(alpha=0.4,size=1) +
  theme_few() + scale_color_brewer(name="Introgressed mutation type", palette = "Set1") +
  facet_grid(pop~.) +
  ylab("Allele frequency") + 
  xlab("Generation") +
  theme(legend.position="bottom") +
  labs(tag = "B") +
  coord_cartesian(ylim=c(0,1))


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
  stat_function(aes(x=gen),fun = curve.fun,color=brewer.pal(3,"Set1")[1]) +
  facet_grid(pop~.) +
  xlab("Generation") +
  ylab("Phenotype")+
  theme(legend.position="bottom") +
  labs(tag = "D")




pdf("Documents/adaptive_introgression/example_sim_control.plots.v2.pdf",width=15,height=8)


grid.arrange( plot_RI,plot_introgression,plot_phenosum,plot_linkage,
              #nrow=3,
              top = textGrob("Example simulation, Control",gp=gpar(fontsize=20,font=2)),
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
