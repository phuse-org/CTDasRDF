library(network3d)

# Set working directory to the root of the work area
setwd("C:/_github/CTDasRDF")

edges <- read.csv2("r/edges.csv",
   fileEncoding="UTF-8-BOM" , header=TRUE, sep=",")

vertices <- read.csv2("r/vertices.csv",
   fileEncoding="UTF-8-BOM" , header=TRUE, sep=",")

network3d(vertices, edges, 
          node_outline_black = TRUE,
          max_iterations = 75,
          manybody_strength = 0.5, 
          background_color = "black",
          # edge_color = "#94e5ff",
          edge_color = "white",
          edge_opacity = 1,
          force_explorer = TRUE
          )
