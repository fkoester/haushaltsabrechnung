(: statistics-module.xqm :)
(: wird verwendet für die Erstellung von Pie- und Bar-Charts :)
(: wird verwendet von show-statistic.xql :)


module namespace ab-statistics="http://wob2.iai.uni-bonn.de/ab/statistics";

import module namespace ab-common="http://wob2.iai.uni-bonn.de/ab/common" at "common.xqm";
import module namespace ab-group="http://wob2.iai.uni-bonn.de/ab/group" at "group-module.xqm";
import module namespace ab-transaction="http://wob2.iai.uni-bonn.de/ab/transaction" at "transaction-module.xqm";

(: Standard Tortengrafik :)
declare function ab-statistics:create-pie($group-id as xs:long, $group-member-name as xs:string+, $group-member-id as xs:string+, $month as xs:integer, $year as xs:integer)  {

let $pie := 
<osgr xmlns="http://graph2svg.googlecode.com" graphType="pie" colorScheme="warm" labelOut="name" labelIn="value">
 <title>{$month}-{$year}</title>
    <names>
	{
		for $user in $group-member-name
			return 
			if (ab-transaction:get-sum-of-transactions-of-user-in-group-in-month(ab-group:get-user-id-by-name($user), $group-id, $month, $year) != 0)
			then <name>{$user}</name>
			else ""
	}
    </names>
    <values>
	{
		for $user in $group-member-id
			return 
			if (ab-transaction:get-sum-of-transactions-of-user-in-group-in-month($user, $group-id, $month, $year) != 0)
			then <value>{ab-transaction:get-sum-of-transactions-of-user-in-group-in-month($user, $group-id, $month, $year)}</value>
			else ""
	}
    </values>
</osgr>

return $pie

};

(: Tortengrafik für einen Zeitraum :)
declare function ab-statistics:create-filtered-pie($group-id as xs:long, $group-member-name as xs:string+, $group-member-id as xs:string+, $start as xs:date, $end as xs:date) as element(osgr) {

let $pie := 
<osgr xmlns="http://graph2svg.googlecode.com" graphType="pie" colorScheme="warm" labelOut="name" labelIn="value">
 <title>Von {$start} bis {$end}</title>
    <names>
	{
		for $user in $group-member-name
			return 
			if (ab-transaction:get-sum-of-transactions-of-user-in-group-in-time(ab-group:get-user-id-by-name($user), $group-id, $start, $end) != 0)
			then <name>{$user}</name>
			else ""
	}
    </names>
    <values>
	{
		for $user in $group-member-id
			return 
			if (ab-transaction:get-sum-of-transactions-of-user-in-group-in-time($user, $group-id, $start, $end) != 0)
			then <value>{ab-transaction:get-sum-of-transactions-of-user-in-group-in-time($user, $group-id, $start, $end)}</value>
			else ""
		(: return <value>{ab-transaction:sum-transactions(ab-transaction:get-transactions-of-creditor($user) , $user)}</value> :)
	}
    </values>
</osgr>

return $pie

};

(: für $pie: zählt die Benutzer, für die Transferwerte verschieden von Null existieren für einen Vergleich :)
declare function ab-statistics:count-over-zero($group-id as xs:long, $group-member-name as xs:string+, $group-member-id as xs:string+, $start as xs:integer, $end as xs:integer) as xs:integer{
let $pie := 
<overzero>
	{
		for $user in $group-member-id
			return 
			if (ab-transaction:get-sum-of-transactions-of-user-in-group-in-month($user, $group-id, $start, $end) != 0)
			then <value/>
			else ""
	}
</overzero>

return count($pie//value)

};

(: für $filtered-pie: zählt die Benutzer, für die Transferwerte verschieden von Null existieren für einen Vergleich :)
declare function ab-statistics:count-over-zero-filter($group-id as xs:long, $group-member-name as xs:string+, $group-member-id as xs:string+, $start as xs:date, $end as xs:date) as xs:integer{
let $pie := 
<overzero>
	{
		for $user in $group-member-id
			return 
			if (ab-transaction:get-sum-of-transactions-of-user-in-group-in-time($user, $group-id, $start, $end) != 0)
			then <value/>
			else ""
	}
</overzero>

return count($pie//value)

};

(: Standard-Bar-Chart :)
declare function ab-statistics:create-bar($group-id as xs:long, $group-member-name as xs:string+, $group-member-id as xs:string+, $year as xs:integer) as element(osgr) {

let $bar :=
<osgr xmlns="http://graph2svg.googlecode.com" effect="3D" labelOut="name" labelIn="value">

 <title>Ausgaben {$year}</title>
    <names>
        <name>Januar</name>
        <name>Februar</name>
        <name>März</name>
        <name>April</name>
        <name>Mai</name>
        <name>Juni</name>
        <name>Juli</name>
        <name>August</name>
        <name>September</name>
        <name>Oktober</name>
        <name>November</name>
        <name>Dezember</name>
    </names>
    <values>	{
		for $months in (1 to 12)
			return 
        <value>{ab-transaction:get-sum-of-transactions-of-group-in-month($group-id, $months, $year)}</value>
	}
    </values>
</osgr>
return $bar
};