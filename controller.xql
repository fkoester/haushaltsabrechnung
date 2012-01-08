declare namespace session="http://exist-db.org/xquery/session";
declare namespace request="http://exist-db.org/xquery/request";
declare namespace response="http://exist-db.org/xquery/response";

import module namespace ab-common="http://wob2.iai.uni-bonn.de/ab/common" at "common.xqm";

let $user-id := ab-common:get-current-user-id()
(:
	Use Content Security Policy to prevent against XSS, see https://wiki.mozilla.org/Security/CSP/Specification
	Currently breaks jQuery DatePicker, therefore commented
:)
(: let $csp := response:set-header("X-Content-Security-Policy", "allow 'self'") :)

return
	(: Let everybody access Login-Page as well as CSS and JavaScript files :)
	if($exist:path = '/login.xql' or starts-with($exist:path, '/css') or starts-with($exist:path, '/js') or starts-with($exist:path, '/fonts') or starts-with($exist:path, '/img')) then
		<ignore xmlns="http://exist.sourceforge.net/NS/exist">
			<cache-control cache="yes"/>
		</ignore>
	(: If user is logged in redirect to requested resource :)
	else if(ab-common:is-user-logged-in()) then
		<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
			<forward url="{$exist:resource}" />
		</dispatch>
	(: Otherwise redirect to login-page :)
	else
		<dispatch xmlns="http://exist.sourceforge.net/NS/exist">
			<forward url="login.xql" />
		</dispatch>
