xquery version "3.1";

import module namespace archeutils="http://www.digital-archiv.at/ns/archeutils" at 'archeutils.xql';
import module namespace app="http://www.digital-archiv.at/ns/templates" at "../modules/app.xql";

declare namespace acdh="https://vocabs.acdh.oeaw.ac.at/schema#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace tei = "http://www.tei-c.org/ns/1.0";


declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=no indent=yes";

let $starting-at := request:get-parameter('starting-at', 0)
let $length := request:get-parameter('length', 10)
let $col_name := request:get-parameter('col-name', 'editions')
let $repoobject_constants := $archeutils:repoobject_constants
let $docs := collection($app:data||"/"||$col_name)//tei:TEI[@xml:id and @xml:base]
let $sample := subsequence($docs, $starting-at, $length)
let $res := for $doc in $sample
    let $xmlid := data($doc/@xml:id)
    let $collID := data($doc/@xml:base)
    let $resID := string-join(($collID, $xmlid), '/')
    let $custom_props := archeutils:populate_tei_resource($doc)
    return 
        <acdh:Resource rdf:about="{$resID}">
            <acdh:isPartOf rdf:resource="{$collID}"/>
            {$custom_props}
            {$repoobject_constants}
        </acdh:Resource>

let $RDF := 
    <rdf:RDF
        xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
        xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
        xmlns:acdh="https://vocabs.acdh.oeaw.ac.at/schema#"
        xml:base="https://id.acdh.oeaw.ac.at/">
        {$res}
    </rdf:RDF>

return $RDF