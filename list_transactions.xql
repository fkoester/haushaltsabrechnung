declare namespace transform="http://exist-db.org/xquery/transform";
declare namespace session="http://exist-db.org/xquery/session";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare option exist:serialize "method=html5 media-type=text/html indent=yes";

import module namespace ab-common="http://wob2.iai.uni-bonn.de/ab/common" at "common.xqm";
import module namespace ab-transaction="http://wob2.iai.uni-bonn.de/ab/transaction" at "transaction-module.xqm";
import module namespace request="http://exist-db.org/xquery/request";

declare variable $orderby := request:get-parameter("orderby", "booking-date");
declare variable $sort-dir := request:get-parameter("sort-dir", "descending");

let $transactions-of-group := ab-transaction:get-transaction-entries-of-group(ab-common:get-current-group-id(), ab-common:get-current-user-id())

let $sorted-transactions := if ($sort-dir="descending")
					then  if ($orderby="booking-date")
						  then <transactions> {for $x in $transactions-of-group/transaction
							order by $x/booking-date descending
							return $x} </transactions>
								else if ($orderby="amount")
								then <transactions> {for $x in $transactions-of-group/transaction
								order by ($x/transaction-entries/transaction-entry[1]/amount cast as xs:decimal) descending
								return $x} </transactions>
									else if ($orderby="debtors")
									then <transactions> {for $x in $transactions-of-group/transaction
									order by count($x/transaction-entries/transaction-entry[1]/debtors/user) descending
									return $x} </transactions>
											else if ($orderby="payee")
											then <transactions> {for $x in $transactions-of-group/transaction
											order by $x/payee descending
											return $x} </transactions>
												else if ($orderby="description")
												then <transactions> {for $x in $transactions-of-group/transaction
												order by $x/transaction-entries/transaction-entry[1]/description descending
												return $x} </transactions>
													else if ($orderby="creditor")
													then <transactions> {for $x in $transactions-of-group/transaction
													order by $x/creditor/@id descending
													return $x} </transactions>
														else if ($orderby="users-share")
														then <transactions> {for $x in $transactions-of-group/transaction
														order by ($x/transaction-entries/transaction-entry/amount div count($x/transaction-entries/transaction-entry/debtors/user)) descending
														return $x} </transactions>
															else if ($orderby="last-changed")
															then <transactions> {for $x in $transactions-of-group/transaction
															order by (if($x/@last-modified) then $x/@last-modified else $x/@created) descending
															return $x} </transactions>
																else ""
							else if ($sort-dir="ascending") then
								if ($orderby="booking-date") 
								then <transactions> {for $x in $transactions-of-group/transaction
								order by $x/booking-date ascending
								return $x} </transactions>
										else if ($orderby="amount")
										then <transactions> {for $x in $transactions-of-group/transaction
										order by ($x/transaction-entries/transaction-entry[1]/amount cast as xs:decimal) ascending
										return $x} </transactions>
											else if ($orderby="debtors")
											then <transactions> {for $x in $transactions-of-group/transaction
											order by count($x/transaction-entries/transaction-entry[1]/debtors/user) ascending
											return $x} </transactions>
													else if ($orderby="payee")
													then <transactions> {for $x in $transactions-of-group/transaction
													order by $x/payee ascending
													return $x} </transactions>
														else if ($orderby="description")
														then <transactions> {for $x in $transactions-of-group/transaction
														order by $x/transaction-entries/transaction-entry[1]/description ascending
														return $x} </transactions>
																else if ($orderby="creditor")
																then <transactions> {for $x in $transactions-of-group/transaction
																order by $x/creditor/@id ascending
																return $x} </transactions>
																	else if ($orderby="users-share")
																	then <transactions> {for $x in $transactions-of-group/transaction
																	order by ($x/transaction-entries/transaction-entry/amount div count($x/transaction-entries/transaction-entry/debtors/user)) ascending 
																	return $x} </transactions>
																		else if ($orderby="last-changed")
																		then <transactions> {for $x in $transactions-of-group/transaction
																		order by (if($x/@last-modified) then $x/@last-modified else $x/@created) ascending 
																		return $x} </transactions>
																			else ""
							else ""
																	
							
let $parameters :=
	<parameters>
        	{ $sorted-transactions }
	        { ab-common:get-environment() }
	</parameters>

return
transform:transform($parameters, xs:anyURI("stylesheets/list_transactions.xsl"), ())
