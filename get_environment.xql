declare namespace transform="http://exist-db.org/xquery/transform";
declare namespace session="http://exist-db.org/xquery/session";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare option exist:serialize "method=xml media-type=text/xml indent=yes";

import module namespace ab-common="http://wob2.iai.uni-bonn.de/ab/common" at "common.xqm";

ab-common:get-environment()
