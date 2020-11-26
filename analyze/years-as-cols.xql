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

for $x in collection($app:editions)//tei:TEI
  let $date := $x//tei:title[@type="iso-date"]/text()
  let $id := data($x/@xml:id)
  let $year := substring-before($date,'-')
  group by $year
  return
        <acdh:Collection rdf:about="{concat('https://id.acdh.oeaw.ac.at/schnitzler/schnitzler-tagebuch/editions/', $year)}">
          {$archeutils:repoobject_constants}
          <acdh:isPartOf rdf:resource="https://id.acdh.oeaw.ac.at/schnitzler/schnitzler-tagebuch/editions"/>
          <acdh:hasTitle xml:lang="de">Einträge des Jahres {$year}</acdh:hasTitle>
          <acdh:hasExtent xml:lang="de">{count($x)} Einträge</acdh:hasExtent>
          <acdh:hasSource rdf:resource="https://id.acdh.oeaw.ac.at/schnitzler/faksimiles/tagebuch"/>
          <acdh:relation rdf:resource="https://id.acdh.oeaw.ac.at/pub-schnitzler-tagebuchgesamtwerk"/>
          <acdh:hasActor rdf:resource="https://d-nb.info/gnd/118609807"/>
          <acdh:hasDescription xml:lang="de">Die Sammlung umfasst {count($x)} Einträge des Tagebuchs von Arthur Schnitzler aus dem Jahr {$year}</acdh:hasDescription>
          <acdh:hasCoverageStartDate rdf:datatype="http://www.w3.org/2001/XMLSchema#date">{concat($year, '-01-01')}</acdh:hasCoverageStartDate>
        <acdh:hasCoverageEndDate rdf:datatype="http://www.w3.org/2001/XMLSchema#date">{concat($year, '-12-31')}</acdh:hasCoverageEndDate>
        </acdh:Collection>
}
</rdf:RDF>
