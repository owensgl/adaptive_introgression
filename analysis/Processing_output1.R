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
  
  system( paste("cd  ../output/",iteration,"/",parameter, "; ls | perl ../../../analysis/process_output1.pl | gzip > ../../../",iteration,".",parameter,".out1.txt.gz; cd ../../../analysis",sep=""))
  
  output1 <- read_tsv(paste("../",iteration,".",parameter,".out1.txt.gz",sep="")) %>%
    separate(.,filename,parameters,"_") %>%  
    group_by(.dots=parameter_full) %>% 
    top_n(.,(198*100),seed)
  
  pdf( paste("../",iteration,".",parameter,".out1.pdf",sep=""))
  print(
    output1 %>% 
      mutate_("parameter_chosen" = parameter_full) %>%
      mutate(parameter_chosen = as.numeric(parameter_chosen)) %>% 
      filter(version == "test") %>%
      ggplot(.,aes(x=gen,y=mean_haldane,group=seed,color=as.numeric(parameter_chosen))) + 
      geom_line(alpha=0.2) + theme_few() + 
      scale_color_distiller(palette = "Spectral",name=paste(parameter_full)) +
      ylab("Average Haldanes") + xlab("Generation")
  )
  dev.off()
  
}
