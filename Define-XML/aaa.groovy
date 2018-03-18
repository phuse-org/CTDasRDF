@Grab('org.apache.jena:jena-core:3.6.0')
@Grab('org.apache.jena:jena-arq:3.6.0')

/**
 * @author ippei
 *
 */

import org.apache.jena.query.*
import org.apache.jena.rdf.model.*

Model model = ModelFactory.createDefaultModel()
model.read("aa.ttl")
