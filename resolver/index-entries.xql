xquery version "3.1";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

import module namespace app="http://www.digital-archiv.at/ns/templates" at "../modules/app.xql";
declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=no indent=yes";

let $doc_name := request:get-parameter('doc-name', 'entry__1931-01-30.xml')
let $collection := request:get-parameter('collection', 'editions')
let $doc_uri :=
    if ($doc_name)
        then 
            string-join(($app:data, $collection, $doc_name), '/')
        else
            false()
let $xml := if($doc_name) then doc($doc_uri) else ()

let $item_refs := distinct-values(data($xml//tei:rs[@type]/@ref))
let $result := 
<tei:result>
{
for $item in $item_refs
    let $item_node := collection($app:indices)//id(substring-after($item, '#'))
    return
        $item_node
}
</tei:result>
return $result
