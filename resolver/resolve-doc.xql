xquery version "3.1";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
import module namespace app="http://www.digital-archiv.at/ns/templates" at "../modules/app.xql";
declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=yes indent=yes";

let $doc_name := request:get-parameter('doc-name', 'entry__1879-11-18.xml')
let $collection := request:get-parameter('collection', 'editions')
let $doc_uri :=
    if ($doc_name)
        then 
            string-join(($app:data, $collection, $doc_name), '/')
        else
            false()
let $xml := if($doc_name) then doc($doc_uri) else ()

return $xml
