xquery version "3.1";

import module namespace app="http://www.digital-archiv.at/ns/templates" at "../modules/app.xql";
import module namespace netvis="https://digital-archiv/ns/netvis" at "netvis.xqm";

declare namespace net="https://digital-archiv/ns/netvis/config";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace util = "http://exist-db.org/xquery/util";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "json";
declare option output:media-type "application/json";

let $node := '#person_13082'
let $hansi := collection($app:editions)//tei:TEI[.//*/@ref=$node]

return $hansi