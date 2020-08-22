library("pheatmap")

# input data
x <- read.table("Data/dffig_clustering", sep = "\t", header = T, row.names = 1)
x <- as.matrix(x)

# legends
samplename <- c("i1_Thio", "i2_Thio", "o1_Thio", "o2_Thio",
                "i1_Met", "i2_Met", "o1_Met", "o2_Met",
                "i1_Sul", "i2_Sul", "o1_Sul", "o2_Sul")

annotation_col = data.frame(
  "stabilization_method" = factor(rep(c("in situ", "onboard"), 3, each=2)),
  taxa = factor(rep(c("Thiotrichales", "Methylococcales", "Sulfurovum"), each=4))
)

rownames(annotation_col) = paste(samplename)

# annotation colors
ann_colors = list(
  "stabilization_method" = c(
      "in situ" = "#23415a", 
      "onboard" = "#87ceff"
  ),
  taxa 　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　= c(
      Thiotrichales      = "#ffc125", 
      Methylococcales  = "#7b68ee", 
      Sulfurovum        = "#ff7f24"
  )
)

# figure
par(mfrow=c(1,1), pin = c(10,10)) 

pheatmap(
  x, scale = "column", clustering_distance_rows = "correlation",
  annotation_col = annotation_col, annotation_colors = ann_colors,
  cellwidth = 15, cellheight = 7, fontsize_row = 7
)