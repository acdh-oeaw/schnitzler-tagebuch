xquery version "3.1";
declare namespace functx = "http://www.functx.com";
import module namespace app="http://www.digital-archiv.at/ns/templates" at "../modules/app.xql";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare option exist:serialize "method=json media-type=text/javascript";

let $data := doc($app:data||'/cache/calender_datasource.xml')//item

for $x in $data
    return
        map {
            "name": $x/name/text(),
            "startDate": $x/startDate/text(),
            "id": $x/id/text()
        }