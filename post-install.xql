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

for $x in collection($app:editions)//tei:TEI
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
    
    return "done",


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

for $x in $listbibls/*
    let $doc := doc($app:editions||'/'||$x/@key)
    let $bibl := $x
    let $back := $doc//tei:back
    let $update := update insert $bibl into $back
    return "bibl",

let $data := app:populate_cache()

let $newIndex := xmldb:reindex($app:data)
return "done"
