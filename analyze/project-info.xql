xquery version "3.1";
declare namespace expath="http://expath.org/ns/pkg";
declare namespace repo="http://exist-db.org/xquery/repo";
import module namespace app="http://www.digital-archiv.at/ns/schnitzler-tagebuch/templates" at "../modules/app.xql";
import module namespace config="http://www.digital-archiv.at/ns/schnitzler-tagebuch/config" at "modules/config.xqm";
declare option exist:serialize "method=json media-type=text/javascript content-type=application/json";


let $description := doc(concat($config:app-root, "/repo.xml"))//repo:description/text()
let $authors := normalize-space(string-join(doc(concat($config:app-root, "/repo.xml"))//repo:author//text(), ', '))
let $map := map{
    "title": "Arthur Schnitzler Tagebuch",
    "subtitle": "Digital Scholarly Edition of Arthur Schnitzler's Diaries",
    "author": $authors,
    "description": $description,
    "github": "https://github.com/KONDE-AT/schnitzler-tagebuch",
    "purpose_de": "Ziel von schnitzler-tagebuch ist die Publikation von Forschungsdaten.",
    "purpose_en": "The purpose of schnitzler-tagebuch is the publication of research data.",
    "app_type": "digital-edition",
    "base_tech": "eXist-db",
    "framework": "Digital Scholarly Editions Base Application"
}
return 
        $map