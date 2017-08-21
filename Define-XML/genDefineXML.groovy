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


// Get DatasetMetadata
def datasetMetadataTemplate = new File('template/datasetMetadata.sparql.template').getText()
def dsname = ['Dataset': "DM"]
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

def _DefineXml = genItemGroupDef(datasetMetadataQE, variableMetadataQE)
_DefineXml <<= genItemDef(variableMetadataQE)

    // Construct CreationDataTime
    def CreationDateTime = new Date(System.currentTimeMillis()).format("yyyy-MM-dd'T'HH:mm:ss")
    def f = new File('template/define.xml.template')
    //def engine = new groovy.text.GStringTemplateEngine()
    def binding = ['ProtocolId': ProtocolId,
                   'StudyDescription': StudyDescription,
                   'Sponsor': Sponsor,
                   'StdVersion': StdVersion,
                   'CreationDateTime': CreationDateTime,
                   'OtherMetadata': _DefineXml]
    def template = engine.createTemplate(f).make(binding)
    def fileWriter = new File('define.xml')
    fileWriter.write template.toString()


def genItemGroupDef(QueryExecution datasetMetadataQE, QueryExecution variableMetadataQE) {
        def writer = new StringWriter()
  		def xml = new MarkupBuilder(writer)
  		xml.setOmitNullAttributes(true)
  		xml.setOmitEmptyAttributes(true)
  		xml.setDoubleQuotes(true)
  		xml.setEscapeAttributes(true)
        for (ResultSet datasetResultset = datasetMetadataQE.execSelect(); datasetResultset.hasNext() ; ) {
            QuerySolution sol = datasetResultset.nextSolution()
  		    xml.'ItemGroupDef'(
  				      'OID': "IG.${sol.Domain}",
  				      'Name': sol.Domain,
  				      'Domain': sol.Domain,
  				      'SASDatasetName': sol.Domain,
  				      'Repeating': "No",
  				      'IsReferenceData': "No",
                'Purpose': "Tabulation",
                'def:Structure': sol.Structure,
                'def:Class': sol.defClass,
                'def:CommentOID': "",
                'def:ArchiveLocationID': "LF.${sol.Domain}"
  			) {
  				'Description'({'TranslatedText'('xml:lang':"en",  sol.DatasetLabel )})
                    for (ResultSet variableResultset = variableMetadataQE.execSelect(); variableResultset.hasNext() ; ) {
                        QuerySolution sol2 = variableResultset.nextSolution()
  						'ItemRef'(ItemOID: "IT.DM.${sol2.dataElementName}", OrderNumber: sol2.ordinal_, Mandatory: sol2.Core, KeySequence: "", MethodOID: "")
  					}
  					'def:leaf'('ID':"LF.${sol.Domain}", 'xlink:href':"${sol.Domain}.xpt".toLowerCase(), {'def:title'("${sol.Domain}.xpt".toLowerCase())}
  					)
  				}
  		return(writer)
  	}
  }


  def genItemDef(QueryExecution variableItemDefMetadataQE) {
      def writer = new StringWriter()
      def xml = new MarkupBuilder(writer)
      xml.setOmitNullAttributes(true)
    		xml.setOmitEmptyAttributes(true)
    		xml.setDoubleQuotes(true)
    		xml.setEscapeAttributes(true)

            for (ResultSet variableItemDefResultset = variableItemDefMetadataQE.execSelect(); variableItemDefResultset.hasNext(); ) {
                QuerySolution solVarItem = variableItemDefResultset.nextSolution()
            xml.'ItemDef'(
  				'OID': "IT.DM.${solVarItem.dataElementName}",
  				'Name': solVarItem.dataElementName,
  				'SASFieldName': solVarItem.dataElementName,
  				'DataType': "",
  				'SignificantDigits': "",
  				'Length': "",
  				'def:DisplayFormat': "",
  				'def:CommentOID': ""
  				) {
  					'Description'({'TranslatedText'('xml:lang':"en",  solVarItem.dataElementLabel )})
  					//if (_CodeListRef!=""){'CodeListRef'('CodeListOID': "" )}
  					//if (_OriginDescription!=""){
  					//	'def:Origin'(Type: "", {'Description'({'TranslatedText'('xml:lang':"en",  "" )})})
  					//}
  					//if (_ValueListOID!=""){
  					//	'def:ValueListRef'('ValueListOID': "")
  					//}
  				}
            }
        println writer
  		return(writer)
    }
