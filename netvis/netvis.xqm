xquery version "3.1";
module namespace netvis="https://digital-archiv/ns/netvis";

import module namespace app="http://www.digital-archiv.at/ns/templates" at "../modules/app.xql";
import module namespace config="http://www.digital-archiv.at/ns/config" at "../modules/config.xqm";

declare namespace net="https://digital-archiv/ns/netvis/config";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $netvis:config := 
    if (doc-available($app:data||'/meta/netvis-config.xml'))
        then
            doc($app:data||'/meta/netvis-config.xml')//net:netvisConfig
        else
            <net:netvisConfig/>;


declare function netvis:fetch_props($node as node(), $props) {
    let $mandatory_props :=
        for $x in $props
            let $el_name := name($x)
            let $el_type := data($x/@type)
            let $el_value := 
                switch ($el_type)
                case 'xpath' return element {$el_name} {util:eval($x/text())}
                default return  element {$el_name} {$x/text()}
            return
                $el_value
    return $mandatory_props
};

declare function netvis:doc_as_graph($node as node()){
    let $mandatory_props := netvis:fetch_props($node, $netvis:config//net:TeiDoc/net:mandatoryProps/*)
    let $edges := $netvis:config//net:TeiDoc//net:target/net:xpath
    let $source_node :=
        <node>
            {$mandatory_props}
        </node>
    let $target_nodes := 
        for $target_group in $netvis:config//net:TeiDoc//net:target
            let $x := $target_group/net:xpath
            let $props := $target_group/net:mandatoryProps/*
            let $relations := util:eval($x/text())
            for $item in $relations
                let $node := $item
                let $target_props := netvis:fetch_props($node, $props)
                return
                    <node>{$target_props}</node>
    let $edges :=
        for $target_node in $target_nodes
            let $e_id := $source_node/id/text()||"__"||$target_node/id
            let $rel_type := $target_node/relationType/text()
            return
                <edge>
                    <id>{$e_id}</id>
                    <label>erwähnt</label>
                    <source>{$source_node/id/text()}</source>
                    <target>{$rel_type}</target>
                </edge>
    let $types := $netvis:config//net:NodeTypes
    return 
        <graph>
            <nodes>
                {$source_node}
                {for $x in $target_nodes return $x}
            </nodes>
            <edges>
                {for $x in $edges return $x}
            </edges>
            <types>
                {for $x in $types/* return <nodes>{for $y in $x/* return $y}</nodes>}
            </types>
        </graph>
};