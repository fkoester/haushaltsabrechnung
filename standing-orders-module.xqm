xquery version "1.0";

module namespace ab-so="http://wob2.iai.uni-bonn.de/ab/standing-orders";

import module namespace ab-update="http://wob2.iai.uni-bonn.de/ab/update" at "update-module.xqm";
import module namespace ab-transaction="http://wob2.iai.uni-bonn.de/ab/transaction" at "transaction-module.xqm";
(: import the functx module with the  day of week name function :)
import module namespace functx="http://www.functx.com" at "3rdparty/functx-1.0-doc-2007-01.xq";

declare function ab-so:get-standing-orders-of-group($group-id as xs:long) {
	<standing-orders>
	{ doc("/db/ab/standing-orders.xml")/standing-orders/standing-order[transaction/groups/group/@id = $group-id] } 
	</standing-orders>
};

declare function ab-so:process-pending-standing-orders() {

	for $standing-order in ab-so:get-pending-standing-order-instances()
	return
		ab-so:create-standing-order-instance($standing-order)

};

declare function ab-so:create-standing-order(
	$user-id as xs:string,
	$group-id as xs:long,
	$description as xs:string,
	$payee as xs:string,
	$debtors as xs:string+,
	$amount as xs:string,
	$start-date as xs:date,
	$end-date as xs:string?,
	$recurrence-weekly as xs:boolean,
	$weekly-week-interval as xs:integer,
	$weekly-weekday as xs:integer,
	$monthly-type-on-weekday as xs:boolean,
	$monthly-month-interval as xs:integer,
	$monthly-day-of-month as xs:integer,
	$monthly-weekday-number as xs:integer,
	$monthly-weekday as xs:integer,
	$sub-transaction-descriptions as element(parameters),
	$sub-transaction-amounts as element(parameters),
	$sub-transaction-debtors as element(parameters)) as xs:long {

	let $new_id := ab-so:next-id()
		let $new_so := 
		<standing-order id="{$new_id}">
			<transaction>
				<creditor id="{$user-id}" />
				<groups>
					<group id="{$group-id}" />
				</groups>
				<payee>{$payee}</payee>
				<transaction-entries>
					<transaction-entry>
						<description>{$description}</description>
						<amount currency="EUR">{ab-transaction:calculate-amount-from-string($amount)}</amount>
						<debtors>
						{
							for $user-id in $debtors
							return <user id="{$user-id}" />
						}
						</debtors>
					</transaction-entry>
					{
						for $sub-transaction-description in $sub-transaction-descriptions/parameter
						order by $sub-transaction-description/@index
						return
							<transaction-entry>
								<description>{data($sub-transaction-description/value)}</description>
								<amount currency="EUR">
								{ ab-transaction:calculate-amount-from-string($sub-transaction-amounts/parameter[@index = $sub-transaction-description/@index]/value) }
								</amount>
								<debtors>
								{
									for $user-id in tokenize($sub-transaction-debtors/parameter[@index = $sub-transaction-description/@index]/value, ' ')
									return <user id="{$user-id}" />
								}
								</debtors>
							</transaction-entry>
					}
				</transaction-entries>
			</transaction>
			<start-date>{ $start-date }</start-date>
			{ if ($end-date castable as xs:date) then <end-date>{xs:date($end-date)}</end-date> else () }
			{ if ($recurrence-weekly) then
				<recurrence type="weekly">
					<day-time-interval>P{ $weekly-week-interval * 7 }D</day-time-interval>
					<day-of-week>{ $weekly-weekday }</day-of-week>
				</recurrence>
				else if ($monthly-type-on-weekday) then
				<recurrence type="monthly-on-day-of-week">
					<month-year-interval>P{ $monthly-month-interval }M</month-year-interval>
					<weekday-number>{ $monthly-weekday-number }</weekday-number>
					<day-of-week>{ $monthly-weekday }</day-of-week>
				</recurrence>
				else
				<recurrence type="monthly-on-day-of-month">
					<month-year-interval>P{ $monthly-month-interval }M</month-year-interval>
					<day-of-month>{ $monthly-day-of-month }</day-of-month>
				</recurrence>
			}
		</standing-order>

		let $result := ab-update:add-subtree($new_so, doc("/db/ab/standing-orders.xml")/standing-orders)

		return $new_id
};

declare function ab-so:next-id() as xs:long {
        if(count(doc("/db/ab/standing-orders.xml")/standing-orders/standing-order) > 0)
        then fn:max(doc("/db/ab/standing-orders.xml")/standing-orders/standing-order/@id)+1
        else xs:long(0.00)
};

declare function ab-so:get-pending-standing-order-instances() as element(transaction)* {
	for $standing-order in doc("/db/ab/standing-orders.xml")/standing-orders/standing-order
	where xs:date($standing-order/start-date) < current-date()
	return
		let $instances-created := doc("/db/ab/transactions.xml")/transactions/transaction[@created-from-standing-order-id = $standing-order/@id]/booking-date
		return
			let $monthly := starts-with($standing-order/recurrence/@type, 'monthly')
			let $monthly-on-day-of-week := $standing-order/recurrence/@type = 'monthly-on-day-of-week'
			let $interval := if ($monthly)
						then xs:yearMonthDuration($standing-order/recurrence/month-year-interval)
						else xs:dayTimeDuration($standing-order/recurrence/day-time-interval)
			(:
				This does not have to be very precise because it is just for the number of instances to add.
				The real booking date is calculated from 'day-of-month' or 'day-of-week' fields
			:)
			let $interval-in-days := if ($monthly)
							then xs:dayTimeDuration(concat('P', (years-from-duration($interval) * 365 + months-from-duration($interval) * 30), 'D'))
							else $interval
			let $start := if (not($instances-created)) then xs:date($standing-order/start-date) else xs:date($instances-created[position()=last()]) + $interval
			let $real-start := if($monthly-on-day-of-week or not($monthly))
						then ab-so:get-next-matching-day-of-week($start, $standing-order/recurrence/day-of-week)
						else ab-so:get-next-matching-day-of-month($start, $standing-order/recurrence/day-of-month)
			let $end := if($standing-order/end-date and xs:date($standing-order/end-date) < current-date()) then xs:date($standing-order/end-date) else current-date()
			let $missing-instances := xs:integer(($end - $real-start) div $interval-in-days)
			return
				if ($missing-instances > 0) then
					for $index in 0 to $missing-instances
					let $booking-date := xs:date($real-start + $index * $interval)
					return element { 'transaction' }
						{($standing-order/transaction/@*,
						attribute { "created-from-standing-order-id" } { $standing-order/@id }),
						$standing-order/transaction/*, element booking-date { $booking-date }} 
				else ()
};

declare function ab-so:get-next-matching-day-of-week($start-date as xs:date, $day-of-week as xs:integer) as xs:date {
	let $start-day-of-week : = functx:day-of-week($start-date)
	let $diff := if ($start-day-of-week > $day-of-week)
			then 7 + $day-of-week - $start-day-of-week
			else $day-of-week - $start-day-of-week
	return $start-date + (xs:dayTimeDuration("P1D") * $diff)
};

declare function ab-so:get-next-matching-day-of-month($start-date as xs:date, $day-of-month as xs:integer) as xs:date {
	let $start-day-of-month := day-from-date($start-date)
	let $start-month := month-from-date($start-date)
	let $start-year := year-from-date($start-date)
	return
		if ($start-day-of-month < $day-of-month)
		then functx:date($start-year, $start-month, $day-of-month)
		else if($start-month = 12) 
		then functx:date($start-year + 1, 1, $day-of-month)
		else functx:date($start-year, $start-month+1, $day-of-month)
};

declare function ab-so:create-standing-order-instance($standing-order-instance as element(transaction)) {

	ab-transaction:persist-transaction($standing-order-instance)
};
