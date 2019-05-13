xquery version "3.1";
declare namespace functx = "http://www.functx.com";
import module namespace app="http://www.digital-archiv.at/ns/schnitzler-tagebuch/templates" at "../modules/app.xql";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare option exist:serialize "method=json media-type=text/javascript";

for $x in collection($app:editions)//tei:TEI[.//tei:date[@when castable as xs:date]]
    let $startDate : = data($x//*[@when castable as xs:date][1]/@when)
    let $name := $x//tei:titleStmt/tei:title[@type="main"]/text()
    let $id := app:hrefToDoc($x)
    return
        map {
                "name": $name,
                "startDate": $startDate,
                "id": $id
        }