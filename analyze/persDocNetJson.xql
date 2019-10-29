xquery version "3.1";

import module namespace util="http://exist-db.org/xquery/util";

import module namespace config="http://www.digital-archiv.at/ns/config" at "../modules/config.xqm";
import module namespace app="http://www.digital-archiv.at/ns/templates" at "../modules/app.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare option exist:serialize "method=json media-type=text/javascript";

let $year := request:get-parameter('year', '1900')

let $docs := collection($app:editions)//tei:TEI[.//tei:date[contains(data(@when), $year)]]
let $result :=
    <result>{

        for $doc in $docs
            let $title := $doc//tei:titleStmt/tei:title[@type='main']/text()
            let $id := util:document-name($doc)
            return
                <nodes>
                    <id>{$id}</id>
                    <title>{$title}</title>
                    <color>#d11141</color>
                </nodes>
    }
    {
        for $person in $docs//tei:back//tei:person[@xml:id]
            let $key := data($person/@xml:id)
            group by $key
            return
                <nodes>
                    <id>{$key[1]}</id>
                    <title>{normalize-space(string-join($person[1]/tei:persName[1]//text(), ''))}</title>
                    <color>#00b159</color>
                </nodes>
    }
    {
        for $ent in $docs//tei:back//tei:person[@xml:id]
            let $from := util:document-name($ent)
            let $to := data($ent/@xml:id)
                    return
                        <edges>
                            <from>{$from}</from>
                            <to>{$to}</to>
                        </edges>
     }
    
    </result>
return
    $result
