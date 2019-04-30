xquery version "3.1";
import module namespace config="http://www.digital-archiv.at/ns/schnitzler-tagebuch/config" at "../modules/config.xqm";
import module namespace app="http://www.digital-archiv.at/ns/schnitzler-tagebuch/templates" at "../modules/app.xql";
import module namespace util="http://exist-db.org/xquery/util";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare option exist:serialize "method=json media-type=text/javascript";


let $max-len := request:get-parameter('max-len', 500)
let $directory := 'editions'
let $collection := string-join(($app:data,$directory), '/')
let $all := sort(xmldb:get-child-resources($collection))
let $max := count($all)
let $random-nr := util:random($max)
let $random-nr-secure := if($random-nr = 0) then 1 else $random-nr
let $selectedDoc := $all[$random-nr-secure]
let $doc := normalize-space(string-join(doc($collection||"/"||$selectedDoc)//tei:div[@type="diary-day"]//text(), ' '))
let $shortdoc := substring($doc, 1, $max-len)
let $url := "show.html?directory=editions&amp;document="||$selectedDoc
let $result := map{
    'text': $shortdoc,
    'doc-id': $selectedDoc,
    'max-len': $max-len,
    'url': $url
}
return
    $result