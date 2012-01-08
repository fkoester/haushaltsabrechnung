(: common.xqm :)
(: Liefert Informationen über den aktuellen Zustand der Anwendung wie z.B. den derzeit eingeloggten Nutzer :) 

module namespace ab-common="http://wob2.iai.uni-bonn.de/ab/common";

import module namespace ab-group="http://wob2.iai.uni-bonn.de/ab/group" at "group-module.xqm";
import module namespace ab-so="http://wob2.iai.uni-bonn.de/ab/standing-orders" at "standing-orders-module.xqm";

(: liefert die aktuelle Gruppe, den derzeit eingeloggten Nutzer, die Mitglieder der aktuellen Gruppe und die Gruppen in denen der Nutzer vertreten ist :)
declare function ab-common:get-environment() as element(environment) {
	
	let $standing-orders := ab-so:process-pending-standing-orders()
	let $current-user-id := ab-common:get-current-user-id()
	let $current-user := ab-group:get-user-by-id($current-user-id)
	let $current-group := ab-group:get-group-by-id(ab-common:get-current-group-id())

	let $group-members := ab-common:get-current-group-members()
	let $groups := ab-common:get-groups-for-current-user()

	return 
	<environment>
	        <current-group>{$current-group}</current-group>
		<current-user>{$current-user}</current-user>
	        <group-members>{$group-members}</group-members>
	        <groups>{$groups}</groups>
		<state-params>{ab-common:get-application-state-as-parameters()}</state-params>
		{ab-common:get-application-state()}
	</environment>
};

declare function ab-common:get-application-state() as element(state) {
	<state>
		<property>
			<name>current-group-id</name>
			<value>{ab-common:get-current-group-id()}</value>
		</property>
	</state>
};

declare function ab-common:get-application-state-as-parameters() as xs:string {
	string-join(
		(for $property in ab-common:get-application-state()/property
		return string-join(($property/name,'=',$property/value), '')),
	'&amp;')
};

(: Test ob derzeit ein Nutzer eingeloggt ist :)
declare function ab-common:is-user-logged-in() as xs:boolean {
	not(empty(ab-group:get-user-by-id(ab-common:get-current-user-id())))
};

(: liefert die ID des eingeloggten Nutzers :)
declare function ab-common:get-current-user-id() as xs:string {
	xmldb:get-current-user()
};

(: Liefert die ID der aktuellen Gruppe :)
declare function ab-common:get-current-group-id() as xs:long {
	let $requested-group-id := request:get-parameter("current-group-id", "")
	let $user-id := ab-common:get-current-user-id()
	let $users-groups := ab-group:get-groups-for-user($user-id)

	return if($requested-group-id castable as xs:long and $users-groups[@id = xs:long($requested-group-id)])
		then xs:long($requested-group-id)
		else $users-groups[1]/@id
};

(: Liefert alle Mitglieder der aktuellen Gruppe :)
declare function ab-common:get-current-group-members() as element(user)* {
	ab-group:get-group-members(ab-common:get-current-group-id())
};


(: Liefert alle Gruppen in denen der Nutzer vertreten ist :)
declare function ab-common:get-groups-for-current-user() as element(group)* {
	ab-group:get-groups-for-user(ab-common:get-current-user-id())
};


declare function ab-common:get-parameters-starting-with($prefix as xs:string) as element(parameters) {
	let $parameter-names := request:get-parameter-names()
	return
	<parameters>
	{
		for $parameter-name in $parameter-names
		where starts-with($parameter-name, $prefix)
		return
			let $index := substring-after($parameter-name, $prefix)
			return
				<parameter index="{$index}">
					<name>{$prefix}</name>
					<value>{request:get-parameter($parameter-name, '')}</value>
				</parameter>
	}
	</parameters>
};

