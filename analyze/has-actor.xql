xquery version "3.1";

import module namespace app="http://www.digital-archiv.at/ns/templates" at "../modules/app.xql";

declare namespace acdh="https://vocabs.acdh.oeaw.ac.at/schema#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=no indent=yes";

let $years := request:get-parameter('years', '187')
let $col_name := request:get-parameter('col-name', 'editions')

let $sample := collection($app:data||"/"||$col_name)//tei:TEI[contains(@xml:id, $years) and .//tei:person[@xml:id]]

let $res :=
    for $item in $sample
        let $doc_id := $item/@xml:base||'/'||$item/@xml:id
        let $ent_nodes := $item//tei:back//tei:listPerson/tei:person[@xml:id]
        return 
        <acdh:Resource rdf:about="{$doc_id}">
        {
        for $ent in $ent_nodes
            let $res_id := app:get_entity_id($ent)
            return
                <acdh:hasActor rdf:resource="{$res_id}"/>
        }
        </acdh:Resource>
return 
    <rdf:RDF
        xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
        xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
        xmlns:acdh="https://vocabs.acdh.oeaw.ac.at/schema#"
        xml:base="https://id.acdh.oeaw.ac.at/">
        {$res}
    </rdf:RDF>
