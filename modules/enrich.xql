xquery version "3.1";

(:~
 : This module provides a couple of helper functions used in the post-install.xql
 : @author peter.andorfer@oeaw.ac.at
:)

module namespace enrich="http://www.digital-archiv.at/ns/enrich";

import module namespace app="http://www.digital-archiv.at/ns/templates" at "../modules/app.xql";
import module namespace http = 'http://expath.org/ns/http-client';

declare namespace functx = "http://www.functx.com";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace acdh="https://vocabs.acdh.oeaw.ac.at/schema#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace util = "http://exist-db.org/xquery/util";


(:~
  : runs an xslt transformation over all documents in the given collection
  :
  : @param $collection The collection with the documents to transform
  : @param $xsl-uri URI of the XSLT used for the transformation
  : @return The URI of the processed document
:)

declare function enrich:bulk_transform($collection as xs:string, $xsl-uri as xs:string) as xs:string? {
  let $xsl := doc($xsl-uri)
  let $collection := $app:editions
  for $doc in xmldb:get-child-resources(xs:anyURI($collection))
      let $path := string-join(($collection, $doc), '/')
      let $xml := doc($path)
      let $params := <blank/>
      let $out := transform:transform($xml, $xsl, $params)
      let $store := xmldb:store($collection, $doc, $out)
      return $store
};



(:~
 : registers a handle-pid for the passed in URL
 :
 : @param $resolver The HANDLE-API-Endpoint, e.g. http://pid.gwdg.de/handles/21.11115/
 : @param $user The HANDLE user name, e.g. 'user34.12345-76'
 : @param $pw The HANDLE pw, e.g. 'verysecret'
 : @param $url The URL to register a handle-PID for
 : @return The handle PID
:)

declare function enrich:fetch_handle($resolver as xs:string, $user as xs:string, $pw as xs:string, $url as xs:string) as xs:string? {
  let $auth := "Basic "||util:string-to-binary($user||":"||$pw)
  let $data := '[{"type":"URL","parsed_data":"' || $url||'"}]'
  let $response := (
  http:send-request(
      <http:request method="POST" href="{$resolver}">
      <http:header name="Authorization" value="{$auth}"/>
      <http:header name="Content-Type" value="application/json"/>
      <http:header name="Accept" value="application/xhtml+xml"/>
      <http:body media-type='string' method='text'>{$data}</http:body>
      </http:request>, $resolver
    )
  )
  let $head := $response[1]
  let $handle := if (data($head/@status) = "201") then substring-after($head//*[@name="location"]/data(@value), 'handles/')
    else ""
  return
    $handle
};


(:~
 : creates RDF Metadata describing the applications basic collection structure
 :
 : @param $archeURL The Top-Collection URL, e.g. https://id.acdh.oeaw.ac.at/grundbuecher/{top-col-name}
 : @param $colName The name of the data-collection to process, e.g. 'editions'
 : @return An ARCHE RDF describing the collections
:)

declare function enrich:add_base_and_xmlid($archeURL as xs:string, $colName as xs:string) {
      let $collection := $app:data||'/'||$colName
      let $all := collection($collection)//tei:TEI
      let $base_url := $archeURL||$colName

    for $x in $all
        let $collectionName := util:collection-name($x)
        let $currentDocName := util:document-name($x)
        let $neighbors := app:doc-context($collectionName, $currentDocName)
        let $xml_id := util:document-name($x)
        let $base := update insert attribute xml:base {$base_url} into $x
        let $currentID := update insert attribute xml:id {$currentDocName} into $x
        let $prev := if($neighbors[1])
        then
            update insert attribute prev {string-join(($base_url, $neighbors[1]), '/')} into $x
        else
            ()
    let $next := if($neighbors[3])
        then
            update insert attribute next {string-join(($base_url, $neighbors[3]), '/')}into $x
        else
            ()
        return
          <result base="{$base_url}">
            <collectionName>{$collectionName}</collectionName>
            <currentDocName>{$currentDocName}</currentDocName>
            <xml_id>{$xml_id}</xml_id>
          </result>

};

(:~
 : adds mentions as tei:events to index entry

 : @param $colName The name of the data-collection to process, e.g. 'editions'
 : @param $ent_type The name of the entity, e.g. 'place', 'org' or 'person'
:)

declare function enrich:mentions($colName as xs:string, $ent_type as xs:string) {
  let $collection := $app:data||'/'||$colName
  for $x at $count in collection($app:indices)//tei:*[name()=$ent_type]
    let $events := $x//tei:event
    let $event_list := $x//tei:listEvent
    let $remove_events := for $e in $event_list let $removed := update delete $e return <removed>{$e}</removed>

    let $ref := '#'||$x/@xml:id
    let $lm := 'processing entity nr: '||$count||' with id: '||$ref
    let $l := util:log('info', $lm)
    let $event_list_node := 
    <tei:listEvent>{
    for $doc in collection($collection)//tei:TEI[.//tei:rs[@ref=$ref]]
        let $doc_title := normalize-space(string-join($doc//tei:titleStmt/tei:title//text()[not(./parent::tei:note)], ''))
        let $handle := $doc//tei:idno[@type='handle']/text()
        return
            <tei:event type="mentioned">
                <tei:desc>erwähnt in <tei:title>{$doc_title}</tei:title></tei:desc>
                <tei:linkGrp>
                  <tei:link type="relativ" target="{$colName||'/'||data($doc/@xml:id)}"/>
                  <tei:link type="PID" target="{$handle}"/>
                  <tei:link type="ARCHE" target="{data($doc/@xml:base)||'/'||data($doc/@xml:id)}"/>
                </tei:linkGrp>
            </tei:event>
    }
    </tei:listEvent>
        let $event_count := count($event_list_node//tei:event)
        let $continue := if ($event_count gt 0) then true() else false()
        let $update := 
                if ($continue) then 
                    update insert $event_list_node into $x
                else
                    ()
        return
            <result updated="{$ref}">
                <event_count>{$event_count}</event_count>
            </result>
};

(:~
 : deletes index-entries without xml:id

 : @param $colName The name of the data-collection to process, e.g. 'editions'
 : @param $ent_type The name of the entity, e.g. 'place', 'org' or 'person'
:)

declare function enrich:delete_entities_without_xmlid($ent_type as xs:string) {
  for $x at $count in collection($app:indices)//tei:*[name()=$ent_type and not(@xml:id)]
    let $msg := substring(normalize-space(string-join($x//text(), ' ')), 1, 25)
    let $l := util:log('info', $msg)

    return
      update delete $x
};

(:~
 : deletes remove tei:list* elements in tei:back"

 : @param $colName The name of the data-collection to process, e.g. 'editions'
:)

declare function enrich:delete_lists_in_back($colName) {
  let $collection := $app:data||'/'||$colName
  for $x at $count in collection($collection)//tei:back//*[starts-with(name(), 'list')]
    return
      update delete $x
};

(:~
 : checks for a tei:back element and creates it if missing

 : @param $doc a tei document
:)

declare function enrich:get_or_create_back_node($doc) {
  let $text_node := $doc//tei:text
  let $check_node :=
    if (exists($doc//tei:back)) then
      true()
    else
      update insert <back xmlns="http://www.tei-c.org/ns/1.0" /> into $text_node
  return $doc//tei:back 
};


(:~
 : add index entries of mentioned entites into the document's back element

 : @param $colName The name of the data-collection to process, e.g. 'editions'
 : @param $ent_type The name of the entity, e.g. 'place', 'org' or 'person'
:)

declare function enrich:denormalize_index($colName as xs:string, $ent_type as xs:string) {
  let $collection := $app:data||'/'||$colName
  let $doc_count := count(collection($collection)//tei:TEI)
  for $x at $pos in collection($collection)//tei:TEI
    let $doc_id := data($x/@xml:id)
    let $lm: = "adding list-"||$ent_type||" to document: "||$doc_id
    let $l := util:log("info", $lm)
    let $l := util:log("info", concat("processed ", $pos, "out of ", $doc_count, " documents"))
    let $item_refs := distinct-values(data($x//tei:rs[@type=$ent_type]/@ref))
    let $back := enrich:get_or_create_back_node($x)
    let $index_list :=
      switch($ent_type)
      case 'org' return
      <listOrg xmlns="http://www.tei-c.org/ns/1.0">
          {
          for $item in $item_refs
          return
          collection($app:indices)//id(substring-after($item, '#'))
          }
      </listOrg>
      case 'place' return
      <listPlace xmlns="http://www.tei-c.org/ns/1.0">
          {
          for $item in $item_refs
          return
          collection($app:indices)//id(substring-after($item, '#'))
          }
      </listPlace>
      case 'bibl' return
      <listBibl xmlns="http://www.tei-c.org/ns/1.0">
          {
          for $item in $item_refs
          return
          collection($app:indices)//id(substring-after($item, '#'))
          }
      </listBibl>
      default return
      <listPerson xmlns="http://www.tei-c.org/ns/1.0">
          {
          for $item in $item_refs
          return
          collection($app:indices)//id(substring-after($item, '#'))
          }
      </listPerson>
  
  
  where has-children($index_list)
  return
    update insert $index_list into $back
};