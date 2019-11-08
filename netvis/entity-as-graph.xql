xquery version "3.1";

import module namespace app="http://www.digital-archiv.at/ns/templates" at "../modules/app.xql";
import module namespace netvis="https://digital-archiv/ns/netvis" at "netvis.xqm";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace util = "http://exist-db.org/xquery/util";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "json";
declare option output:media-type "application/json";

let $netivs_conf := $netvis:config
let $entity-id := request:get-parameter('id', 'entry__1931-01-02.xml')
let $entity-type := request:get-parameter('type', 'Tagebucheintrag')
let $node_conf := $netivs_conf//Entity[@type=$entity-type]
let $id := util:eval($node_conf/getId/text())
let $node := util:eval($node_conf/getEntity/text())
let $graph :=  netvis:item_as_graph($node, $entity-type)

return $graph
