(: messages-module.xqm :)
(: wird verwendet von list_messages.xql und overview.xql :)

module namespace ab-messages="http://wob2.iai.uni-bonn.de/ab/messages";

import module namespace ab-update="http://wob2.iai.uni-bonn.de/ab/update" at "update-module.xqm";

(: Liefert eine Nachricht anhand ihrer ID :)
declare function ab-messages:get-message-by-id($message-id as xs:long) as element(message) {
	doc("/db/ab/messages.xml")/messages/message[@id = $message-id]
};

(: Löscht eine Nachricht anhand ihrer ID :)
declare function ab-messages:delete-message($message-id as xs:long) {
	update delete doc("/db/ab/messages.xml")/messages/message[@id = $message-id]
};

(: Fügt in messages.xml eine Nachricht hinzu :)
declare function ab-messages:post-message($subject as xs:string, $user-id as xs:string, $group-id as xs:long, $recipient as xs:string+, $content as xs:string) as xs:long {

	let $new_message:= update insert <message id="{ab-messages:next-id()}">
		<subject>{$subject}</subject>
		<creation-timestamp>{fn:current-dateTime()}</creation-timestamp>
		<sender id="{$user-id}" />
		<recipients>
		{
			for $user-id in $recipient
				return <recipient id="{$user-id}" status="unread" />
		}
		</recipients>
		<group id="{$group-id}" />
		<content>{$content}</content>
		</message>
		into doc("/db/ab/messages.xml")/messages
		return fn:max(doc("/db/ab/messages.xml")/messages/message/@id)
};

declare function ab-messages:next-id() as xs:long {
	if(count(doc("/db/ab/messages.xml")/messages/message) > 0)
	then fn:max(doc("/db/ab/messages.xml")/messages/message/@id)+1
	else xs:long(0.00)
};

(: Liefert alle Nachrichten eines Nutzers anhand seiner ID :)
declare function ab-messages:get-messages-of-user($user-id as xs:string) as element(messages) {

	<messages>
	{ doc("/db/ab/messages.xml")/messages/message[recipients/recipient/@id = $user-id] }
	</messages>
};

(: Liefert alle ungelesenen Nachrichten eines Nutzers anhand seiner ID :)
declare function ab-messages:get-unread-messages-of-user($user-id as xs:string) as element(messages) {

        <messages>
	        { doc("/db/ab/messages.xml")/messages/message[recipients/recipient[@id = $user-id]/@status = 'unread'] }
        </messages>
};

(: Liefert alle Nachrichten eines Nutzers innerhalb einer bestimmten Gruppe :)
declare function ab-messages:get-messages-of-user-in-group($user-id as xs:string, $group-id as xs:long) as element(messages) {

        <messages>
        { doc("/db/ab/messages.xml")/messages/message[recipients/recipient/@id = $user-id and group/@id = $group-id] }
        </messages>
};

(: Markiert eine Nachricht eines bestimmten Nutzers anhand ihrer ID als gelesen :)
declare function ab-messages:mark-read($message-id as xs:long, $user-id as xs:string) {
	ab-update:set-attribute-value(doc("/db/ab/messages.xml")/messages/message[@id = $message-id]/recipients/recipient[@id = $user-id]/@status, "read")	
};
