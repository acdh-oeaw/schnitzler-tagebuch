xquery version "3.1";
declare namespace functx = "http://www.functx.com";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace app="http://www.digital-archiv.at/ns/templates" at "../modules/app.xql";
import module namespace config="http://www.digital-archiv.at/ns/config" at "../modules/config.xqm";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

let $listbibls := 
<result xmlns="http://www.tei-c.org/ns/1.0">{

for $x in doc($app:workIndex)//tei:body/tei:list//tei:date[@when]
    let $groupkey := data($x/@when)
    let $book := $x/ancestor::tei:item/tei:title
    group by $groupkey 
    return 
        <listbibl key="{concat('entry__', $groupkey[1], '.xml')}" xmlns="http://www.tei-c.org/ns/1.0">
            {
                for $y in $book
                return
                    <bibl xml:id="{data($y/@key)}" xmlns="http://www.tei-c.org/ns/1.0">
                        <title xmlns="http://www.tei-c.org/ns/1.0">{$y/text()}</title>
                    </bibl>
            }
        </listbibl>
}
</result>

for $x in subsequence($listbibls/*, 1, 10)
    let $doc := doc($app:editions||'/'||$x/@key)
    let $bibl := $x
    let $back := $doc//tei:back
    let $update := update insert $bibl into $back
    return $doc
