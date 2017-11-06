@Grab('org.apache.jena:jena-core:3.4.0')
@Grab('org.apache.jena:jena-arq:3.4.0')

/**
 * @author ippei
 *
 */

import groovy.xml.MarkupBuilder
import org.apache.jena.query.*

def Sparql_Endpoint="http://localhost:8080/fuseki/CTD-RDF/sparql"

// Init Template Engine
def engine = new groovy.text.GStringTemplateEngine()

// Get Study Metadata
def ProtocolId
def StudyDescription
def Sponsor
def StdVersion

def prefixed = new File('template/prefixes.sparql.template').getText()
def studyMetadata = new File('template/studyMetadata.sparql.template').getText()
def queryString = prefixed + studyMetadata
Query query = QueryFactory.create(queryString)
// Execute the query and obtain results
QueryExecution qe = QueryExecutionFactory.sparqlService(Sparql_Endpoint, query);
try {
    for (ResultSet rs = qe.execSelect(); rs.hasNext() ; ) {
        QuerySolution sol = rs.nextSolution()
        ProtocolId=sol.StudyId
        StudyDescription=sol.StudyDescription
        Sponsor=sol.Sponsor
        StdVersion=sol.StdVersion
    }
} finally {
	qe.close()
}


// Construct Other Metadata
def writer = new StringWriter()
def xml = new MarkupBuilder(writer)
xml.setOmitNullAttributes(true)
xml.setOmitEmptyAttributes(true)
xml.setDoubleQuotes(true)
xml.setEscapeAttributes(true)

def datasetList = ["DM","SUPPDM","VS"]

// Generate ItemGroupDef
def _DefineXml=""
for (i in datasetList) {
    def dsname
    if (i.size() > 4 && i[0..3]=="SUPP") {
        dsname=['Dataset':"SUPPQUAL"]
    }else{
        dsname=['Dataset':i]
    }
    def datasetMetadataTemplate = new File('template/datasetMetadata.sparql.template').getText()
    def datasetMetadataQuery = engine.createTemplate(datasetMetadataTemplate).make(dsname)
    def datasetMetadataQueryFactory = QueryFactory.create(prefixed + datasetMetadataQuery)
    QueryExecution datasetMetadataQE = QueryExecutionFactory.sparqlService(Sparql_Endpoint, datasetMetadataQueryFactory);

    // Get VariabeMetadata
    def variableMetadataTemplate = new File('template/variableMetadata.sparql.template').getText()
    def variableMetadataQuery = engine.createTemplate(variableMetadataTemplate).make(dsname)
    def variableMetadataQueryFactory = QueryFactory.create(prefixed + variableMetadataQuery)
    QueryExecution variableMetadataQE = QueryExecutionFactory.sparqlService(Sparql_Endpoint, variableMetadataQueryFactory);

    // Get VariabeMetadata for ItemDef
    def variableItemDefMetadataTemplate = new File('template/variableMetadata.sparql.template').getText()
    def variableItemDefMetadataQuery = engine.createTemplate(variableItemDefMetadataTemplate).make(dsname)
    def variableItemDefMetadataQueryFactory = QueryFactory.create(prefixed + variableItemDefMetadataQuery)
    QueryExecution variableItemDefMetadataQE = QueryExecutionFactory.sparqlService(Sparql_Endpoint, variableItemDefMetadataQueryFactory);

    _DefineXml <<= genItemGroupDef(datasetMetadataQE, variableMetadataQE, i)
}

// Get VariabeMetadata for ItemDef
for (i in datasetList) {
    def dsname
    if (i.size() > 4 && i[0..3]=="SUPP") {
        dsname=['Dataset':"SUPPQUAL"]
    }else{
        dsname=['Dataset':i]
    }
    def variableItemDefMetadataTemplate = new File('template/variableMetadata.sparql.template').getText()
    def variableItemDefMetadataQuery = engine.createTemplate(variableItemDefMetadataTemplate).make(dsname)
    def variableItemDefMetadataQueryFactory = QueryFactory.create(prefixed + variableItemDefMetadataQuery)
    QueryExecution variableItemDefMetadataQE = QueryExecutionFactory.sparqlService(Sparql_Endpoint, variableItemDefMetadataQueryFactory);

    _DefineXml <<= genItemDef(variableItemDefMetadataQE,i)
}

    // Construct CreationDataTime
    def CreationDateTime = new Date(System.currentTimeMillis()).format("yyyy-MM-dd'T'HH:mm:ss")
    def f = new File('template/define.xml.template')
    def binding = ['ProtocolId': ProtocolId,
                   'StudyDescription': StudyDescription,
                   'Sponsor': Sponsor,
                   'StdVersion': StdVersion,
                   'CreationDateTime': CreationDateTime,
                   'OtherMetadata': _DefineXml]
    def template = engine.createTemplate(f).make(binding)
    def fileWriter = new File('define.xml')
    fileWriter.write template.toString()


def genItemGroupDef(QueryExecution datasetMetadataQE, QueryExecution variableMetadataQE, String datasetName) {
        def writer = new StringWriter()
  		def xml = new MarkupBuilder(writer)
  		xml.setOmitNullAttributes(true)
  		xml.setOmitEmptyAttributes(true)
  		xml.setDoubleQuotes(true)
  		xml.setEscapeAttributes(true)
        for (ResultSet datasetResultset = datasetMetadataQE.execSelect(); datasetResultset.hasNext() ; ) {
            QuerySolution sol = datasetResultset.nextSolution()
            def dsname
            def dslabel
            if (sol.Domain.toString() == "SUPPQUAL") {
                dsname = datasetName
                dslabel = sol.DatasetLabel.toString() + " for " + datasetName.toString()
            }else{
                dsname = sol.Domain
                dslabel = sol.DatasetLabel
            }
            println sol.Domain.toString().length()
  		    xml.'ItemGroupDef'(
  				      'OID': "IG.${dsname}",
  				      'Name': dsname,
  				      'Domain': dsname,
  				      'SASDatasetName': dsname,
  				      'Repeating': "No",
  				      'IsReferenceData': "No",
                'Purpose': "Tabulation",
                'def:Structure': sol.Structure,
                'def:Class': sol.defClass,
                'def:CommentOID': "",
                'def:ArchiveLocationID': "LF.${dsname}"
  			) {
  				'Description'({'TranslatedText'('xml:lang':"en",  dslabel )})
                    for (ResultSet variableResultset = variableMetadataQE.execSelect(); variableResultset.hasNext() ; ) {
                        QuerySolution sol2 = variableResultset.nextSolution()
  						'ItemRef'(ItemOID: "IT.${datasetName}.${sol2.dataElementName}", OrderNumber: sol2.ordinal_, Mandatory: sol2.Core, KeySequence: "", MethodOID: "")
  					}
  					'def:leaf'('ID':"LF.${dsname}", 'xlink:href':"${dsname}.xpt".toLowerCase(), {'def:title'("${dsname}.xpt".toLowerCase())}
  					)
  				}
  		return(writer)
  	}
  }


  def genItemDef(QueryExecution variableItemDefMetadataQE, String datasetName) {
      def writer = new StringWriter()
      def xml = new MarkupBuilder(writer)
      xml.setOmitNullAttributes(true)
    		xml.setOmitEmptyAttributes(true)
    		xml.setDoubleQuotes(true)
    		xml.setEscapeAttributes(true)

            for (ResultSet variableItemDefResultset = variableItemDefMetadataQE.execSelect(); variableItemDefResultset.hasNext(); ) {
                QuerySolution solVarItem = variableItemDefResultset.nextSolution()
            xml.'ItemDef'(
  				'OID': "IT.${datasetName}.${solVarItem.dataElementName}",
  				'Name': solVarItem.dataElementName,
  				'SASFieldName': solVarItem.dataElementName,
  				'DataType': "",
  				'SignificantDigits': "",
  				'Length': "",
  				'def:DisplayFormat': "",
  				'def:CommentOID': ""
  				) {
  					'Description'({'TranslatedText'('xml:lang':"en",  solVarItem.dataElementLabel )})
  				}
            }

  		return(writer)
    }
