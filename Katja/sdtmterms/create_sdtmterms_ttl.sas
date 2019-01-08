* download from https://evs.nci.nih.gov/ftp1/CDISC/SDTM/CDASH%20Terminology.txt - 2018-01-08;


DATA sdtmterm (COMPRESS=CHAR);
    infile '<path>/sdtm-terminology.txt' dlm='09'x dsd lrecl=4096 firstobs=2;
    input code       :$20.
          codelist   :$20.
          extensible :$10.
          name       :$50.
          sub_val    :$200.
          synonyms   :$2000.
          def        :$2000.
          nci        :$200.;
RUN;


DATA blub;
    FILE "<path>/sdtmterms.ttl" lrecl=2000;
    SET sdtmterm/* (WHERE=(code IN ("C66737","C66742") OR codelist IN ("C66737","C66742")))*/ END=_eof_;
    ATTRIB id  FORMAT=$200.;
    ATTRIB id2 FORMAT=$200.;
    RETAIN id;

    IF _N_ = 1
    THEN DO;
        PUT "###############################################################################";
        PUT "# FILE: sdtmterms.ttl                                                          ";
        PUT "# DESC: triples containing CDISC sdtm terminology for PhUSE project            ";
        PUT "# REQ :                                                                        ";
        PUT "# SRC :                                                                        ";
        PUT "# IN  :                                                                        ";
        PUT "# OUT :                                                                        ";
        PUT "# NOTE: origin: https://evs.nci.nih.gov/ftp1/CDISC/SDTM/CDASH%20Terminology.txt";
        PUT "#        - 2018-01-08                                                          ";
        PUT "# TODO:                                                                        ";
        PUT "# DATE: 2019-01                                                                ";
        PUT "# BY  : KG                                                                     ";
        PUT "###############################################################################";
        PUT ;
        PUT "@prefix sdtmterms: <https://w3id.org/phuse/sdtmterms#> .              ";
        PUT "@prefix code: <https://w3id.org/phuse/code#> .                        ";
        PUT "@prefix owl: <http://www.w3.org/2002/07/owl#> .                       ";
        PUT "@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .               ";
        PUT "@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .                    ";
        PUT ;
        PUT ;
    END;

    IF MISSING(codelist)
    THEN DO;
        id = STRIP(TRANSLATE(STRIP(name),"_____", " |:-/"));
    END;


    IF MISSING(codelist)    /* new codelist starts */
    THEN DO;
        PUT "sdtmterms:" id;
        PUT @4 'rdf:type' @30 "owl:Class;";
        PUT @4 'rdfs:subClassOf' @30 "code:DefinedConcept;";
        PUT @4 'rdfs:subClassOf [';
        PUT @8 'rdf:type        owl:Restriction;';
        PUT @8 'owl:hasValue    code:CodeSystem_CDISCTerminology;';
        PUT @8 'owl:onProperty  code:hasCodeSystem;';
        PUT @6 '];';
        PUT @4 'skos:prefLabel' @30 "'" name +(-1) "';";
        PUT ".";
        PUT ;
    END;
    ELSE DO;
        id2 = STRIP(TRANSLATE(STRIP(sub_val),"_____", " |:-/"));;
        PUT "sdtmterms:" id +(-1) "_" id2;
        PUT @4 'rdf:type'                    @50 "sdtmterms:"             id ";";
        PUT @4 'rdf:type'                    @50 "mms:PermissibleValue;";
        PUT @4 'skos:prefLabel'              @50 '"'                      sub_val  +(-1) '";';
        PUT @4 'code:hasCode'                @50 '"'                      code     +(-1) '";';
        PUT @4 'schema:cdiscDefinition'      @50 '"'                      def      +(-1) '";';
        PUT @4 'schema:cdiscSubmissionValue' @50 '"'                      sub_val  +(-1) '";';
        PUT @4 'schema:cdiscSynonyms'        @50 '"'                      synonyms +(-1) '";';
        PUT @4 'schema:nciCode'              @50 '"'                      code     +(-1) '";';
        PUT @4 'schema:nciPreferredTerm'     @50 '"'                      nci      +(-1) '";';
        PUT @4 'mms:inValueDomain'           @50 '"sdtmterm:'             codelist +(-1) '";';
        PUT ".";
        PUT ;
    END;
RUN;