#Plotting for the august+ version of the output
library(tidyverse)

setwd("/home/owens/working/adaptive_introgression/")
parameters <- colnames(read_tsv("parameter_file.txt"))
parameters <- c("blank",parameters,"tail")
output2 <- list.files("output/august_15/", pattern = "out2")

data <- data_frame(filename = output2) %>% # create a data frame
  # holding the file names
  mutate(file_contents = map(filename,          # read files into
                             ~ read_tsv(file.path("output/august_15/", .))) # a new data column
  )  

unnest(data) %>%
  separate(.,filename,parameters,"_") ->output2_data

colnames(output2_data)[5:12] -> varying_parameters
#Find the middle parameter that is common amongst the replicates.
middle_parameter <- tibble(parameter=character(),value=numeric())
for (chosen_par in varying_parameters){
  output2_data %>% 
    group_by_(.dots= chosen_par) %>% 
    summarize(count = n()) %>% 
    arrange(desc(count)) %>% 
    head(n=1) %>% pull(chosen_par)-> tmp
  loading_tibble <- tibble(parameter=chosen_par,value=tmp)
  middle_parameter <- rbind(middle_parameter, loading_tibble)
}

middle_parameter

pdf("Preliminary_august_simulations.pdf",height=10,width=10)
output2_data %>% filter(blank == "output",
                  #      delta = 1,
                        div_sel_n == 100, 
                        div_sel_s == 0.009, 
                        fitness_sd == 2, 
                        m == 0.01,
                        mutation_rate == 1e-07,
                        pop_size == 1000, 
                        qtl_sd == 1) %>% 
  group_by(delta, seed) %>%
  summarize(burn_in_purity = (p1home[which(version == "burn_in")] + p2home[which(version == "burn_in")])/2,
            test_purity = (p1home[which(version == "test")] + p2home[which(version == "test")])/2,
            control_purity = (p1home[which(version == "control")] + p2home[which(version == "control")])/2) %>%
  mutate(test_change = burn_in_purity - test_purity,
         control_change = burn_in_purity - control_purity) %>% 
  gather(., version, purity_change, c(test_change,control_change)) %>%
  ungroup() %>%
  mutate(delta = as.numeric(delta)) %>%
  ggplot(.) + geom_point(aes(x=delta,y=purity_change,color=version),alpha=0.1) +
    scale_color_brewer(palette = "Set1") + theme_bw() +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))

  


output2_data %>% filter(blank == "output",
                        delta == 1,
                        div_sel_n == 100, 
                        #div_sel_s == 0.009, 
                        fitness_sd == 2, 
                        m == 0.01,
                        mutation_rate == 1e-07,
                        pop_size == 1000, 
                        qtl_sd == 1) %>% 
  group_by(div_sel_s, seed) %>% 
  summarize(burn_in_purity = (p1home[which(version == "burn_in")] + p2home[which(version == "burn_in")])/2,
            test_purity = (p1home[which(version == "test")] + p2home[which(version == "test")])/2,
            control_purity = (p1home[which(version == "control")] + p2home[which(version == "control")])/2) %>%
  mutate(test_change = burn_in_purity - test_purity,
         control_change = burn_in_purity - control_purity) %>% 
  gather(., version, purity_change, c(test_change,control_change)) %>%
  ungroup() %>%
  mutate(div_sel_s = as.numeric(div_sel_s)) %>%
  ggplot(.) + geom_point(aes(x=div_sel_s,y=purity_change,color=version),alpha=0.1) +
  scale_color_brewer(palette = "Set1") + theme_bw() + 
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))



output2_data %>% filter(blank == "output",
                        delta == 1,
                        div_sel_n == 100, 
                        div_sel_s == 0.009, 
                        fitness_sd == 2, 
                        #m == 0.01,
                        mutation_rate == 1e-07,
                        pop_size == 1000, 
                        qtl_sd == 1) %>% 
  group_by(m, seed) %>% 
  summarize(burn_in_purity = (p1home[which(version == "burn_in")] + p2home[which(version == "burn_in")])/2,
            test_purity = (p1home[which(version == "test")] + p2home[which(version == "test")])/2,
            control_purity = (p1home[which(version == "control")] + p2home[which(version == "control")])/2) %>%
  mutate(test_change = burn_in_purity - test_purity,
         control_change = burn_in_purity - control_purity) %>% 
  gather(., version, purity_change, c(test_change,control_change)) %>%
  ungroup() %>%
  mutate(m = as.numeric(m)) %>%
  ggplot(.) + geom_point(aes(x=m,y=purity_change,color=version),alpha=0.1) +
  scale_color_brewer(palette = "Set1") + theme_bw() +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))

output2_data %>% filter(blank == "output",
                        delta == 1,
                        div_sel_n == 100, 
                        div_sel_s == 0.009, 
                        fitness_sd == 2, 
                        m == 0.01,
                        #mutation_rate == 1e-07,
                        pop_size == 1000, 
                        qtl_sd == 1) %>% 
  group_by(mutation_rate, seed) %>% 
  summarize(burn_in_purity = (p1home[which(version == "burn_in")] + p2home[which(version == "burn_in")])/2,
            test_purity = (p1home[which(version == "test")] + p2home[which(version == "test")])/2,
            control_purity = (p1home[which(version == "control")] + p2home[which(version == "control")])/2) %>%
  mutate(test_change = burn_in_purity - test_purity,
         control_change = burn_in_purity - control_purity) %>% 
  gather(., version, purity_change, c(test_change,control_change)) %>% 
  ungroup() %>%
  mutate(mutation_rate = as.numeric(mutation_rate)) %>% 
  ggplot(.,aes(x=mutation_rate,y=purity_change,color=version)) + geom_point(alpha=0.1) +
  scale_color_brewer(palette = "Set1") + theme_bw() +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))


output2_data %>% filter(blank == "output",
                        delta == 1,
                        div_sel_n == 100, 
                        div_sel_s == 0.009, 
                        fitness_sd == 2, 
                        m == 0.01,
                        mutation_rate == 1e-07,
                        pop_size == 1000) %>%
                        #qtl_sd == 1
  group_by(qtl_sd, seed) %>% 
  summarize(burn_in_purity = (p1home[which(version == "burn_in")] + p2home[which(version == "burn_in")])/2,
            test_purity = (p1home[which(version == "test")] + p2home[which(version == "test")])/2,
            control_purity = (p1home[which(version == "control")] + p2home[which(version == "control")])/2) %>%
  mutate(test_change = burn_in_purity - test_purity,
         control_change = burn_in_purity - control_purity) %>% 
  gather(., version, purity_change, c(test_change,control_change)) %>%
  ungroup()  %>%
  mutate(qtl_sd = as.numeric(qtl_sd)) %>%
  ggplot(.) + geom_point(aes(x=qtl_sd,y=purity_change,color=version),alpha=0.1) +
  scale_color_brewer(palette = "Set1") + theme_bw() +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))

dev.off()
