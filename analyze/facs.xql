xquery version "3.1";
declare namespace functx = "http://www.functx.com";
import module namespace app="http://www.digital-archiv.at/ns/templates" at "../modules/app.xql";
import module namespace archeutils="http://www.digital-archiv.at/ns/archeutils" at "../archeutils/archeutils.xql";

declare namespace acdh="https://vocabs.acdh.oeaw.ac.at/schema#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=no indent=yes";
<rdf:RDF
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:acdh="https://vocabs.acdh.oeaw.ac.at/schema#"
    xml:base="https://id.acdh.oeaw.ac.at/">
    {

for $x in collection($app:editions)//tei:TEI[contains(@xml:id, '193')]//tei:graphic
    let $facs_id := data($x/@url)
    let $root := $x/ancestor::tei:TEI
    let $doc_id := concat(data($root/@xml:base), '/', data($root/@xml:id))
    return
    <rdf:Resource rdf:about="{$facs_id}">
            <acdh:isSourceOf rdf:resource="{$doc_id}"/>
    </rdf:Resource>

}
</rdf:RDF>
