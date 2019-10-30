xquery version "3.1";

(:~
 : This module provides a couple of restxq functions (and some helper functions) to set ease the creation of ARCHE-RDF metadata representation
 : @author peter.andorfer@oeaw.ac.at
:)

module namespace archeutils="http://www.digital-archiv.at/ns/archeutils";

import module namespace app="http://www.digital-archiv.at/ns/templates" at "../modules/app.xql";
import module namespace config="http://www.digital-archiv.at/ns/config" at "../modules/config.xqm";

declare namespace functx = "http://www.functx.com";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace acdh="https://vocabs.acdh.oeaw.ac.at/schema#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace util = "http://exist-db.org/xquery/util";


declare variable $archeutils:base_url := "https://id.acdh.oeaw.ac.at/"||$config:app-name;
declare variable $archeutils:persons_url := $archeutils:base_url||"/persons";
declare variable $archeutils:places_url := $archeutils:base_url||"/places";
declare variable $archeutils:available_date := <acdh:hasAvailableDate>{current-date()}</acdh:hasAvailableDate>;
declare variable $archeutils:constants :=
    if (doc-available($app:data||'/arche_constants.rdf'))
        then
            doc($app:data||'/arche_constants.rdf')//acdh:ACDH
        else
            $app:data;

declare variable $archeutils:repoobject_constants : = $archeutils:constants//acdh:RepoObject/*;
declare variable $archeutils:resource_constants : = ($archeutils:repoobject_constants, $archeutils:constants//acdh:Resource/*);