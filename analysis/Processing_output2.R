library(tidyverse)
library(ggthemes)
library(forcats)
library(grid)
library(gridExtra)

###Measuring introgression
iteration <- "nov20"
#Not run divseln
parameter <- "qtlsd"
parameters_tested <- c("totaldiv","delta","mutationrate","qtlsd","m","divseln")

plots <- list()
plots_RI <- list()
for (n in 1:length(parameters_tested)){
  parameter <- parameters_tested[n]
  parameters <- colnames(read_tsv("../parameter_file.txt"))
  parameters <- c("blank","target_param",parameters,"tail")
  parameter_full <- parameter
  parameter_full <- gsub("totaldiv","total_div",parameter_full)
  parameter_full <- gsub("mutationrate","mutation_rate",parameter_full)
  parameter_full <- gsub("qtlsd","qtl_sd",parameter_full)
  parameter_full <- gsub("divseln","div_sel_n",parameter_full)
  
  parameter_print <- parameter
  parameter_print <- gsub("totaldiv","Total divergent selection",parameter_print)
  parameter_print <- gsub("mutationrate","Mutation rate",parameter_print)
  parameter_print <- gsub("qtlsd","QTL Stdev",parameter_print)
  parameter_print <- gsub("divseln","RI loci",parameter_print)
  parameter_print <- gsub("delta","Delta",parameter_print)
  parameter_print <- gsub("m","Migration rate",parameter_print)
  
  
  #system( paste("cd  ../output/",iteration,"/",parameter, "; ls | perl ../../../analysis/process_output2.pl | gzip > ../../../",iteration,".",parameter,".out2.txt.gz; cd ../../../analysis",sep=""))
  
  output2 <- read_tsv(paste("../",iteration,".",parameter,".out2.txt.gz",sep="")) %>%
    separate(.,filename,parameters,"_") %>%
    group_by(.dots=parameter_full) %>% 
    top_n(.,(100*2),seed) 

  

  
  
  #pdf( paste("../",iteration,".",parameter,".out2.pdf",sep=""))

  plot_dot <- output2 %>% mutate_("parameter_chosen" = parameter_full) %>%
    mutate(parameter_chosen = as.numeric(parameter_chosen)) %>%
    ggplot(.) + geom_point(aes(x=parameter_chosen,y=purity_change,color=version),alpha=0.2) +
    scale_color_brewer(palette = "Set1",name="Version",labels=c("Control", "Climate change")) + theme_bw() +
    theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1)) +
    geom_hline(yintercept=0) +
    xlab(parameter_print) +
    ylab("Additional introgression") +
    labs(tag = LETTERS[n])

  plots[[n]] <- plot_dot
  
  plot_dot_RI <- output2 %>% mutate_("parameter_chosen" = parameter_full) %>%
    mutate(parameter_chosen = as.numeric(parameter_chosen)) %>%
    ggplot(.) + geom_point(aes(x=parameter_chosen,y=fit_change,color=version),alpha=0.2) +
    scale_color_brewer(palette = "Set1",name="Version",labels=c("Control", "Climate change")) + theme_bw() +
    theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1)) +
    geom_hline(yintercept=0) +
    xlab(parameter_print) +
    ylab("RI loss") +
    labs(tag = LETTERS[n])
  
  plots_RI[[n]] <- plot_dot_RI
  
  
  
}
pdf(paste("../figures/",iteration,".points.out2.pdf",sep=""),width=12,height=6)

grid.arrange( plots[[1]],plots[[2]],
              plots[[3]],plots[[4]],
              plots[[5]],plots[[6]],
              # top = textGrob("Haldane Values",gp=gpar(fontsize=20,font=2)),
              layout_matrix = rbind(c(1,2,3),
                                    c(4,5,6)))
dev.off()

pdf(paste("../figures/",iteration,".points.out2RI.pdf",sep=""),width=12,height=6)

grid.arrange( plots_RI[[1]],plots_RI[[2]],
              plots_RI[[3]],plots_RI[[4]],
              plots_RI[[5]],plots_RI[[6]],
              # top = textGrob("Haldane Values",gp=gpar(fontsize=20,font=2)),
              layout_matrix = rbind(c(1,2,3),
                                    c(4,5,6)))
dev.off()
  