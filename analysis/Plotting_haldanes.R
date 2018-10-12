library(tidyverse)
library(ggthemes)
library(forcats)
#output1 <- read_tsv("../sept24.out1.txt.gz")
pdf("sept24_haldanes.v1.pdf")
###Migration rate
output1 %>%
  filter(target_param == "m") %>%
  filter(generation > 10002) %>%
  filter(version == "test") %>% 
  filter(!is.na(mean_haldane)) %>%
  group_by(generation, m) %>%
  summarize(average_haldane = mean(mean_haldane)) %>% 
  ggplot(.,aes(x=generation,y=average_haldane,group=m,color=as.numeric(m))) + 
  geom_line(alpha=0.2) + theme_few() + 
  scale_color_distiller(palette = "Spectral",name="Migration rate") +
  ylab("Average Haldanes") + xlab("Generation")


output1 %>%
  filter(target_param == "m") %>%
  filter(generation > 10002) %>%
  filter(version == "test") %>% 
  ggplot(.,aes(x=generation,y=mean_haldane,group=seed,color=as.numeric(m))) + 
  geom_line(alpha=0.1) + theme_few() + 
  scale_color_distiller(palette = "Spectral",name="Migration rate") +
  ylab("Haldanes") + xlab("Generation")


output1 %>%
  filter(target_param == "m") %>%
  filter(generation > 10002) %>%
  filter(version == "test") %>% 
  filter(!is.na(mean_haldane)) %>% 
  ggplot(.,aes(x=fct_reorder(as.factor(m),as.numeric(m)),y=mean_haldane,color=as.numeric(m))) + 
  geom_violin() + theme_few() + 
  scale_color_distiller(palette = "Spectral",name="Migration rate") +
  ylab("Haldanes") + xlab("Migration rate")


####Total divergent selection

output1 %>%
  filter(target_param == "total-div") %>% 
  filter(generation > 10002) %>%
  filter(version == "test") %>% 
  filter(!is.na(mean_haldane)) %>%
  group_by(generation, total_div) %>%
  summarize(average_haldane = mean(mean_haldane)) %>% 
  ggplot(.,aes(x=generation,y=average_haldane,group=total_div,color=as.numeric(total_div))) + 
  geom_line(alpha=0.2) + theme_few() + 
  scale_color_distiller(palette = "Spectral",name="Divergent selection") +
  ylab("Average Haldanes") + xlab("Generation")


output1 %>%
  filter(target_param == "total-div") %>%
  filter(generation > 10002) %>%
  filter(version == "test") %>% 
  ggplot(.,aes(x=generation,y=mean_haldane,group=seed,color=as.numeric(total_div))) + 
  geom_line(alpha=0.1) + theme_few() + 
  scale_color_distiller(palette = "Spectral",name="Divergent selection") +
  ylab("Haldanes") + xlab("Generation")


output1 %>%
  filter(target_param == "total-div") %>%
  filter(generation > 10002) %>%
  filter(version == "test") %>% 
  filter(!is.na(mean_haldane)) %>%
  ggplot(.,aes(x=fct_reorder(as.factor(total_div),as.numeric(total_div)),y=mean_haldane,color=as.numeric(total_div))) + 
  geom_violin() + theme_few() + 
  scale_color_distiller(palette = "Spectral",name="Divergent selection") +
  ylab("Haldanes") + xlab("Total divergent selection")

####QTL SD

output1 %>%
  filter(target_param == "qtl-sd") %>% 
  filter(generation > 10002) %>%
  filter(version == "test") %>% 
  filter(!is.na(mean_haldane)) %>%
  group_by(generation, qtl_sd) %>%
  summarize(average_haldane = mean(mean_haldane)) %>% 
  ggplot(.,aes(x=generation,y=average_haldane,group=qtl_sd,color=as.numeric(qtl_sd))) + 
  geom_line(alpha=0.2) + theme_few() + 
  scale_color_distiller(palette = "Spectral",name="QTL size") +
  ylab("Average Haldanes") + xlab("Generation")


output1 %>%
  filter(target_param == "qtl-sd") %>%
  filter(generation > 10002) %>%
  filter(version == "test") %>% 
  ggplot(.,aes(x=generation,y=mean_haldane,group=seed,color=as.numeric(qtl_sd))) + 
  geom_line(alpha=0.1) + theme_few() + 
  scale_color_distiller(palette = "Spectral",name="QTL size") +
  ylab("Haldanes") + xlab("Generation")


output1 %>%
  filter(target_param == "qtl-sd") %>%
  filter(generation > 10002) %>%
  filter(version == "test") %>% 
  filter(!is.na(mean_haldane)) %>%
  ggplot(.,aes(x=fct_reorder(as.factor(qtl_sd),as.numeric(qtl_sd)),y=mean_haldane,color=as.numeric(qtl_sd))) + 
  geom_violin() + theme_few() + 
  scale_color_distiller(palette = "Spectral",name="QTL size") +
  ylab("Haldanes") + xlab("QTL SD")

####Mutation Rate

output1 %>%
  filter(target_param == "mutation-rate") %>% 
  filter(generation > 10002) %>%
  filter(version == "test") %>% 
  filter(!is.na(mean_haldane)) %>%
  group_by(generation, mutation_rate) %>%
  summarize(average_haldane = mean(mean_haldane)) %>% 
  ggplot(.,aes(x=generation,y=average_haldane,group=mutation_rate,color=as.numeric(mutation_rate))) + 
  geom_line(alpha=0.2) + theme_few() + 
  scale_color_distiller(palette = "Spectral",name="Mutation Rate") +
  ylab("Average Haldanes") + xlab("Generation")


output1 %>%
  filter(target_param == "mutation-rate") %>%
  filter(generation > 10002) %>%
  filter(version == "test") %>% 
  ggplot(.,aes(x=generation,y=mean_haldane,group=seed,color=as.numeric(mutation_rate))) + 
  geom_line(alpha=0.1) + theme_few() + 
  scale_color_distiller(palette = "Spectral",name="Mutation Rate") +
  ylab("Haldanes") + xlab("Generation")


output1 %>%
  filter(target_param == "mutation-rate") %>%
  filter(generation > 10002) %>%
  filter(version == "test") %>% 
  filter(!is.na(mean_haldane)) %>%
  ggplot(.,aes(x=fct_reorder(as.factor(mutation_rate),as.numeric(mutation_rate)),y=mean_haldane,color=as.numeric(mutation_rate))) + 
  geom_violin() + theme_few() + 
  scale_color_distiller(palette = "Spectral",name="Mutation Rate") +
  ylab("Haldanes") + xlab("Mutation rate")

####Delta

output1 %>%
  filter(target_param == "delta") %>% 
  filter(generation > 10002) %>%
  filter(version == "test") %>% 
  filter(!is.na(mean_haldane)) %>%
  group_by(generation, delta) %>%
  summarize(average_haldane = mean(mean_haldane)) %>% 
  ggplot(.,aes(x=generation,y=average_haldane,group=delta,color=as.numeric(delta))) + 
  geom_line(alpha=0.2) + theme_few() + 
  scale_color_distiller(palette = "Spectral",name="Delta") +
  ylab("Average Haldanes") + xlab("Generation")

#Too BIG!
# output1 %>%
#   filter(target_param == "delta") %>%
#   filter(generation > 10002) %>%
#   filter(version == "test") %>% 
#   ggplot(.,aes(x=generation,y=mean_haldane,group=seed,color=as.numeric(delta))) + 
#   geom_line(alpha=0.1) + theme_few() + 
#   scale_color_distiller(palette = "Spectral",name="Delta") +
#   xlab("Haldanes") + ylab("Generation")


output1 %>%
  filter(target_param == "delta") %>%
  filter(generation > 10002) %>%
  filter(version == "test") %>% 
  filter(!is.na(mean_haldane)) %>%
  ggplot(.,aes(x=fct_reorder(as.factor(delta),as.numeric(delta)),y=mean_haldane,color=as.numeric(delta))) + 
  geom_violin() + theme_few() + 
  scale_color_distiller(palette = "Spectral",name="Delta") +
  ylab("Haldanes") + xlab("Delta")

dev.off()
