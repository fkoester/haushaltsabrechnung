(: show-ststistic.xql :)
(: Statistikenaufruf :)

declare namespace transform="http://exist-db.org/xquery/transform";
declare namespace session="http://exist-db.org/xquery/session";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace gr = "http://graph2svg.googlecode.com";
declare option exist:serialize "method=html5 media-type=text/html indent=yes";  

import module namespace ab-common="http://wob2.iai.uni-bonn.de/ab/common" at "common.xqm";
import module namespace ab-group="http://wob2.iai.uni-bonn.de/ab/group" at "group-module.xqm";
import module namespace ab-statistics="http://wob2.iai.uni-bonn.de/ab/statistics" at "statistics-module.xqm";
import module namespace ab-transaction="http://wob2.iai.uni-bonn.de/ab/transaction" at "transaction-module.xqm";

(: gängige Variablen:)
let $current-user-id := ab-common:get-current-user-id()
let $current-group-id := ab-common:get-current-group-id()
let $group-members  := ab-common:get-current-group-members()
let $transactions-of-group  := ab-transaction:get-transactions-of-group($current-group-id)

(: Zeitabhängige Variablen für die Diagramme :)
let $current-date := fn:current-dateTime()
let $current-month := fn:month-from-date($current-date)
let $current-year := fn:year-from-date($current-date)
let $start-date := request:get-parameter("filter-start-date", "")
let $end-date := request:get-parameter("filter-end-date", "")
let $month := request:get-parameter("month", $current-month)
let $year := request:get-parameter("year", $current-year)

(: Aufbau der Diagramme  :)
(: Torte wird standardmäßig für den aktuellen Monat im aktuellen Jahr erstellt, Bar für das aktuelle Jahr :)
let $pie := if (($start-date != "") and ($end-date != ""))
			then ab-statistics:create-filtered-pie($current-group-id, $group-members/display-name, $group-members/@id, $start-date, $end-date)
			else
			ab-statistics:create-pie($current-group-id, $group-members/display-name, $group-members/@id, xs:integer($month), xs:integer($year))

let $bar := ab-statistics:create-bar($current-group-id, $group-members/display-name, $group-members/@id, xs:integer($year))

let $emptypie := "Ein Nutzer trägt allein alle Kosten für diesen Zeitraum!"

(: container für alle Daten :)
let $parameters :=
	<parameters>
		{ ab-common:get-environment() }
		<charts>
			{ if (($start-date = "") and ($end-date = ""))			
			  then if (ab-statistics:count-over-zero($current-group-id, $group-members/display-name, $group-members/@id, xs:integer($month), xs:integer($year))>1)
				   then $pie else $emptypie
			  else if (ab-statistics:count-over-zero-filter($current-group-id, $group-members/display-name, $group-members/@id, xs:date($start-date), xs:date($end-date))>1) 
			  then $pie else $emptypie
			 }
			{ $bar }
		</charts>
	</parameters>

return
transform:transform($parameters, xs:anyURI("stylesheets/statistic.xsl"), ())