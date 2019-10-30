xquery version "3.1";

import module namespace archeutils="http://www.digital-archiv.at/ns/archeutils" at 'archeutils.xql';

declare namespace acdh="https://vocabs.acdh.oeaw.ac.at/schema#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=no indent=yes";

let $cols := ('editions', 'indices', 'whatever')


let $colstruct := archeutils:dump_collections($cols)

return $colstruct