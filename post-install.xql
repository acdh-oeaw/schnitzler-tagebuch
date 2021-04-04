xquery version "3.0";
import module namespace config="http://www.digital-archiv.at/ns/config" at "modules/config.xqm";
import module namespace app="http://www.digital-archiv.at/ns/templates" at "modules/app.xql";
import module namespace netvis="https://digital-archiv/ns/netvis" at "netvis/netvis.xqm";
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

(: for $x in collection($app:editions)//tei:TEI
    let $removeBack := update delete $x//tei:back
    let $persons := distinct-values(data($x//tei:rs[@type="person" and not(@ref="#person_")]/@ref))
    let $listperson :=
    <listPerson xmlns="http://www.tei-c.org/ns/1.0">
        {
        for $y in $persons
        return
        collection($app:indices)//id(substring-after($y, '#'))
        }
    </listPerson>

    let $places := distinct-values(data($x//tei:rs[@type="place"]/@ref))
    let $listplace :=
    <listPlace xmlns="http://www.tei-c.org/ns/1.0">
        {
        for $y in $places
        return
        collection($app:indices)//id(substring-after($y, '#'))
        }
    </listPlace>

    let $validlistperson := if ($listperson/tei:person) then $listperson else ()
    let $validlistplace := if ($listplace/tei:place) then $listplace else ()

    let $back :=
    <back xmlns="http://www.tei-c.org/ns/1.0">
        {$validlistperson}
        {$validlistplace}
    </back>

    let $update := update insert $back into $x/tei:text

    return "done", :)


let $listbibls :=
<result xmlns="http://www.tei-c.org/ns/1.0">{

for $x in doc($app:workIndex)//tei:body/tei:list//tei:date[@when]
    let $groupkey := data($x/@when)
    let $book := $x/ancestor::tei:item/tei:title
    group by $groupkey
    return
        <listBibl xmlns="http://www.tei-c.org/ns/1.0" ana="{concat('entry__', $groupkey[1], '.xml')}">
            {
                for $y in $book
                return
                    <bibl xmlns="http://www.tei-c.org/ns/1.0" xml:id="{data($y/@key)}">
                        <title xmlns="http://www.tei-c.org/ns/1.0">{$y/text()}</title>
                    </bibl>
            }
        </listBibl>
}
</result>

for $x in $listbibls/*
    let $doc := doc($app:editions||'/'||$x/@ana)
    let $bibl := $x
    let $back := $doc//tei:back
    let $update := update insert $bibl into $back
    return "bibl",

(: create calendar cache :)
let $data := app:populate_cache()

(: create table of contents cache :)
let $source-col := $app:data||'/cache'
let $contents := <tbody/>
let $cache-file := xmldb:store($source-col, 'toc_cache.xml', $contents)
let $docs := collection($app:editions)//tei:TEI
let $context := doc($cache-file)/tbody
for $x in $docs
  let $row := app:createTocRow($x)
  return update insert $row into $context
