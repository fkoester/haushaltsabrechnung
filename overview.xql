(: Anzeige des eingeloggten users, aktuellen Nachrichten sowie Einkäufen und einer Bilanz bzgl. Forderungen und Schulden :)

declare namespace transform="http://exist-db.org/xquery/transform";
declare namespace session="http://exist-db.org/xquery/session";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare option exist:serialize "method=html5 media-type=text/html indent=yes";

import module namespace ab-common="http://wob2.iai.uni-bonn.de/ab/common" at "common.xqm";
import module namespace ab-transaction="http://wob2.iai.uni-bonn.de/ab/transaction" at "transaction-module.xqm";
import module namespace ab-messages="http://wob2.iai.uni-bonn.de/ab/messages" at "messages-module.xqm";

let $messages-of-user := ab-messages:get-unread-messages-of-user(ab-common:get-current-user-id())
let $last-transactions-of-group := ab-transaction:get-transaction-entries-of-group(ab-common:get-current-group-id(), 10, ab-common:get-current-user-id())
let $balances-of-group := ab-transaction:get-balances-of-group-for-user(ab-common:get-current-group-id(), ab-common:get-current-user-id())

let $parameters :=
	<parameters>
		<overview-data>
		        { $messages-of-user }
		        { $last-transactions-of-group }
			{ $balances-of-group }
		</overview-data>
	        { ab-common:get-environment() }
	</parameters>

return transform:transform($parameters, xs:anyURI("stylesheets/overview.xsl"), ())
