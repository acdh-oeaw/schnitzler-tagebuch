xquery version "3.1";
declare namespace functx = "http://www.functx.com";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace config="http://www.digital-archiv.at/ns/schnitzler-tagebuch/config" at "../modules/config.xqm";
import module namespace app="http://www.digital-archiv.at/ns/schnitzler-tagebuch/templates" at "../modules/app.xql";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace acdh="https://vocabs.acdh.oeaw.ac.at/schema#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace util = "http://exist-db.org/xquery/util";

declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=no indent=yes";

let $baseID := 'https://id.acdh.oeaw.ac.at/'
let $personbase := $baseID||"schnitzler/schnitzler-tagebuch/persons/"
let $placebase := $baseID||"schnitzler/schnitzler-tagebuch/places/"
let $about := doc($app:data||'/project.rdf')/rdf:RDF
let $topCollection := $about//acdh:Collection[not(acdh:isPartOf)]
let $childCollections := $about//acdh:Collection[acdh:isPartOf]
let $customResources := $about//acdh:Resource
let $contributors := 
    for $x in distinct-values(data($about//acdh:hasContributor/acdh:Person/@rdf:about))
        return
        <acdh:hasContributor>
            <acdh:Person rdf:about="{$x}"/>
        </acdh:hasContributor>

let $authors := 
            <acdh:authors>
                 <acdh:hasCreator>
                     <acdh:Person rdf:about="http://d-nb.info/gnd/1145358152"/>
                 </acdh:hasCreator>
            </acdh:authors>  

let $collection-uri := $app:editions


let $RDF := 
    <rdf:RDF
        xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
        xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
        xmlns:acdh="https://vocabs.acdh.oeaw.ac.at/schema#"
        xmlns:acdhi="https://id.acdh.oeaw.ac.at/"
        xmlns:foaf="http://xmlns.com/foaf/spec/#"
        xml:base="https://id.acdh.oeaw.ac.at/">
            {$topCollection}
            {$childCollections}
            {
            let $sample := collection($app:editions)//tei:TEI[@xml:id and @xml:base]
            for $doc in subsequence($sample, 1, 1)
(:            for $doc in $sample:)
                let $xmlid := data($doc/@xml:id)
                let $collID := data($doc/@xml:base)
                let $date := substring-before(substring-after($xmlid, 'entry__'), '.xml')
                let $resID := string-join(($collID, $xmlid), '/')
                let $text := normalize-space(string-join($doc//tei:div[@type="diary-day"]//text(), ' '))
                let $title := <acdh:hasTitle>{$doc//tei:title[@type="main"][1]/text()}</acdh:hasTitle>
                let $schnitzler :=
                    <acdh:Person rdf:about="http://d-nb.info/gnd/118609807">
                        <acdh:hasLastName>Schnitzler</acdh:hasLastName>
                        <acdh:hasFirstName>Arthur</acdh:hasFirstName>
                    </acdh:Person>

               let $startDate :=
                    <acdh:hasCoverageStartDate>{$date}</acdh:hasCoverageStartDate>
                    
               let $description := if($text) then
                        <acdh:hasDescription>{concat(substring($text, 1, 150), '...')}</acdh:hasDescription>
                    else
                        ()

               let $persons := 
                    for $item in $doc//tei:listPerson//tei:person[./@xml:id]
                         let $pername := $item/tei:persName[1]/tei:surname[1]/text()
                         let $firstname := $item/tei:persName[1]/tei:forename[1]/text()
                         let $xmlid := data($item/@xml:id)
                         let $ID := $personbase||$xmlid
                         let $normIDs := 
                            for $x in $item//tei:idno/text()[starts-with(., 'http')]
                            return
                                <acdh:hasIdentifier rdf:resource="{$x}"/>
                         return
                             <acdh:hasActor>
                                 <acdh:Person rdf:about="{$ID}">
                                     <acdh:hasLastName>{$pername}</acdh:hasLastName>
                                     <acdh:hasFirstName>{$firstname}</acdh:hasFirstName>
                                     {$normIDs}
                                 </acdh:Person>
                             </acdh:hasActor>

                let $places := 
                    for $item in $doc//tei:listPlace//tei:place[./@xml:id]
                         let $placename := $item//tei:placeName[1]/text()
                         let $xmlid := data($item/@xml:id)
                         let $ID := $placebase||$xmlid
                         let $normIDs := 
                            for $x in $item//tei:idno/text()[starts-with(., 'http')]
                            return
                                <acdh:hasIdentifier rdf:resource="{$x}"/>
                         return
                             <acdh:hasSpatialCoverage>
                                 <acdh:Place rdf:about="{$ID}">
                                     <acdh:hasTitle>{$placename}</acdh:hasTitle>
                                     {$normIDs}
                                 </acdh:Place>
                             </acdh:hasSpatialCoverage>

                let $prev :=
                    if(exists($doc/@next)) then
                        <acdh:isContinuedBy rdf:resource="{data($doc/@next)}"/>
                    else
                        ()

                let $next :=
                    if(exists($doc/@prev)) then
                        <acdh:continues rdf:resource="{data($doc/@prev)}"/>
                    else
                        ()

                let $pid_str := $doc//tei:publicationStmt//tei:idno[@type="URI"]/text()
                    
                let $pid := if ($pid_str != "")
                    then
                        <acdh:hasPid rdf:resource="{$pid_str}"/>
                    else
                        ()

                return 
                    <acdh:Resource rdf:about="{$resID}">
                        <acdh:isPartOf rdf:resource="{$collID}"/>
                        {$prev}
                        {$next}
                        {$pid}
                        <acdh:hasCategory rdf:resource="https://vocabs.acdh.oeaw.ac.at/archecategory/dataset"/>
                        {$title}
                        {$startDate}
                        {$description}
                        <acdh:hasActor>
                            <acdh:Person rdf:about="http://d-nb.info/gnd/118609807"/>
                        </acdh:hasActor>
                        {$persons}
                        {$places}
                        {for $x in $authors//acdh:hasAuthor return $x}
                        {for $x in $authors//acdh:hasCreator return $x}
                        {for $x in $contributors return $x}
                        <acdh:hasDissService rdf:resource="https://id.acdh.oeaw.ac.at/dissemination/customTEI2HTML"/>
                        <acdh:hasCustomXSL rdf:resource="https://id.acdh.oeaw.ac.at/schnitzler/schnitzler-tagebuch/utils/tei2html.xsl"/>
                        <acdh:hasSchema>https://www.tei-c.org/release/xml/tei/schema/relaxng/tei.rng</acdh:hasSchema>
                        <acdh:hasLicense rdf:resource="https://creativecommons.org/licenses/by/4.0/"/>
                    </acdh:Resource>
        }
        {$customResources}

    </rdf:RDF>
    
return
    $RDF