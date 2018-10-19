# alternative
#https://datastorm-open.github.io/visNetwork/

#http://www.bioconductor.org/install/
#http://www.bioconductor.org/packages/release/BiocViews.html#___Software

# source("https://bioconductor.org/biocLite.R")
# biocLite()
# 
# ## try http:// if https:// URLs are not supported
# source("https://bioconductor.org/biocLite.R")
# biocLite("Rgraphviz")
# 
# biocValid()
# 
# #package documentation:
# browseVignettes("Rgraphviz")


library("Rgraphviz")


set.seed(123)
V <- letters[1:10]
M <- 1:4
g1 <- randomGraph(V, M, 0.2)

plot(g1)


rEG <- new("graphNEL", nodes=c("A", "B"), edgemode="directed")
rEG <- addEdge("A", "B", rEG, 1)
rEG <- addEdge("B", "A", rEG, 1)
plot(rEG)

#Node Labels
z <- strsplit(packageDescription("Rgraphviz")$Description, " ")[[1]]
z <- z[1:numNodes(g1)]
names(z) = nodes(g1)
nAttrs <- list()
nAttrs$label <- z
eAttrs <- list()
eAttrs$label <- c("a~h"="Label 1", "c~h"="Label 2")
attrs <- list(node=list(shape="ellipse", fixedsize=FALSE))
plot(g1, nodeAttrs=nAttrs, edgeAttrs=eAttrs, attrs=attrs)


#Create My Graph
myGraph <- new("graphNEL", nodes=c("Subject", "Study", "Site", "Activities", "Protocol", "Rules"), edgemode="directed")
myGraph <- addEdge("Study", "Subject", myGraph, 1)
myGraph <- addEdge("Study", "Site", myGraph, 1)
myGraph <- addEdge("Study", "Protocol", myGraph, 1)
myGraph <- addEdge("Study", "Activities", myGraph, 1)
myGraph <- addEdge("Activities", "Rules", myGraph, 1)
myGraph <- addEdge("Protocol", "Rules", myGraph, 1)
myGraph <- addNode("Dummy", myGraph)
myEAttrs <- list()
myEAttrs$label <- c("Study~Subject"="Participates in", "Study~Site"="has")
plot(myGraph, edgeAttrs=myEAttrs)

png(filename="example_graphViz.png")
plot(myGraph, edgeAttrs=myEAttrs, attrs=list(node=list(label="foo", fillcolor="lightgreen", 
                                                       fontsize=12, shape="box", width="1.5"),
                                             graph=list(rankdir="LR")), main = "Figure 1: Step overview")
dev.off()


roadmapGraph <- new("graphNEL", nodes=c("Installation", 
                                        "Setup Stardog", 
                                        "Create Data \\\n(R)",
                                        "Load Data \\\n(Stardog)",
                                        "Query Data \\\n(Stardog/R)"), 
                    edgemode="directed")

roadmapGraph <- addEdge("Installation", "Setup Stardog", roadmapGraph, 1)
roadmapGraph <- addEdge("Setup Stardog", "Create Data \\\n(R)", roadmapGraph, 1)
roadmapGraph <- addEdge("Create Data \\\n(R)", "Load Data \\\n(Stardog)", roadmapGraph, 1)
roadmapGraph <- addEdge("Load Data \\\n(Stardog)", "Query Data \\\n(Stardog/R)", roadmapGraph, 1)
roadmapGraph <- addEdge("Setup Stardog", "Load Data \\\n(Stardog)", roadmapGraph, 1)
#plot(roadmapGraph)

plot(roadmapGraph, attrs=list(node=list(label="foo", fillcolor="lightgreen", 
                                        fontsize=18, shape="box", width="1.5"),
                              graph=list(rankdir="LR")), main = "Figure 1: Step overview")

#nodeRenderInfo(roadmapGraph) <- list(shape="box")
graph.par(list(nodes=list(fontsize=24)))
roadmapGraph <- layoutGraph(roadmapGraph)
renderGraph(roadmapGraph)


z <- getDefaultAttrs()
checkAttrs(z)

