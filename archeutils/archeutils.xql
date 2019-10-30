xquery version "3.1";

(:~
 : This module provides a couple of restxq functions (and some helper functions) to set ease the creation of ARCHE-RDF metadata representation
 : @author peter.andorfer@oeaw.ac.at
:)

module namespace archeutils="http://www.digital-archiv.at/ns/archeutils";

import module namespace app="http://www.digital-archiv.at/ns/templates" at "../modules/app.xql";
import module namespace config="http://www.digital-archiv.at/ns/config" at "../modules/config.xqm";

declare namespace functx = "http://www.functx.com";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace acdh="https://vocabs.acdh.oeaw.ac.at/schema#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace util = "http://exist-db.org/xquery/util";


declare variable $archeutils:base_url := "https://id.acdh.oeaw.ac.at/"||$config:app-name;
declare variable $archeutils:persons_url := $archeutils:base_url||"/persons";
declare variable $archeutils:places_url := $archeutils:base_url||"/places";
declare variable $archeutils:available_date := <acdh:hasAvailableDate>{current-date()}</acdh:hasAvailableDate>;
declare variable $archeutils:constants_exist := 
    if (doc-available($app:data||'/meta/arche_constants.rdf'))
        then
            true()
        else
            false();
declare variable $archeutils:constants :=
    if ($archeutils:constants_exist)
        then
            doc($app:data||'/meta/arche_constants.rdf')//acdh:ACDH
        else
            <acdh:ACDH/>;
declare variable $archeutils:repoobject_constants : = $archeutils:constants//acdh:RepoObject/*;
declare variable $archeutils:resource_constants : = ($archeutils:repoobject_constants, $archeutils:constants//acdh:Resource/*);
declare variable $archeutils:agents := $archeutils:constants//acdh:MetaAgents//*;
declare variable $archeutils:collstruct := $archeutils:constants//acdh:CollStruct;
declare variable $archeutils:tei_lookups := $archeutils:constants//acdh:TeiLookUps;


(:~
 : creates RDF Metadata describing the applications basic collection structure  
 :
 : @param $cols A sequence of names of the collection, need to match the @name attribute and are used to genereate the collections identifier
 : @return An ARCHE RDF describing the collections
:)

declare function archeutils:dump_collections($cols as item()+) as node()*{
    let $topcol := 
        <acdh:Collection rdf:about="{$archeutils:base_url}">
            {$archeutils:collstruct//acdh:TopColl//*}
            {$archeutils:repoobject_constants}
        </acdh:Collection>

    let $childCols := 
        for $x in $cols 
            let $col := 
                <acdh:Collection rdf:about="{$archeutils:base_url||'/'||$x}">
                    <acdh:isPartOf rdf:resource="{$archeutils:base_url}"/>
                    {$archeutils:collstruct//acdh:DataColl[@name=$x]//*}
                    {$archeutils:repoobject_constants}
                </acdh:Collection>
            where $col/acdh:hasTitle
            return
                $col
    
    let $RDF := 
        <rdf:RDF
            xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
            xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
            xmlns:acdh="https://vocabs.acdh.oeaw.ac.at/schema#"
            xml:base="https://id.acdh.oeaw.ac.at/">
            {$topcol}
            {$childCols}
        </rdf:RDF>
    
    return $RDF
};


(:~
 : generates resource specific attributes derived from acdh_TeiLookUps and the passed in TEI-Document  
 :
 : @param $doc The root element of a TEI Document (or the node from wich the provided xpaths should be evaluated)
 : @return ARCHE properties
:)

declare function archeutils:populate_tei_resource($doc as node()) as node()*{

for $x in $archeutils:tei_lookups/*
    let $el_name := name($x)
    let $el_xpath := $x/text()
    let $el_value := util:eval($el_xpath)
    let $el_type := data($x/@type)
    let $el := 
        switch ($el_type)
        case 'date' return element {$el_name} {attribute date { $el_value }}
        case 'resource' return element {$el_name} {attribute rdf:resource { $el_value }}
        default return element {$el_name} {$el_value}
    return $el
};