declare namespace transform="http://exist-db.org/xquery/transform";
declare namespace session="http://exist-db.org/xquery/session";
declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare option exist:serialize "method=html5 media-type=text/html indent=yes";

import module namespace ab-common="http://wob2.iai.uni-bonn.de/ab/common" at "common.xqm";
import module namespace ab-standing-orders="http://wob2.iai.uni-bonn.de/ab/standing-orders" at "standing-orders-module.xqm";
import module namespace request="http://exist-db.org/xquery/request";

declare variable $orderby := request:get-parameter("orderby", "interval");
declare variable $sort-dir := request:get-parameter("sort-dir", "descending");

let $standing-orders-of-group := ab-standing-orders:get-standing-orders-of-group(ab-common:get-current-group-id())

let $sorted-standing-orders := if ($sort-dir="descending")
					then  if ($orderby="interval")
						  then <standing-orders> {for $x in $standing-orders-of-group/standing-order
							order by $x/recurrence/month-year-interval descending
							return $x} </standing-orders>
								else if ($orderby="amount")
								then <standing-orders> {for $x in $standing-orders-of-group/standing-order
								order by ($x/transaction/transaction-entries/transaction-entry[1]/amount cast as xs:decimal) descending
								return $x} </standing-orders>
									else if ($orderby="debtors")
									then <standing-orders> {for $x in $standing-orders-of-group/standing-order
									order by count($x/transaction/transaction-entries/transaction-entry[1]/debtors/user) descending
									return $x} </standing-orders>
											else if ($orderby="payee")
											then <standing-orders> {for $x in $standing-orders-of-group/standing-order
											order by $x/transaction/payee descending
											return $x} </standing-orders>
												else if ($orderby="description")
												then <standing-orders> {for $x in $standing-orders-of-group/standing-order
												order by $x/transaction/transaction-entries/transaction-entry[1]/description descending
												return $x} </standing-orders>
													else if ($orderby="creditor")
													then <standing-orders> {for $x in $standing-orders-of-group/standing-order
													order by $x/transaction/creditor/@id descending
													return $x} </standing-orders>
														else ""
							else if ($sort-dir="ascending") then
								if ($orderby="interval") 
								then <standing-orders> {for $x in $standing-orders-of-group/standing-order
								order by $x/recurrence/month-year-interval ascending
								return $x} </standing-orders>
										else if ($orderby="amount")
										then <standing-orders> {for $x in $standing-orders-of-group/standing-order
										order by ($x/transaction/transaction-entries/transaction-entry[1]/amount cast as xs:decimal) ascending
										return $x} </standing-orders>
											else if ($orderby="debtors")
											then <standing-orders> {for $x in $standing-orders-of-group/standing-order
											order by count($x/transaction/transaction-entries/transaction-entry[1]/debtors/user) ascending
											return $x} </standing-orders>
													else if ($orderby="payee")
													then <standing-orders> {for $x in $standing-orders-of-group/standing-order
													order by $x/transaction/payee ascending
													return $x} </standing-orders>
														else if ($orderby="description")
														then <standing-orders> {for $x in $standing-orders-of-group/standing-order
														order by $x/transaction/transaction-entries/transaction-entry[1]/description ascending
														return $x} </standing-orders>
																else if ($orderby="creditor")
																then <standing-orders> {for $x in $standing-orders-of-group/standing-order
																order by $x/transaction/creditor/@id ascending
																return $x} </standing-orders>
																	else ""
							else ""
																	
							
let $parameters :=
	<parameters>
        	{ $sorted-standing-orders }
	        { ab-common:get-environment() }
	</parameters>

return
transform:transform($parameters, xs:anyURI("stylesheets/list_standing_orders.xsl"), ())
