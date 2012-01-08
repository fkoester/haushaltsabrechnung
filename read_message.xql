(: Nacrichtenaufruf :)

declare namespace transform="http://exist-db.org/xquery/transform";
declare namespace session="http://exist-db.org/xquery/session";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare option exist:serialize "method=html5 media-type=text/html indent=yes";

import module namespace ab-group="http://wob2.iai.uni-bonn.de/ab/group" at "group-module.xqm";
import module namespace ab-messages="http://wob2.iai.uni-bonn.de/ab/messages" at "messages-module.xqm";
import module namespace ab-common="http://wob2.iai.uni-bonn.de/ab/common" at "common.xqm";

let $message-id := request:get-parameter("id", "")

let $current-user-id := ab-common:get-current-user-id()
let $current-group-id := ab-common:get-current-group-id()

let $message := ab-messages:get-message-by-id(xs:long($message-id))

let $read :=  ab-messages:mark-read(xs:long($message-id), $current-user-id)

let $parameters := 
<parameters>
	{ $message }
	{ ab-common:get-environment() }
</parameters>

return
transform:transform($parameters, xs:anyURI("stylesheets/read_message.xsl"), ())
