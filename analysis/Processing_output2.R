library(tidyverse)
library(ggthemes)
library(forcats)

###Measuring introgression
iteration <- "nov5"
#Not run divseln
parameter <- "divseln"
parameters_tested <- c("totaldiv","delta","mutationrate","qtlsd","m","divseln")

for (parameter in parameters_tested){

  parameters <- colnames(read_tsv("../parameter_file.txt"))
  parameters <- c("blank","target_param",parameters,"tail")
  parameter_full <- parameter
  parameter_full <- gsub("totaldiv","total_div",parameter_full)
  parameter_full <- gsub("mutationrate","mutation_rate",parameter_full)
  parameter_full <- gsub("qtlsd","qtl_sd",parameter_full)
  parameter_full <- gsub("divseln","div_sel_n",parameter_full)
  
  system( paste("cd  ../output/",iteration,"/",parameter, "; ls | perl ../../../analysis/process_output2.pl | gzip > ../../../",iteration,".",parameter,".out2.txt.gz; cd ../../../analysis",sep=""))
  
  output2 <- read_tsv(paste("../",iteration,".",parameter,".out2.txt.gz",sep="")) %>%
    separate(.,filename,parameters,"_") %>%
    group_by(.dots=parameter_full) %>% 
    top_n(.,(100*2),seed) 

  

  
  
  pdf( paste("../",iteration,".",parameter,".out2.pdf",sep=""))
  print(
  output2 %>% 
    mutate_("parameter_chosen" = parameter_full) %>%
    mutate(parameter_chosen = as.numeric(parameter_chosen)) %>%
    ggplot(.) + geom_point(aes(x=parameter_chosen,y=purity_change,color=version),alpha=0.2) +
    scale_color_brewer(palette = "Set1",name="Version",labels=c("Control", "Climate change")) + theme_bw() +
    theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1)) +
    geom_hline(yintercept=0) +
    xlab(parameter_full) +
    ylab("Purity change")
  )
  dev.off()
  
}
  