xquery version "3.1";

import module namespace archeutils="http://www.digital-archiv.at/ns/archeutils" at 'archeutils.xql';

declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=no indent=yes";

let $RDF := 
    <rdf:RDF
        xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
        xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
        xmlns:acdh="https://vocabs.acdh.oeaw.ac.at/schema#"
        xml:base="https://id.acdh.oeaw.ac.at/">
        
        {$archeutils:agents}
        
    </rdf:RDF>

return $RDF