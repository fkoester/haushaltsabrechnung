xquery version "1.0";

declare namespace session="http://exist-db.org/xquery/session";
declare namespace transform="http://exist-db.org/xquery/transform";

import module namespace ab-group="http://wob2.iai.uni-bonn.de/ab/group" at "group-module.xqm";

session:invalidate(),
transform:transform(<user />, xs:anyURI("stylesheets/login.xsl"), ())
