@Grab('org.apache.jena:jena-core:3.6.0')
@Grab('org.apache.jena:jena-arq:3.6.0')

/**
 * @author Ippei Akiya
 *
 */

import groovy.xml.MarkupBuilder
import org.apache.jena.query.*
import org.apache.jena.rdf.model.*


class genDefineXMLFile {
	Model model = ModelFactory.createDefaultModel()

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
	def comentCollection = []
	def methodCollection = []
	def codelistCollection = []
	def datasetList = []

	// Construct Other Metadata
	def writer = new StringWriter()
	def xml = new MarkupBuilder(writer)


	//Constructor
	def genDefineXMLFile(datasets) {
		this.datasetList=datasets
		readRdfFiles()

		Query query = QueryFactory.create(queryString)
		// Execute the query and obtain results
		QueryExecution qe = QueryExecutionFactory.create(query, model)
		try {
			for (ResultSet rs = qe.execSelect(); rs.hasNext() ; ) {
				QuerySolution sol = rs.nextSolution()
				ProtocolId=sol.StudyId
				StudyDescription=sol.StudyDescription
				Sponsor=sol.SponsorName
				StdVersion=sol.StdVersion
			}
		} finally {
			qe.close()
		}

		xml.setOmitNullAttributes(true)
		xml.setOmitEmptyAttributes(true)
		xml.setDoubleQuotes(true)
		xml.setEscapeAttributes(true)
	}


	// Read RDF files
	def readRdfFiles() {
		def fileList = [
		"cdisc-schema.rdf",
		"cdiscpilot01-R.TTL",
		"cdiscpilot01-protocol.ttl",
		"cdiscpilot01.ttl",
		"code.ttl",
		"ct-schema.rdf",
		"meta-model-schema.rdf",
		"sdtm-1-3.ttl",
		"sdtm-cd01p.ttl",
		"sdtm-cdisc01.ttl",
		"sdtm-terminology.rdf",
		"sdtm.ttl",
		"sdtmig-3-1-3.ttl",
		"study.ttl",
		"time.ttl"]

		for (i in fileList) {
			model.read("../data/rdf/" + i)
		}
	}



	def genDefineXML() {
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
			QueryExecution datasetMetadataQE = QueryExecutionFactory.create(datasetMetadataQueryFactory, model)

			// Get VariabeMetadata
			def variableMetadataTemplate = new File('template/variableMetadata.sparql.template').getText()
			def variableMetadataQuery = engine.createTemplate(variableMetadataTemplate).make(dsname)
			def variableMetadataQueryFactory = QueryFactory.create(prefixed + variableMetadataQuery)
			QueryExecution variableMetadataQE = QueryExecutionFactory.create(variableMetadataQueryFactory, model)

			// Get VariabeMetadata for ItemDef
			def variableItemDefMetadataTemplate = new File('template/variableMetadata.sparql.template').getText()
			def variableItemDefMetadataQuery = engine.createTemplate(variableItemDefMetadataTemplate).make(dsname)
			def variableItemDefMetadataQueryFactory = QueryFactory.create(prefixed + variableItemDefMetadataQuery)
			QueryExecution variableItemDefMetadataQE = QueryExecutionFactory.create(variableItemDefMetadataQueryFactory, model)

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
			QueryExecution variableItemDefMetadataQE = QueryExecutionFactory.create(variableItemDefMetadataQueryFactory, model)

			_DefineXml <<= genItemDef(variableItemDefMetadataQE,i)
		}
		// Generate MethodDef
		_DefineXml <<= genMethodDef()
		// Generate def:comment
		_DefineXml <<= genComment()
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
	}

	/**
	 * Creates a ItemGroupDef as dataset level metadata.
	 *
	 * @param datasetMetadataQE
	 * @param variableMetadataQE
	 * @param datasetName Specific dataset name, i.e. DM, VS, SUPPAE, and others
	 * @return xml document
	 */
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
			def repeating
			def reference
			if (sol.Domain.toString() == "SUPPQUAL") {
				dsname = datasetName
				dslabel = sol.DatasetLabel.toString() + " for " + datasetName.toString()
			}else{
				dsname = sol.Domain
				dslabel = sol.DatasetLabel
			}

			// Repeating Attribute
			if (dsname in [
				"DM",
				"TA",
				"TI",
				"TE",
				"TV",
				"TS"
			]) {
				repeating = "No"
			}else{
				repeating = "Yes"
			}
			// IsReferenceData Attribute
			if (sol.defClass == "TRIAL DESIGN") {
				reference = "Yes"
			}else{
				reference = "No"
			}
			xml.'ItemGroupDef'(
					'OID': "IG.${dsname}",
					'Name': dsname,
					'Domain': dsname,
					'SASDatasetName': dsname,
					'Repeating': repeating,
					'IsReferenceData': reference,
					'Purpose': "Tabulation",
					'def:Structure': sol.Structure,
					'def:Class': sol.defClass,
					'def:CommentOID': "",
					'def:ArchiveLocationID': "LF.${dsname}"
					) {
						'Description'({'TranslatedText'('xml:lang':"en",  dslabel )})
						for (ResultSet variableResultset = variableMetadataQE.execSelect(); variableResultset.hasNext() ; ) {
							QuerySolution sol2 = variableResultset.nextSolution()

							// Generate Method comOID
							def origin = sol2.Origin.toString()
							def mtOID = "MT.${datasetName}.${sol2.dataElementName}"
							if (sol2.comment != null && origin == "DERIVED" ){
								Map mtMap =[(mtOID):(sol2.comment)]
								methodCollection << mtMap
							}

							'ItemRef'(ItemOID: "IT.${datasetName}.${sol2.dataElementName}",
							OrderNumber: sol2.ordinal_, Mandatory: (sol2.Core.toString() == "Required" ? "Yes" : "No"), KeySequence: "", MethodOID: mtOID)
						}
						'def:leaf'('ID':"LF.${dsname}", 'xlink:href':"${dsname}.xpt".toLowerCase(), {
							'def:title'("${dsname}.xpt".toLowerCase())}
						)
					}
			return(writer)
		}
	}


	def String genItemDef(QueryExecution variableItemDefMetadataQE, String datasetName) {
		def writer = new StringWriter()
		def xml = new MarkupBuilder(writer)
		xml.setOmitNullAttributes(true)
		xml.setOmitEmptyAttributes(true)
		xml.setDoubleQuotes(true)
		xml.setEscapeAttributes(true)

		for (ResultSet variableItemDefResultset = variableItemDefMetadataQE.execSelect(); variableItemDefResultset.hasNext(); ) {
			QuerySolution solVarItem = variableItemDefResultset.nextSolution()
					//Convert Data Type Name
					def datatype
					if ( solVarItem.dataType.toString() == "xsd:string"){
							datatype = "text"
					} else if ( solVarItem.dataType.toString().toLowerCase().contains("integer")){
							datatype = "integer"
					} else if ( solVarItem.dataType.toString() == "xsd:dateTime"){
							datatype = "datetime"
					} else if ( solVarItem.dataType.toString() == "xsd:decimal"){
							datatype = "float"
					} else{
							datatype = solVarItem.dataType
					}

					//Convert Origin name
					def origin
					if ( solVarItem.Origin.toString() == "COLLECTED"){
							origin = "CRF"
					} else{
							origin = solVarItem.Origin.toString()
					}

			//Hnadling CommentOID
			def comOID
			if (solVarItem.comment != null && origin != "DERIVED" ){
				Map comMap =[("COM."+solVarItem.dataElementName):(solVarItem.comment)]
				comentCollection << comMap
				comOID = "COM."+solVarItem.dataElementName
			}

			if (solVarItem.codeListName != null){
				codelistCollection << solVarItem.codeListName
			}

			xml.'ItemDef'(
					'OID': "IT.${datasetName}.${solVarItem.dataElementName}",
					'Name': solVarItem.dataElementName,
					'SASFieldName': solVarItem.dataElementName,
					'DataType': datatype,
					'SignificantDigits': "",
					'Length': "",
					'def:DisplayFormat': "",
					'def:CommentOID': comOID
					) {
						'Description'({'TranslatedText'('xml:lang':"en",  solVarItem.dataElementLabel )})
						if (solVarItem.Origin != null){
							'def:Origin'(Type:origin)
						}
						if (solVarItem.codeListName != null){
							'CodeListRef'('CodeListOID': "CL.${solVarItem.codeListName}" )
						}
					}
		}
		return(writer)
	}


	def String genMethodDef(){
		def writer = new StringWriter()
		def xml = new MarkupBuilder(writer)

		xml.setOmitNullAttributes(true)
		xml.setOmitEmptyAttributes(true)
		xml.setDoubleQuotes(true)
		xml.setEscapeAttributes(true)

		for (mtind in methodCollection){
			def mkey = mtind.keySet()[0]
			def mval = mtind.get(mkey)
			def mname = mkey - "MT."
			xml.'MethodDef'('OID':mkey, 'Name':"Algorithm to derive ${mname}", 'Type':"Computation"){
				'Description'({'TranslatedText'('xml:lang':"en",  mval)})
			}
		}
		return(writer)
	}


	def String genComment(){
		def writer = new StringWriter()
		def xml = new MarkupBuilder(writer)

		xml.setOmitNullAttributes(true)
		xml.setOmitEmptyAttributes(true)
		xml.setDoubleQuotes(true)
		xml.setEscapeAttributes(true)

		for (comind in comentCollection){
			def ckey = comind.keySet()[0]
			def cval = comind.get(ckey)
			xml.'def:CommentDef'( 'OID': ckey ){
				'Description'({ 'TranslatedText'('xml:lang':"en",  comind.get( ckey )) })
			}
		}
		return(writer)
	}

}


define_generator = new genDefineXMLFile(["DM", "SUPPDM", "VS"])
define_generator.genDefineXML()
