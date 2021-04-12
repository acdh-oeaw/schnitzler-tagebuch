xquery version "3.0";
import module namespace config="http://www.digital-archiv.at/ns/config" at "modules/config.xqm";
import module namespace app="http://www.digital-archiv.at/ns/templates" at "modules/app.xql";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

(: grant general execution rights to all scripts in analyze and modules collection :)
for $resource in xmldb:get-child-resources(xs:anyURI($config:app-root||"/analyze/"))
    return sm:chmod(xs:anyURI($config:app-root||'/analyze/'||$resource), "rwxrwxr-x"),

(: grant general execution rights to all scripts in analyze and modules collection :)
for $resource in xmldb:get-child-resources(xs:anyURI($config:app-root||"/archeutils/"))
    return sm:chmod(xs:anyURI($config:app-root||'/archeutils/'||$resource), "rwxrwxr-x"),

for $resource in xmldb:get-child-resources(xs:anyURI($config:app-root||"/modules/"))
    return sm:chmod(xs:anyURI($config:app-root||'/modules/'||$resource), "rwxrwxr-x"),

for $resource in xmldb:get-child-resources(xs:anyURI($config:app-root||"/ac/"))
    return sm:chmod(xs:anyURI($config:app-root||'/ac/'||$resource), "rwxrwxr-x"),

for $resource in xmldb:get-child-resources(xs:anyURI($config:app-root||"/netvis/"))
    return sm:chmod(xs:anyURI($config:app-root||'/netvis/'||$resource), "rwxrwxr-x"),

let $listbibls :=
<result xmlns="http://www.tei-c.org/ns/1.0">{

for $x in doc($app:workIndex)//tei:body/tei:list//tei:date[@when]
    let $groupkey := data($x/@when)
    let $book := $x/ancestor::tei:item/tei:title
    group by $groupkey
    return
        <back xmlns="http://www.tei-c.org/ns/1.0" ana="{concat('entry__', $groupkey[1], '.xml')}">
        <listBibl xmlns="http://www.tei-c.org/ns/1.0" >
            {
                for $y in $book
                return
                    <bibl xmlns="http://www.tei-c.org/ns/1.0" xml:id="{data($y/@key)}">
                        <title xmlns="http://www.tei-c.org/ns/1.0">{$y/text()}</title>
                    </bibl>
            }
        </listBibl>
        </back>
}
</result>

for $x in $listbibls/*
    let $doc := doc($app:editions||'/'||$x/@ana)
    let $bibl := $x
    let $insert_place := $doc//tei:text
    let $update := update insert $bibl into $insert_place
    return "bibl",

(: create calendar cache :)
let $data := app:populate_cache()
return 'done'