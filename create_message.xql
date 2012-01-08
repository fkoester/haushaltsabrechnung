declare namespace transform="http://exist-db.org/xquery/transform";
declare namespace session="http://exist-db.org/xquery/session";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare option exist:serialize "method=html5 media-type=text/html indent=yes";

import module namespace ab-group="http://wob2.iai.uni-bonn.de/ab/group" at "group-module.xqm";
import module namespace ab-messages="http://wob2.iai.uni-bonn.de/ab/messages" at "messages-module.xqm";
import module namespace ab-common="http://wob2.iai.uni-bonn.de/ab/common" at "common.xqm";

let $subject := request:get-parameter("subject", "")
let $content := request:get-parameter("content", "")
let $recipients := request:get-parameter("recipients", "")

let $current-user-id := ab-common:get-current-user-id()
let $current-group-id := ab-common:get-current-group-id()

let $parameters := 
<parameters>
	<messages />
	{ ab-common:get-environment() }
</parameters>

let $valid-input := $subject != '' and $content != ''
let $is-initial-request := fn:empty(request:get-parameter-names())

let $message :=
        if($valid-input)
        	then
			<p class='success-message'>{ab-messages:post-message($subject, $current-user-id, $current-group-id, $recipients, $content), response:redirect-to(session:encode-url(xs:anyURI("list_messages.xql")))}</p>
		else if(not($is-initial-request))
			then <p class='error-message'>Sie müssen alle Felder ausfüllen!</p>
		else
			""
return
transform:transform($parameters, xs:anyURI("stylesheets/create_message.xsl"), ())
