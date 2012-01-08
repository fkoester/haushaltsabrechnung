(: list_messages.xql :)
(: Listet die Nachrichten für den eingeloggten User unter Verwendung des messages-module.xqm auf :)

declare namespace transform="http://exist-db.org/xquery/transform";
declare namespace session="http://exist-db.org/xquery/session";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare option exist:serialize "method=html5 media-type=text/html indent=yes";

import module namespace ab-common="http://wob2.iai.uni-bonn.de/ab/common" at "common.xqm";
import module namespace ab-messages="http://wob2.iai.uni-bonn.de/ab/messages" at "messages-module.xqm";

let $messages-of-user := ab-messages:get-messages-of-user(ab-common:get-current-user-id())

let $parameters :=
	<parameters>
        	{ $messages-of-user }
	        { ab-common:get-environment() }
	</parameters>

return transform:transform($parameters, xs:anyURI("stylesheets/list_messages.xsl"), ())
