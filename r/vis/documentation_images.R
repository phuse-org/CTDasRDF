###############################################################################
# FILE: documentation_images.R
# DESC: Created images used for documentation, e.g. in HandsOnCTDasRDF.rmd
# SRC :
# IN  : 
# OUT : 
# REQ : 
# SRC : 
# NOTE: 
# TODO: 
# DATE: 2018-10-17
# BY  : KG
###############################################################################

###############################################################################
#
# License: MIT
#
# Copyright (c) 2018 PhUSE CTDasRDF Project
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
# documentation files (the "Software"), to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
# to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of
# the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
# THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
###############################################################################


# for HandsOnCTDasRDF.rmd "Step Overview"

library("Rgraphviz")
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

plot(roadmapGraph, attrs=list(node=list(label="foo", fillcolor="lightgreen", 
                                        fontsize=18, shape="box", width="1.5"),
                              graph=list(rankdir="LR")), main = "Figure 1: Step overview")