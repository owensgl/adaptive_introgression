library(tidyverse)
library(ggthemes)
library(forcats)

###Calculating haldanes
output2 <- list.files("../output/sep24/", pattern = "out2") 

data2 <- data_frame(filename = output2) %>% # create a data frame
  mutate(file_contents = map(filename,          # read files into
                             ~ read_tsv(file.path("../output/sep24/", .)) %>%
                               mutate(purity = (p1home + p2home)/2) %>%
                               select(-p1home,-p2home,-fit_dif) %>%
                               spread(version,purity) %>% 
                               mutate(test = if ("test" %in% names(.)){return(test)}else{return(NA)}) %>% 
                               mutate(test_change = burn_in - test,
                                      control_change = burn_in - control) %>% 
                               gather(., version, purity_change, c(test_change,control_change)))
  )  

parameters <- colnames(read_tsv("../parameter_file.txt"))
parameters <- c("blank","target_param",parameters,"tail")

unnest(data2) %>%
  separate(.,filename,parameters,"_") ->output2



write_tsv(output2, "../sept24.out2.txt.gz")