xquery version "3.0";
import module namespace config="http://www.digital-archiv.at/ns/config" at "modules/config.xqm";
import module namespace app="http://www.digital-archiv.at/ns/templates" at "modules/app.xql";
import module namespace util   = "http://exist-db.org/xquery/util";

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

for $resource in xmldb:get-child-resources(xs:anyURI($config:app-root||"/resolver/"))
    return sm:chmod(xs:anyURI($config:app-root||'/resolver/'||$resource), "rwxrwxr-x"),
   
util:log("info", "#################################"),
util:log("info", "create calendar"),
util:log("info", "#################################"),
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