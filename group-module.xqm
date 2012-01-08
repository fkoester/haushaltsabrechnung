module namespace ab-group="http://wob2.iai.uni-bonn.de/ab/group"; 

import module namespace ab-update="http://wob2.iai.uni-bonn.de/ab/update" at "update-module.xqm";

declare function ab-group:get-group-members($group-id as xs:long) as element(user)* {
	doc("/db/ab/users.xml")/users/user[groups/group/@id = $group-id]
};

declare function ab-group:get-user-by-id($user-id as xs:string) as element(user)? {
	doc("/db/ab/users.xml")/users/user[@id = $user-id]
};

declare function ab-group:get-user-id-by-name($display-name as xs:string) as xs:string* {
	doc("/db/ab/users.xml")/users/user[display-name = $display-name]/@id
};

declare function ab-group:get-groups-for-user($user-id as xs:string) as element(group)* {
	for $group-id in doc("/db/ab/users.xml")/users/user[@id = $user-id]/groups/group/@id
	return doc("/db/ab/groups.xml")/groups/group[@id = $group-id]
};

declare function ab-group:get-user-by-email($user-email as xs:string) as element(user) {
	doc("/db/ab/users.xml")/users/user[email = $user-email]
};

declare function ab-group:get-group-by-id($group-id as xs:long) as element(group) {
	doc("/db/ab/groups.xml")/groups/group[@id = $group-id]
};

declare function ab-group:delete-group($group-id as xs:long) {
	ab-update:remove-subtree(doc("/db/ab/groups.xml")/groups/group[@id = $group-id])
};

declare function ab-group:group-exists($group-id as xs:long) as xs:boolean {
	exists(doc("/db/ab/groups.xml")/groups/group[@id = $group-id])
};

declare function ab-group:set-group-status($group-id as xs:long, $status as xs:string) {
	ab-update:set-element-value(doc("/db/ab/groups.xml")/groups/group[@id = $group-id]/status, $status)
};

declare function ab-group:add-group-member($group-id as xs:long, $user-id as xs:string) {
	ab-update:add-subtree(<group id="{$group-id}" role="user"/>, doc("/db/ab/users.xml")/users/user[@id = $user-id]/groups)
};

declare function ab-group:add-group($name as xs:string, $description as xs:string, $new-user-type as xs:string,$status as xs:string) as xs:integer{
	let $new_group:= <group id="{fn:max(doc("/db/ab/groups.xml")/groups/group/@id)+1}">
				<name>{$name}</name>
				<description>{$description}</description>
				<new-users-type>{$new-user-type}</new-users-type>
				<status>{$status}</status>
			</group>
	let $result := ab-update:add-subtree($new_group, doc("/db/ab/groups.xml")/groups)
	return fn:max(doc("/db/ab/groups.xml")/groups/group/@id)
};

declare function ab-group:remove-group-member($group-id as xs:long, $user-id as xs:string) {
	ab-update:remove-subtree(doc("/db/ab/users.xml")/users/user[@id = $user-id]/groups/group[@id=$group-id])
};

declare function ab-group:add-user($user-name as xs:string,$user-display-name as xs:string,$user-email as xs:string) as xs:string{
	let $new_user:= <user id="{$user-display-name}">
				<full-name>{$user-name}</full-name>
				<display-name>{$user-display-name}</display-name>
				<email>{$user-email}</email>
				<email-verified/>
				<status>active</status>
				<groups/>
			</user>
	let $result := ab-update:add-subtree($new_user, doc("/db/ab/users.xml")/users)
	return $user-display-name
};

declare function ab-group:delete-user($user-id as xs:string) {
	ab-update:remove-subtree(doc("/db/ab/users.xml")/users/user[@id = $user-id])
};

declare function ab-group:set-user-status($user-id as xs:string, $status as xs:string) {
	ab-update:set-element-value(doc("/db/ab/users.xml")/users/user[@id = $user-id]/status, $status)
};

declare function ab-group:set-role($user-id as xs:string,$group-id as xs:long, $role as xs:string) {
	ab-update:set-attribute-value(doc("/db/ab/users.xml")/users/user[@id = $user-id]/groups/group[@id=$group-id]/@role, $role)
};
