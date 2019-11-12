xquery version "3.1";
module namespace app="http://www.digital-archiv.at/ns/templates";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace functx = 'http://www.functx.com';

import module namespace util="http://exist-db.org/xquery/util";
import module namespace http="http://expath.org/ns/http-client";
import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://www.digital-archiv.at/ns/config" at "config.xqm";
import module namespace kwic = "http://exist-db.org/xquery/kwic" at "resource:org/exist/xquery/lib/kwic.xql";

declare variable $app:data := $config:app-root||'/data';
declare variable $app:editions := $config:app-root||'/data/editions';
declare variable $app:indices := $config:app-root||'/data/indices';
declare variable $app:placeIndex := $config:app-root||'/data/indices/listplace.xml';
declare variable $app:personIndex := $config:app-root||'/data/indices/listperson.xml';
declare variable $app:orgIndex := $config:app-root||'/data/indices/listorg.xml';
declare variable $app:workIndex := $config:app-root||'/data/indices/listwork.xml';
declare variable $app:defaultXsl := doc($config:app-root||'/resources/xslt/xmlToHtml.xsl');
declare variable $app:cachedGraph := doc($app:data||'/cache/graph_cache.xml');


declare variable $app:redmineBaseUrl := "https://shared.acdh.oeaw.ac.at/acdh-common-assets/api/imprint.php?serviceID=";
declare variable $app:redmineID := "11833";
declare variable $app:productionBaseURL := "https://schnitzler-tagebuch.acdh.oeaw.ac.at";

declare function functx:contains-case-insensitive
  ( $arg as xs:string? ,
    $substring as xs:string )  as xs:boolean? {

   contains(upper-case($arg), upper-case($substring))
 } ;

 declare function functx:escape-for-regex
  ( $arg as xs:string? )  as xs:string {

   replace($arg,
           '(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')
 } ;

declare function functx:substring-after-last
  ( $arg as xs:string? ,
    $delim as xs:string )  as xs:string {
    replace ($arg,concat('^.*',$delim),'')
 };

 declare function functx:substring-before-last
  ( $arg as xs:string? ,
    $delim as xs:string )  as xs:string {

   if (matches($arg, functx:escape-for-regex($delim)))
   then replace($arg,
            concat('^(.*)', functx:escape-for-regex($delim),'.*'),
            '$1')
   else ''
 } ;

 declare function functx:capitalize-first
  ( $arg as xs:string? )  as xs:string? {

   concat(upper-case(substring($arg,1,1)),
             substring($arg,2))
 } ;

(:~
 : returns the names of the previous, current and next document
:)

declare function app:next-doc($collection as xs:string, $current as xs:string) {
let $all := sort(xmldb:get-child-resources($collection))
let $currentIx := index-of($all, $current)
let $prev := if ($currentIx > 1) then $all[$currentIx - 1] else false()
let $next := if ($currentIx < count($all)) then $all[$currentIx + 1] else false()
return
    ($prev, $current, $next)
};

declare function app:doc-context($collection as xs:string, $current as xs:string) {
let $all := sort(xmldb:get-child-resources($collection))
let $currentIx := index-of($all, $current)
let $prev := if ($currentIx > 1) then $all[$currentIx - 1] else false()
let $next := if ($currentIx < count($all)) then $all[$currentIx + 1] else false()
let $amount := count($all)
return
    ($prev, $current, $next, $amount, $currentIx)
};


declare function app:fetchEntity($ref as xs:string){
    let $entity := collection($config:app-root||'/data/indices')//*[@xml:id=$ref]
    let $type: = if (contains(node-name($entity), 'place')) then 'place'
        else if  (contains(node-name($entity), 'person')) then 'person'
        else 'unkown'
    let $viewName := if($type eq 'place') then(string-join($entity/tei:placeName[1]//text(), ', '))
        else if ($type eq 'person' and exists($entity/tei:persName/tei:forename)) then string-join(($entity/tei:persName/tei:surname/text(), $entity/tei:persName/tei:forename/text()), ', ')
        else if ($type eq 'person') then $entity/tei:placeName/tei:surname/text()
        else 'no name'
    let $viewName := normalize-space($viewName)

    return
        ($viewName, $type, $entity)
};

declare function local:everything2string($entity as node()){
    let $texts := normalize-space(string-join($entity//text(), ' '))
    return
        $texts
};

declare function local:viewName($entity as node()){
    let $name := node-name($entity)
    return
        $name
};


(:~
: returns the name of the document of the node passed to this function.
:)
declare function app:getDocName($node as node()){
let $name := functx:substring-after-last(document-uri(root($node)), '/')
    return $name
};

(:~
: renders the name element of the passed in entity node.
:)
declare function app:nameOfIndexWork($node as node(), $model as map (*)){
    let $searchkey := xs:string(request:get-parameter("searchkey", "No search key provided"))
    let $item := doc($app:workIndex)//tei:item[./tei:title[@key=$searchkey]]
    let $name := $item/tei:title/text()
    let $noOfterms := count($item//tei:date)
    return
     <h1 style="text-align:center;">
        <small>
            <span id="hitcount"/>{$noOfterms} Treffer für</small>
        <br/>
        <strong>
            {$name}
        </strong>
    </h1>
};


(:~
: renders the name element of the passed in entity node as a link to entity's info-modal.
:)
declare function app:nameOfIndexEntry($node as node(), $model as map (*)){

    let $searchkey := xs:string(request:get-parameter("searchkey", "No search key provided"))
    let $withHash:= '#'||$searchkey
    let $entities := collection($app:editions)//tei:TEI//*[@ref=$withHash]
    let $terms := (collection($app:editions)//tei:TEI[.//tei:term[./text() eq substring-after($withHash, '#')]])
    let $noOfterms := count(($entities, $terms))
    let $hit := collection($app:indices)//*[@xml:id=$searchkey]
    let $name := if (contains(node-name($hit), 'person'))
        then
            <a class="reference" data-type="listperson.xml" data-key="{$searchkey}">{normalize-space(string-join($hit/tei:persName[1], ', '))}</a>
        else if (contains(node-name($hit), 'place'))
        then
            <a class="reference" data-type="listplace.xml" data-key="{$searchkey}">{normalize-space(string-join($hit/tei:placeName[1], ', '))}</a>
        else if (contains(node-name($hit), 'org'))
        then
            <a class="reference" data-type="listorg.xml" data-key="{$searchkey}">{normalize-space(string-join($hit/tei:orgName[1], ', '))}</a>
        else if (contains(node-name($hit), 'bibl'))
        then
            <a class="reference" data-type="listwork.xml" data-key="{$searchkey}">{normalize-space(string-join($hit/tei:title[1], ', '))}</a>
        else
            functx:capitalize-first($searchkey)
    return
    <h1 style="text-align:center;">
        <small>
            <span id="hitcount"/>{$noOfterms} Treffer für</small>
        <br/>
        <strong>
            {$name}
        </strong>
    </h1>
};

(:~
 : href to document.
 :)
declare function app:hrefToDoc($node as node()){
let $name := functx:substring-after-last($node, '/')
let $href := concat('show.html','?document=', app:getDocName($node))
    return $href
};

(:~
 : href to document.
 :)
declare function app:hrefToDoc($node as node(), $collection as xs:string){
let $name := functx:substring-after-last($node, '/')
let $href := concat('show.html','?document=', app:getDocName($node), '&amp;directory=', $collection)
    return $href
};

(:~
 : a fulltext-search function
 :)
 declare function app:ft_search($node as node(), $model as map (*)) {
 if (request:get-parameter("searchexpr", "") !="") then
 let $searchterm as xs:string:= request:get-parameter("searchexpr", "")
 for $hit in collection(concat($config:app-root, '/data/editions/'))//*[.//tei:body[ft:query(.,$searchterm)]]
    let $href := concat(app:hrefToDoc($hit), "&amp;searchexpr=", $searchterm)
    let $score as xs:float := ft:score($hit)
    let $docname := app:getDocName($hit)
    let $day := substring-before(substring-after($docname, 'entry__'), '.xml')
    order by $docname descending
    return
    <tr>
        <td><a href="{$href}">{$day}</a></td>
        <td class="KWIC">{kwic:summarize($hit, <config width="100" link="{$href}" />)}</td>
    </tr>
 else
    <div>Nothing to search for</div>
 };

declare function app:indexSearch_hits($node as node(), $model as map(*),  $searchkey as xs:string?, $path as xs:string?){
let $indexSerachKey := $searchkey
let $searchkey:= '#'||$searchkey
let $entities := collection($app:editions)//tei:TEI[.//*/@ref=$searchkey]
for $title in ($entities)
    let $docTitle := root($title)//tei:titleStmt/tei:title[@type='iso-date']/text()
    let $hits := if (count(root($title)//*[@ref=$searchkey]) = 0) then 1 else count(root($title)//*[@ref=$searchkey])
    let $snippet :=
        for $entity in root($title)//*[@ref=$searchkey]
                let $before := string-join(($entity/preceding::text()[3],$entity/preceding::text()[2], $entity/preceding::text()[1]), '')
                let $after := substring(normalize-space(string-join($entity/following::text(), '')), 1, 50)
                return
                    <p>... {concat($before, ' ')} <strong><a href="{concat(app:hrefToDoc($title), "&amp;searchkey=", $indexSerachKey)}"> {string-join($entity//text(), '')}</a></strong> {concat(' ', $after)}...<br/></p>
    let $zitat := $title//tei:msIdentifier
    return
            <tr>
               <td style="white-space: nowrap;"><a href="{concat(app:hrefToDoc($title), "&amp;searchkey=", $indexSerachKey)}">{$docTitle}</a></td>
               <td>{$hits}</td>
               <td>{$snippet}</td>
            </tr>
};


declare function app:workIndexSearchResults($node as node(), $model as map(*),  $searchkey as xs:string?, $path as xs:string?){
let $entities := collection($app:editions)//tei:TEI[.//*/@xml:id=$searchkey]
for $title in ($entities)
    let $docTitle := root($title)//tei:titleStmt/tei:title[@type='iso-date']/text()
    return
            <tr>
               <td style="white-space: nowrap;"><a href="{concat(app:hrefToDoc($title), "&amp;searchkey=", $searchkey)}">{$docTitle}</a></td>
            </tr>
};


(:~
 : creates a basic work-index derived from the  '/data/indices/listwork.xml'
 :)
declare function app:listWork($node as node(), $model as map(*)) {
    let $hitHtml := "work-search.html?searchkey="
    for $item in doc($app:workIndex)//tei:body//tei:item
        return
        <tr>
            <td><a href="{concat($hitHtml, data($item/tei:title/@key))}">{$item/tei:title/text()}</a></td>
            <td><a href="{concat($hitHtml, data($item/tei:title/@key))}">{count($item//tei:date)}</a></td>
            <td>{$item/tei:note[1]}</td>
        </tr>
};

(:~
 : creates a basic person-index derived from the  '/data/indices/listperson.xml'
 :)
declare function app:listPers($node as node(), $model as map(*)) {
    let $hitHtml := "hits.html?searchkey="
    for $person in doc($app:personIndex)//tei:listPerson/tei:person
    let $gnd := $person/tei:idno[@type='GND']
    let $gender := if ($person/tei:sex/text() != "") then $person/tei:sex/text() else '-'
    let $job := normalize-space(string-join($person//tei:occupation//text(), ', '))
    let $jobstring := if ($job != '') then $job else '-'
    let $birthday := if ($person/tei:birth/tei:date/text() != "") then $person/tei:birth/tei:date/text() else '-'
    let $surname := if ($person/tei:persName/tei:surname) then $person/tei:persName/tei:surname else '-'
    let $forename := if ($person/tei:persName/tei:forename) then $person/tei:persName/tei:forename else '-'
    let $birthplace := if ($person/tei:birth/tei:placeName/text() != "") then $person/tei:birth/tei:placeName/text() else '-'
    let $deathday := if ($person/tei:death/tei:date/text() != "") then $person/tei:death/tei:date/text() else '-'
    let $deathplace := if ($person/tei:death/tei:placeName/text() != "") then $person/tei:death/tei:placeName/text() else '-'
    let $gnd_link := if ($gnd != "no gnd provided") then
        <a href="{$gnd}">gnd:{tokenize($gnd, '/')[last()]}</a>
        else
        "-"
        return
        <tr>
            <td>
                <a href="{concat($hitHtml,data($person/@xml:id))}">{$surname}</a>
            </td>
            <td>
                <a href="{concat($hitHtml,data($person/@xml:id))}">{$forename}</a>
            </td>
            <td>
                {$birthday}
            </td>
            <td>
                {$birthplace}
            </td>
            <td>
                {$deathday}
            </td>
            <td>
                {$deathplace}
            </td>
            <td>
                {$gnd_link}
            </td>
            <td>
                {$jobstring}
            </td>
            <td>
                {$gender}
            </td>
        </tr>
};

(:~
 : creates a basic place-index derived from the  '/data/indices/listplace.xml'
 :)
declare function app:listPlace($node as node(), $model as map(*)) {
    let $hitHtml := "hits.html?searchkey="
    for $place in doc($app:placeIndex)//tei:listPlace/tei:place
    let $lat := tokenize($place//tei:geo/text(), ' ')[1]
    let $lng := tokenize($place//tei:geo/text(), ' ')[2]
    let $idno := if ($place//tei:idno/text() != "") then analyze-string($place//tei:idno/text(), '\d*')//*:match else '-'
    let $idnolink := if ($place//tei:idno/text() != "") then  <a href="{$place//tei:idno/text()}">geonames:{$idno}</a> else '-'

        return
        <tr>
            <td>
                <a href="{concat($hitHtml, data($place/@xml:id))}">{functx:capitalize-first($place/tei:placeName[1])}</a>
            </td>
            <td>{for $altName in $place//tei:placeName return <li>{$altName/text()}</li>}</td>
            <td>{$idnolink}</td>
            <td>{$lat}</td>
            <td>{$lng}</td>
        </tr>
};

declare function app:createTocRow($x as item()){
    let $entry_label := $x//tei:title[@type="main"]/text()
    let $entry_text := normalize-space(string-join($x//tei:div[@type="diary-day"]//text(), ' '))
    let $token_nr := count(tokenize($entry_text))
    let $week_day := substring-before($entry_label, ',')
    let $date := $x//tei:title[@type="iso-date"]/text()
    let $date_split := tokenize($date, '-')
    let $persons := for $item in $x//tei:listPerson/tei:person return <li>{normalize-space(string-join($item/tei:persName[1]//text()))}</li>
    let $places := for $item in $x//tei:listPlace/tei:place return <li>{normalize-space(string-join($item/tei:placeName[1]//text()))}</li>
    let $works := for $item in $x//tei:listbibl/tei:bibl return <li>{normalize-space(string-join($item/tei:title[1]//text()))}</li>
    return
        <tr>
            <td>
              <a href="{app:hrefToDoc($x, 'editions')}" target="_blank">{$entry_label}</a>
            </td>
            <td>{$date_split[1]}</td>
            <td>{$date_split[2]}</td>
            <td>{$date_split[3]}</td>
            <td>{$week_day}</td>
            <td>{$date}</td>
            <td>{$entry_text}</td>
            <td>{$persons}</td>
            <td>{$places}</td>
            <td>{$works}</td>
            <td>{count($persons)}</td>
            <td>{count($places)}</td>
            <td>{count($works)}</td>
            <td>{$token_nr}</td>
        </tr>
};

(:~
 : creates a basic table of content derived from the documents stored in '/data/editions'
 :)
declare function app:toc($node as node(), $model as map(*)) {
  for $x in doc($app:data||'/cache/toc_cache.xml')//tr
    return $x
};

(:~
 : perfoms an XSLT transformation
:)
declare function app:XMLtoHTML ($node as node(), $model as map (*), $query as xs:string?) {
let $ref := xs:string(request:get-parameter("document", ""))
let $refname := substring-before($ref, '.xml')
let $xmlPath := concat(xs:string(request:get-parameter("directory", "editions")), '/')
let $xml := doc(replace(concat($config:app-root,'/data/', $xmlPath, $ref), '/exist/', '/db/'))
let $collectionName := util:collection-name($xml)
let $collection := functx:substring-after-last($collectionName, '/')
let $neighbors := try{app:doc-context($collectionName, $ref)} catch * {false()}
let $prev := if($neighbors[1]) then 'show.html?document='||$neighbors[1]||'&amp;directory='||$collection else ()
let $next := if($neighbors[3]) then 'show.html?document='||$neighbors[3]||'&amp;directory='||$collection else ()
let $amount := $neighbors[4]
let $currentIx := $neighbors[5]
let $progress := ($currentIx div $amount)*100
let $xslPath := xs:string(request:get-parameter("stylesheet", ""))
let $quotationURL := string-join(($app:productionBaseURL, 'v', $collection, $refname), '/')
let $xsl := if($xslPath eq "")
    then
        if(doc($config:app-root||'/resources/xslt/'||$collection||'.xsl'))
            then
                doc($config:app-root||'/resources/xslt/'||$collection||'.xsl')
        else if(doc($config:app-root||'/resources/xslt/'||$refname||'.xsl'))
            then
                doc($config:app-root||'/resources/xslt/'||$refname||'.xsl')
        else
            $app:defaultXsl
    else
        if(doc($config:app-root||'/resources/xslt/'||$xslPath||'.xsl'))
            then
                doc($config:app-root||'/resources/xslt/'||$xslPath||'.xsl')
            else
                $app:defaultXsl
let $path2source := "../resolver/resolve-doc.xql?doc-name="||$ref||"&amp;collection="||$collection
let $params :=
<parameters>
    <param name="app-name" value="{$config:app-name}"/>
    <param name="collection-name" value="{$collection}"/>
    <param name="path2source" value="{$path2source}"/>
    <param name="prev" value="{$prev}"/>
    <param name="next" value="{$next}"/>
    <param name="amount" value="{$amount}"/>
    <param name="currentIx" value="{$currentIx}"/>
    <param name="progress" value="{$progress}"/>
    <param name="productionBaseUrl" value="{$app:productionBaseURL}"/>
    <param name="quotationURL" value="{$quotationURL}"/>
   {
        for $p in request:get-parameter-names()
            let $val := request:get-parameter($p,())
                return
                   <param name="{$p}"  value="{$val}"/>
   }
</parameters>
let $result := if (not($neighbors castable as xs:boolean)) then transform:transform($xml, $xsl, $params) else <h1>Kein Eintrag für diesen Tag</h1>
return
    $result
};

(:~
 : creates a basic work-index derived from the  '/data/indices/listbibl.xml'
 :)
declare function app:listBibl($node as node(), $model as map(*)) {
    let $hitHtml := "hits.html?searchkey="
    for $item in doc($app:workIndex)//tei:listBibl/tei:bibl
    let $author := normalize-space(string-join($item/tei:author//text(), ' '))
    let $gnd := $item//tei:idno/text()
    let $gnd_link := if ($gnd)
        then
            <a href="{$gnd}">{$gnd}</a>
        else
            'no normdata provided'
   return
        <tr>
            <td>
                <a href="{concat($hitHtml,data($item/@xml:id))}">{$item//tei:title[1]/text()}</a>
            </td>
            <td>
                {$author}
            </td>
            <td>
                {$gnd_link}
            </td>
        </tr>
};

(:~
 : creates a basic organisation-index derived from the  '/data/indices/listorg.xml'
 :)
declare function app:listOrg($node as node(), $model as map(*)) {
    let $hitHtml := "hits.html?searchkey="
    for $item in doc($app:orgIndex)//tei:listOrg/tei:org
    let $altnames := normalize-space(string-join($item//tei:orgName[@type='alt'], ' '))
    let $gnd := $item//tei:idno/text()
    let $gnd_link := if ($gnd)
        then
            <a href="{$gnd}">{$gnd}</a>
        else
            'no normdata provided'
   return
        <tr>
            <td>
                <a href="{concat($hitHtml,data($item/@xml:id))}">{$item//tei:orgName[1]/text()}</a>
            </td>
            <td>
                {$altnames}
            </td>
            <td>
                {$gnd_link}
            </td>
        </tr>
};

(:~
 : fetches html snippets from ACDH's imprint service; Make sure you'll have $app:redmineBaseUrl and $app:redmineID set
 :)
declare function app:fetchImprint($node as node(), $model as map(*)) {
    let $url := $app:redmineBaseUrl||$app:redmineID
    let $request :=
    <http:request href="{$url}" method="GET"/>
    let $response := http:send-request($request)
        return $response[2]
};

(:~
 : fetches the first document in the given collection
 :)
declare function app:firstDoc($node as node(), $model as map(*)) {
    let $all := sort(xmldb:get-child-resources($app:editions))
    let $href := "show.html?document="||$all[1]||"&amp;directory=editions"
        return
            <a href="{$href}"><button class="btn btn-round">Lesen</button></a>
};


(:~
 : returns first n chars of random doc
 :)
declare function app:randomDoc($node as node(), $model as map(*), $maxlen as xs:integer) {
    let $directory := 'editions'
    let $collection := string-join(($app:data,$directory), '/')
    let $all := sort(xmldb:get-child-resources($collection))
    let $max := count($all)
    let $random-nr := util:random($max)
    let $random-nr-secure := if($random-nr = 0) then 1 else $random-nr
    let $selectedDoc := $all[$random-nr-secure]
    let $teinode := doc($collection||"/"||$selectedDoc)//tei:TEI
    let $title := $teinode//tei:title[@type="main"]/text()
    let $doc := normalize-space(string-join(doc($collection||"/"||$selectedDoc)//tei:div[@type="diary-day"]//text(), ' '))
    let $shortdoc := substring($doc, 1, $maxlen)
    let $url := "show.html?directory=editions&amp;document="||$selectedDoc
    let $result :=
    <div class="entry-text-content">
        <header class="entry-header">
            <h4 class="entry-title">
                <a href="{$url}" rel="bookmark" class="light">{$title}</a>
            </h4>
        </header>
        <!-- .entry-header -->
        <div class="entry-content">
            <p>{$shortdoc}[...]</p>
            <a class="btn btn-round mb-1" href="{$url}">Mehr lesen</a>
        </div>
        <!-- .entry-content -->
    </div>
    return
        $result
};

declare function app:populate_cache(){
let $contents :=
<result>{
for $x in collection($app:editions)//tei:TEI[.//tei:date[@when castable as xs:date]]
    let $startDate : = data($x//*[@when castable as xs:date][1]/@when)
    let $name := $x//tei:titleStmt/tei:title[@type="main"]/text()
    let $id := app:hrefToDoc($x)
    return
        <item>
            <name>{$name}</name>
            <startDate>{$startDate}</startDate>
            <id>{$id}</id>
        </item>
}
</result>
let $rm-cache := try {xmldb:remove($app:data||'/cache')} catch * {'ok'}
let $target-col := xmldb:create-collection($app:data, 'cache')
let $json := xmldb:store($target-col, 'calender_datasource.xml', $contents)

return $json
};
