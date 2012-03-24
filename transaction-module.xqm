module namespace ab-transaction="http://wob2.iai.uni-bonn.de/ab/transaction";

import module namespace ab-group="http://wob2.iai.uni-bonn.de/ab/group" at "group-module.xqm";
import module namespace ab-update="http://wob2.iai.uni-bonn.de/ab/update" at "update-module.xqm";
import module namespace ab-formula="http://wob2.iai.uni-bonn.de/ab/formula" at "formula.xqm";

declare function ab-transaction:create-transaction($user-id as xs:string, $group-id as xs:long, $description as xs:string, $payee as xs:string, $debtors as xs:string+, $amount as xs:string, $booking-date as xs:date, $sub-transaction-descriptions as element(parameters), $sub-transaction-amounts as element(parameters), $sub-transaction-debtors as element(parameters)) as xs:long {
	let $new-id := ab-transaction:next-id()
	let $new-transaction := ab-transaction:build-transaction($new-id, $user-id, $group-id, $description, $payee, $debtors, $amount, $booking-date, $sub-transaction-descriptions, $sub-transaction-amounts, $sub-transaction-debtors)
	let $result := ab-update:add-subtree($new-transaction, doc("/db/ab/transactions.xml")/transactions)

	return $new-id
};

declare function ab-transaction:update-transaction($transaction-id as xs:long, $user-id as xs:string, $group-id as xs:long, $description as xs:string, $payee as xs:string, $debtors as xs:string+, $amount as xs:string, $booking-date as xs:date, $sub-transaction-descriptions as element(parameters), $sub-transaction-amounts as element(parameters), $sub-transaction-debtors as element(parameters)) {

	let $updated-transaction := ab-transaction:build-transaction($transaction-id, $user-id, $group-id, $description, $payee, $debtors, $amount, $booking-date, $sub-transaction-descriptions, $sub-transaction-amounts, $sub-transaction-debtors)
	return ab-update:replace-subtree(doc("/db/ab/transactions.xml")/transactions/transaction[@id=$transaction-id], $updated-transaction)
};

declare function ab-transaction:build-transaction($transaction-id as xs:long, $user-id as xs:string, $group-id as xs:long, $description as xs:string, $payee as xs:string, $debtors as xs:string+, $amount as xs:string, $booking-date as xs:date, $sub-transaction-descriptions as element(parameters), $sub-transaction-amounts as element(parameters), $sub-transaction-debtors as element(parameters)) as element(transaction) {
	 <transaction id="{$transaction-id}">
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
		<booking-date>{$booking-date}</booking-date>
	</transaction>
};

declare function ab-transaction:next-id() as xs:long {
	if(count(doc("/db/ab/transactions.xml")/transactions/transaction) > 0)
	then fn:max(doc("/db/ab/transactions.xml")/transactions/transaction/@id)+1
	else xs:long(0.00)
};

declare function ab-transaction:persist-transaction($transaction as element(transaction)) {
	let $new_transaction := element { "transaction" } {($transaction/@*[local-name()!='id'],
				attribute { "id" } { ab-transaction:next-id() }),
				$transaction/*}
	return	ab-update:add-subtree($new_transaction, doc("/db/ab/transactions.xml")/transactions)
};

declare function ab-transaction:get-transactions-of-group($group-id as xs:long) as element(transactions) {

	<transactions>
	{ doc("/db/ab/transactions.xml")/transactions/transaction[groups/group/@id = $group-id] }
	</transactions>
};

declare function ab-transaction:get-transaction-entries-of-group($group-id as xs:long, $debtor-id as xs:string) as element(transactions) {

	<transactions>
	{ ab-transaction:split-multi-transaction-entries(doc("/db/ab/transactions.xml")/transactions/transaction[groups/group/@id = $group-id])[transaction-entries/transaction-entry/debtors/user/@id = $debtor-id or creditor/@id = xmldb:get-current-user()] }
	</transactions>
};

declare function ab-transaction:get-transactions-of-group($group-id as xs:long, $max-per-user as xs:integer, $debtor-id as xs:string) as element(transactions)* {

	for $creditor-id in ab-group:get-group-members($group-id)/@id
	let $transactions := subsequence(reverse(doc("/db/ab/transactions.xml")/transactions/transaction[groups/group/@id = $group-id and creditor/@id = $creditor-id and (transaction-entries/transaction-entry/debtors/user/@id = $debtor-id or creditor/@id = xmldb:get-current-user())]), 1, $max-per-user)
	return
		<transactions creditor-id="{$creditor-id}">
			{ $transactions }
		</transactions>
};

declare function ab-transaction:get-transaction-entries-of-group($group-id as xs:long, $max-per-user as xs:integer, $debtor-id as xs:string) as element(transactions)* {
	for $creditor-id in ab-group:get-group-members($group-id)/@id
	let $transactions := subsequence(reverse(ab-transaction:split-multi-transaction-entries(doc("/db/ab/transactions.xml")/transactions/transaction[groups/group/@id = $group-id and creditor/@id = $creditor-id])[transaction-entries/transaction-entry/debtors/user/@id = $debtor-id or xmldb:get-current-user()]), 1, $max-per-user)
	return
		<transactions creditor-id="{$creditor-id}">
			{ $transactions }
		</transactions>
};

declare function ab-transaction:split-multi-transaction-entries($transactions as element(transaction)*) as element(transaction)* {
	for $transaction in $transactions
	return
		if(count($transaction/transaction-entries/transaction-entry) = 1)
		then $transaction
		else
		for $transaction-entry at $position in $transaction/transaction-entries/transaction-entry
		return
			<transaction instance="{$position}">
				{ $transaction/@* }
				{ $transaction/*[local-name() != 'transaction-entries'] }
				<transaction-entries>
					<transaction-entry>
						{ $transaction-entry/*[local-name() != 'amount'] }
						{ if($position = 1) then
							(: Why is amount not calculated precisely here??? :)
							<amount currency="{$transaction-entry/amount/@currency}">{$transaction-entry/amount - sum($transaction/transaction-entries/transaction-entry[position() != 1]/amount)}</amount>
						  else
							$transaction-entry/amount
						}
					</transaction-entry>
				</transaction-entries>
			</transaction>
};


declare function ab-transaction:get-balances-of-group-for-user($group-id as xs:long, $user-id as xs:string) as element(balances) {
	<balances>
	{
		for $group-member in ab-group:get-group-members($group-id)
		where $group-member/@id != $user-id
		return ab-transaction:get-formatted-balance-between-users-in-group($user-id, $group-member/@id, $group-id)
	}
	</balances>
};

declare function ab-transaction:get-formatted-balance-between-users-in-group($user-id as xs:string, $group-member as xs:string, $group-id as xs:long) as element(balance) {

	<balance>
		<user id="{$group-member}">
			<display-name>{ab-group:get-user-by-id($group-member)/display-name}</display-name>
		</user>
		<amount>{ab-transaction:get-balance-between-users-in-group($user-id, $group-member, $group-id)}</amount>
	</balance>
};

declare function ab-transaction:get-balance-between-users-in-group($user-id as xs:string, $group-member as xs:string, $group-id as xs:long) as xs:float {
        ab-transaction:get-debts-of-user-in-group($user-id, $group-member, $group-id)-ab-transaction:get-debts-of-user-in-group($group-member, $user-id, $group-id)
};


declare function ab-transaction:get-balance-between-users($user-id as xs:string, $group-member as xs:string) as xs:float {
	ab-transaction:get-debts-of($user-id, $group-member)-ab-transaction:get-debts-of($group-member, $user-id)
};

declare function ab-transaction:get-debts-of($user-id as xs:string, $group-member as xs:string) as xs:float {
	sum(
		for $transaction in doc("/db/ab/transactions.xml")/transactions/transaction
		where $transaction/creditor/@id = $user-id
		return
			let $entries := $transaction/transaction-entries/transaction-entry
			return
			(
				if(exists($entries[1]/debtors/user[@id=$group-member])) then
					($entries[1]/amount - sum($entries[position()!=1]/amount)) div count($entries[1]/debtors/user)
				else 0,
						
				for $sub-transaction in $entries[position()!=1]
				where exists($sub-transaction/debtors/user[@id=$group-member])
				return $sub-transaction/amount div count($sub-transaction/debtors/user)
				
			)
	)
};

declare function ab-transaction:get-debts-of-user-in-group($user-id as xs:string, $group-member as xs:string, $group-id as xs:long) as xs:float {
	sum(
			for $transaction in doc("/db/ab/transactions.xml")/transactions/transaction
			where $transaction/creditor/@id = $user-id and $transaction/groups/group/@id =$group-id
			return
			let $entries := $transaction/transaction-entries/transaction-entry
			return
			(
			 if(exists($entries[1]/debtors/user[@id=$group-member])) then
			 ($entries[1]/amount - sum($entries[position()!=1]/amount)) div count($entries[1]/debtors/user)
			 else 0,

			 for $sub-transaction in $entries[position()!=1]
			 where exists($sub-transaction/debtors/user[@id=$group-member])
			 return $sub-transaction/amount div count($sub-transaction/debtors/user)

			)
	   )
};

declare function ab-transaction:calculate-amount-from-string($amount-expression as xs:string) as xs:float {

	xs:float(ab-formula:calculate-formula-value-from-string($amount-expression))
};


(: andreas :)
declare function ab-transaction:get-sum-of-transactions-of-user-in-group ($user-id as xs:string, $group-id as xs:long) as xs:double {
	round-half-to-even ( sum (
		for $transaction in doc("/db/ab/transactions.xml")/transactions/transaction
		where $transaction/creditor/@id = $user-id and $transaction/groups/group/@id = $group-id
		return
		$transaction/transaction-entries/transaction-entry/amount
		), 2)
};

declare function ab-transaction:get-sum-of-transactions-of-user-in-group-in-month ($user-id as xs:string, $group-id as xs:long, $month as xs:integer, $year as xs:integer) as xs:double {
	round-half-to-even ( sum (
		for $transaction in doc("/db/ab/transactions.xml")/transactions/transaction
		where $transaction/creditor/@id = $user-id and $transaction/groups/group/@id = $group-id  and (fn:month-from-date($transaction/booking-date) eq $month) and fn:year-from-date($transaction/booking-date) eq $year
		return
		$transaction/transaction-entries/transaction-entry/amount
		), 2)
};

declare function ab-transaction:get-sum-of-transactions-of-user-in-group-in-time ($user-id as xs:string, $group-id as xs:long, $start as xs:date, $end as xs:date) as xs:double {
	round-half-to-even ( sum (
		for $transaction in doc("/db/ab/transactions.xml")/transactions/transaction
		where $transaction/creditor/@id = $user-id and $transaction/groups/group/@id = $group-id  and ($transaction/booking-date >= $start) and ($transaction/booking-date <= $end)
		return
		$transaction/transaction-entries/transaction-entry/amount
		), 2)
};

declare function ab-transaction:get-sum-of-transactions-of-group-in-month ($group-id as xs:long, $month as xs:integer, $year as xs:integer ) as xs:double {
	round-half-to-even ( sum (
		for $transaction in doc("/db/ab/transactions.xml")/transactions/transaction
		where $transaction/groups/group/@id = $group-id and (fn:month-from-date($transaction/booking-date) eq $month) and fn:year-from-date($transaction/booking-date) eq $year
		return
		$transaction/transaction-entries/transaction-entry/amount
		), 2)
};
