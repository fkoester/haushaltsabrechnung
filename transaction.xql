declare namespace transform="http://exist-db.org/xquery/transform";
declare namespace session="http://exist-db.org/xquery/session";
declare option exist:serialize "method=html5 media-type=text/html indent=yes";

import module namespace ab-group="http://wob2.iai.uni-bonn.de/ab/group" at "group-module.xqm";
import module namespace ab-transaction="http://wob2.iai.uni-bonn.de/ab/transaction" at "transaction-module.xqm";
import module namespace ab-so="http://wob2.iai.uni-bonn.de/ab/standing-orders" at "standing-orders-module.xqm";
import module namespace ab-common="http://wob2.iai.uni-bonn.de/ab/common" at "common.xqm";
import module namespace ab-formula="http://wob2.iai.uni-bonn.de/ab/formula" at "formula.xqm";

let $operation := request:get-parameter("operation", "create")
let $transaction-id := request:get-parameter("id", "")
let $description := request:get-parameter("description", "")
let $amount := request:get-parameter("amount", "")
let $payee := request:get-parameter("payee", "")
let $debtors := request:get-parameter("debtors", "")
let $booking-date := request:get-parameter("booking-date", "")
let $start-date := request:get-parameter("start-date", "")
let $end-date := request:get-parameter("end-date", "")
let $weekly-week-interval := request:get-parameter("weekly-week-interval", "1")
let $weekly-weekday := request:get-parameter("weekly-weekday", "2") 
let $monthly-month-interval := request:get-parameter("monthly-month-interval", "1")
let $monthly-day-of-month := request:get-parameter("monthly-day-of-month", "1")
let $monthly-weekday-number := request:get-parameter("monthly-weekday-number", "1")
let $monthly-weekday := request:get-parameter("monthly-weekday", "2")
let $recurrence-weekly := request:get-parameter("recurrence", "") = "weekly"
let $monthly-type-on-weekday := request:get-parameter("monthly-type", "") = "on-weekday"
let $is-initial-request := not(contains(request:get-parameter-names(), 'description'))

let $sub-transaction-descriptions := ab-common:get-parameters-starting-with('sub-transaction-description_')
let $sub-transaction-amounts := ab-common:get-parameters-starting-with('sub-transaction-amount_')
let $sub-transaction-debtors := ab-common:get-parameters-starting-with('sub-transaction-debtors_')
let $sub-trans-count := count($sub-transaction-descriptions/parameter)

let $current-user-id := ab-common:get-current-user-id()
let $current-group-id := ab-common:get-current-group-id()

let $is-standing-order := xs:boolean(request:get-parameter("occurrences", "") = "multi")
let $are-formulas-wellformed := ab-formula:is-wellformed($amount) and not((for $formula in $sub-transaction-amounts/parameter/value return if(ab-formula:is-wellformed($formula)) then () else true()))
let $sub-transaction-debtors-empty := count($sub-transaction-debtors/parameter) != $sub-trans-count
let $sub-transaction-amounts-valid := if ($is-initial-request or $sub-trans-count = 0 or not($are-formulas-wellformed)) then true() else sum(for $sub-amount in $sub-transaction-amounts/parameter/value return ab-transaction:calculate-amount-from-string($sub-amount)) le ab-transaction:calculate-amount-from-string($amount)
(:let $sub-trans-debtors-not-in-main-trans := exists(for $sub-debtors in $sub-transaction-debtors/parameter/value return for $sub-debtor in tokenize($sub-debtors, ' ') return if ($sub-debtor = $debtors) then () else true()) :)
let $valid-input := $description != '' and $amount != '' and $payee != '' and $debtors != '' and (( $booking-date != '' and not($is-standing-order)) or ($start-date != '' and $is-standing-order)) and $are-formulas-wellformed and not($sub-transaction-debtors-empty) and $sub-transaction-amounts-valid (:and not($sub-trans-debtors-not-in-main-trans) :)

let $add-sub-transaction := request:get-parameter("add-sub-transaction", "") != ''
(:let $transaction-entry-count := if ($add-sub-transaction) then ($sub-trans-count + 2) else ($sub-trans-count + 1):)
let $transaction-entry-count := 1

let $message :=
	if ($is-standing-order and $valid-input)
		then 
			<info type='success'>
				<message>Der Dauerauftrag wurde erfolgreich angelegt!</message>
				{ab-so:create-standing-order(
					$current-user-id,
					$current-group-id,
					$description,
					$payee,
					$debtors,
					$amount,
					xs:date($start-date),
					$end-date,
					$recurrence-weekly,
					xs:integer($weekly-week-interval),
					xs:integer($weekly-weekday),
					xs:boolean($monthly-type-on-weekday),
					xs:integer($monthly-month-interval),
					xs:integer($monthly-day-of-month),
					xs:integer($monthly-weekday-number),
					xs:integer($monthly-weekday),
					$sub-transaction-descriptions,
					$sub-transaction-amounts,
					$sub-transaction-debtors)
				}
			</info>
	else if($operation = 'edit' and $transaction-id castable as xs:long and $valid-input and doc("/db/ab/transactions.xml")/transactions/transaction[@id=$transaction-id]/creditor/@id = $current-user-id)
		then <info type='success'><message>Datensatz erfolgreich geändert!</message>{ab-transaction:update-transaction(xs:long($transaction-id), $current-user-id, $current-group-id, $description, $payee, $debtors, $amount, xs:date($booking-date), $sub-transaction-descriptions, $sub-transaction-amounts, $sub-transaction-debtors)}</info>
        else if($valid-input)
	       	then <info type='success'><message>Die Kosten wurden erfolgreich eingetragen!</message>{ab-transaction:create-transaction($current-user-id, $current-group-id, $description, $payee, $debtors, $amount, xs:date($booking-date), $sub-transaction-descriptions, $sub-transaction-amounts, $sub-transaction-debtors)}</info>
	else if(not($is-initial-request) and $debtors = '')
		then <info type="error"><message>Sie müssen mindestens eine beteiligte Person auswählen!</message></info>
	else if (not($is-initial-request) and $sub-transaction-debtors-empty)
		then <info type="error"><message>Teileinkäufe müssen mindestens eine beteiligte Person haben!</message></info>
	else if (not($is-initial-request) and not($are-formulas-wellformed))
		then <info type="error"><message>Eines oder mehrere Betragsfelder enthalten ungültige Eingaben!</message></info>
	else if (not($is-initial-request) and not($sub-transaction-amounts-valid))
		then <info type="error"><message>Die Summe der Beträge der Teileinkäufe ist größer als der Betrag des Gesamteinkaufs!</message></info>
	(: else if (not($is-initial-request) and $sub-trans-debtors-not-in-main-trans)
		then <info type="error"><message>An einem Teileinkauf beteiligte Personen müssen auch am Haupteinkauf beteiligt sein!</message></info> :)
	else if (not($is-initial-request))
		then <info type="error"><message>Sie müssen alle Felder ausfüllen!</message></info>
	else
		()

let $transaction := if($operation = 'create') then
	<transaction>
		<creditor />
		<groups>
			<group id="{$current-group-id}" />
		</groups>
		<payee />
		<transaction-entries>
		{ for $index in 1 to $transaction-entry-count return
			<transaction-entry>
				<description />
				<categories />
				<amount currency="EUR" />
				<debtors>
				{ ab-common:get-current-group-members() } 
				</debtors>
			</transaction-entry>
		}
		</transaction-entries>
		<booking-date />
	</transaction> else doc("/db/ab/transactions.xml")/transactions/transaction[@id=$transaction-id]

let $parameters :=
<parameters>
	{ $message }
	{ $transaction }
	{ ab-common:get-environment() }
</parameters>

return
if($operation = 'create')
then transform:transform($parameters, xs:anyURI("stylesheets/create_transaction.xsl"), ())
else transform:transform($parameters, xs:anyURI("stylesheets/edit_transaction.xsl"), ())
