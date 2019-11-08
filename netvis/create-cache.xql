xquery version "3.1";

import module namespace app="http://www.digital-archiv.at/ns/templates" at "../modules/app.xql";
import module namespace netvis="https://digital-archiv/ns/netvis" at "netvis.xqm";

declare namespace net="https://digital-archiv/ns/netvis/config";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace util = "http://exist-db.org/xquery/util";

let $source-col := $app:data||'/cache'
let $netivs_conf := $netvis:config
let $collection := request:get-parameter('collection', 'editions')
let $type := request:get-parameter('type', 'Tagebucheintrag')
let $types := $netvis:config//NodeTypes
let $contents := <CachedGraph>{$types}</CachedGraph>
let $cache-file := xmldb:store($source-col, 'graph_cache.xml', $contents)
let $docs := collection($app:editions)//tei:TEI
let $context := doc($cache-file)/CachedGraph

for $x in $docs
    let $graph := netvis:item_as_graph($x, $type)
    let $new_graph := 
        <graph>
            <Nodes>{for $n in $graph/nodes return $n}</Nodes>
        </graph>
    return update insert $new_graph into $context
