library(datapack)


dp <- new("DataPackage")
data <- charToRaw("1,2,3\n4,5,6")
do <- new("DataObject", id="do1", dataobj=data, format="text/csv", user="jsmith")
dp <- addMember(dp, do)
data2 <- charToRaw("7,8,9\n10,11,12")
do2 <- new("DataObject", id="do2", dataobj=data2, format="text/csv", user="jsmith")
dp <- addMember(dp, do2)
dp <- describeWorkflow(dp, sources=do, derivations=do2)
## Not run:
td <- "C:/temp"
status <- serializePackage(dp, file=paste(td, "resmap.ttl", sep="/"), syntaxName="turtle",
mimeType="text/turtle")