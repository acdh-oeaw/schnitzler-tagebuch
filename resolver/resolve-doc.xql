xquery version "3.1";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
import module namespace app="http://www.digital-archiv.at/ns/templates" at "../modules/app.xql";
declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=yes indent=yes";




let $xsl := doc('denormalize.xsl')
let $doc_name := request:get-parameter('doc-name', 'entry__1879-11-18.xml')
let $collection := request:get-parameter('collection', 'editions')
let $index_col := $app:indices
let $doc_uri :=
    if ($doc_name)
        then 
            string-join(($app:data, $collection, $doc_name), '/')
        else
            false()
let $xml := if($doc_name) then doc($doc_uri) else ()
let $index_endpoint := $app:BASE_URL||'/resolver/index-entries.xql?doc-name='||$doc_name||'&amp;collection='||$collection
let $params :=
<parameters>
    <param name="doc_name" value="{$doc_name}"/>
    <param name="col_name" value="{$collection}"/>
    <param name="uri" value="{request:get-effective-uri()}"/>
    <param name="index" value="{$index_endpoint}"/>
   {
        for $p in request:get-parameter-names()
            let $val := request:get-parameter($p,())
                return
                   <param name="{$p}"  value="{$val}"/>
   }
</parameters>
let $result := transform:transform($xml, $xsl, $params)
return $result
