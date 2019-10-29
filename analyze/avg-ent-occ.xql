xquery version "3.1";

import module namespace util="http://exist-db.org/xquery/util";

import module namespace config="http://www.digital-archiv.at/ns/config" at "../modules/config.xqm";
import module namespace app="http://www.digital-archiv.at/ns/templates" at "../modules/app.xql";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare option exist:serialize "method=json media-type=text/javascript";

let $by := request:get-parameter('group-by', 'month')

let $result := 
<result>
    {
for $x in collection($app:editions)//tei:TEI
    let $persons := count($x//tei:person[@xml:id])
    let $places := count($x//tei:place[@xml:id])
    let $date := tokenize($x//tei:title[@type='iso-date']/text(), '-')
    let $year := $date[1]
    let $month := $year||'-'||$date[2]
    let $text := string-length(normalize-space(string-join($x//tei:div[@type="diary-day"]//text(), '')))
    let $groupby := if ($by = 'year') then $year else $month
    group by $groupby

    return 
        <result>
            <groupby>{$by}</groupby>
            <range>{$groupby}</range>
            <days>{count($x)}</days>
            <avgPersons>{sum($persons) div count($x)}</avgPersons>
            <avgPlaces>{sum($places) div count($x)}</avgPlaces>
            <avgEntryLenght>{sum($text) div count($x)}</avgEntryLenght>
        </result>
    }
</result>
return $result

(:    :)
(::)
(:let $docs := count(collection($app:editions)//tei:TEI):)
(:let $ents := count(collection($app:editions)//tei:place[@xml:id]):)
(:let $avg := $ents div $docs:)
(:return $avg:)
(::)
