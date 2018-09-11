xquery version "3.1";
import module namespace app="http://www.digital-archiv.at/ns/schnitzler-tagebuch/templates" at "../modules/app.xql";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare option exist:serialize "method=json media-type=text/javascript";

let $end := number(request:get-parameter('end', 2000))
let $all := sort(collection($app:editions)//tei:TEI)
let $docs := subsequence($all, 1, $end)
let $result := 
<result>
    {
    for $doc at $count in $docs
        let $id := app:getDocName($doc)
        let $rowID := "row_"||$count
        let $text := substring(normalize-space(string-join($doc//tei:div[@type='diary-day']/tei:p[1]/text())), 1, 50)||"..."
        return
            <data>
                <title>
                    <textvalue>{normalize-space(string-join($doc//tei:title[@type='main']//text(), ' '))}</textvalue>
                    <href>{app:hrefToDoc($doc)}</href>
                </title>
                <doc_name>
                   <textvalue>{$id}</textvalue>
                </doc_name>
                <text>{$text}</text>
            </data>
    }
            <data>
                <title>
                    <textvalue></textvalue>
                    <href></href>
                </title>
                <doc_name>
                   <textvalue></textvalue>
                </doc_name>
                <text></text>
            </data>
         </result>
return $result
