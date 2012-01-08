xquery version "1.0";

declare namespace session="http://exist-db.org/xquery/session";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";

declare option exist:serialize "method=html5 media-type=text/html indent=yes";

import module namespace ab-group="http://wob2.iai.uni-bonn.de/ab/group" at "group-module.xqm";

declare function local:login(){
	
	let $user-id := request:get-parameter("user", ())
	let $password := request:get-parameter("password", ())
	let $login := xmldb:login("xmldb:exist:///db/ab", $user-id, $password)
	let $referer := request:get-header("REFERER")
	let $redirect := if($referer != '' and not(ends-with($referer,'/login.xql')) and not(ends-with($referer,'/logout.xql')) and not(ends-with($referer,'/'))) then $referer else "overview.xql"
	
	return
	if ($user-id) 
		then if ($login) then (
			response:redirect-to(xs:anyURI($redirect)))

		else (<info type="error"><message>Falscher Benutzername oder falsches Passwort!</message></info>)
	else
		<dummy />
};

let $message := (session:invalidate(), session:create(),local:login())
return transform:transform($message, xs:anyURI("stylesheets/login.xsl"), ())
