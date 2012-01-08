module namespace ab-formula="http://wob2.iai.uni-bonn.de/ab/formula";

declare function ab-formula:calculate-formula-value-from-string($formula as xs:string) as xs:double {
	if(ab-formula:is-wellformed($formula))
	then xs:double(ab-formula:calculate(ab-formula:tokenize(concat('(', replace($formula, ',', '.'), ')'), 1), (), 1))
	else error(xs:QName('ab-formula-not-wellformed'), 'Der gegebene Wert oder die Formel sind nicht gültig')
};

declare function ab-formula:is-wellformed($formula as xs:string) as xs:boolean {
	matches($formula, "^([0-9\(]([0-9]|[,\+\-\*/\(\)])*[0-9\)])|[0-9]$")
	and
	ab-formula:count-brackets($formula, 1, 0) = 0
};

declare function ab-formula:count-brackets($formula as xs:string, $offset as xs:integer, $open-brackets as xs:integer) as xs:integer {
	let $character := substring($formula, $offset, 1)
	return 
		if ($character = '') then $open-brackets
		else if ($character = '(') then ab-formula:count-brackets($formula, $offset + 1, $open-brackets + 1)
		else if ($character = ')') then ab-formula:count-brackets($formula, $offset + 1, $open-brackets - 1)
		else ab-formula:count-brackets($formula, $offset + 1, $open-brackets)
};

declare function ab-formula:tokenize($formula as xs:string, $offset as xs:integer) as xs:string* {
	let $character := substring($formula, $offset, 1)
	let $previous-character := substring($formula, $offset - 1, 1)
	where $character != ''
	return
		if ($character = '-' and not(ab-formula:is-part-of-digit($previous-character)))
		then
			let $digit := concat('-', ab-formula:extract-digit-from-string($formula, $offset + 1))
			return ($digit, ab-formula:tokenize($formula, $offset+string-length($digit)))
		else if (ab-formula:is-part-of-digit($character))
		then
			let $digit := ab-formula:extract-digit-from-string($formula, $offset)
			return ($digit, ab-formula:tokenize($formula, $offset+string-length($digit)))
		else
			($character, ab-formula:tokenize($formula, $offset+1))
};

declare function ab-formula:extract-digit-from-string($string as xs:string, $offset as xs:integer) as xs:string? {
	let $character := substring($string, $offset, 1)
	where ab-formula:is-part-of-digit($character)
	return concat($character, ab-formula:extract-digit-from-string($string, $offset+1))
};

declare function ab-formula:calculate($tokens as xs:string*, $opening-bracket-indeces as xs:integer*, $cursor as xs:integer) as xs:double {
	if($tokens[$cursor] = '(')
	then ab-formula:calculate($tokens, ($cursor, $opening-bracket-indeces), $cursor+1)
	else if($tokens[$cursor] = ')')
	then ab-formula:calculate((subsequence($tokens, 1, $opening-bracket-indeces[1] - 1),
				ab-formula:evaluate-term(subsequence($tokens, $opening-bracket-indeces[1] + 1, $cursor - $opening-bracket-indeces[1] - 1)),
				subsequence($tokens, $cursor + 1)), subsequence($opening-bracket-indeces, 2) , $opening-bracket-indeces[1] + 1)
	else if($tokens[$cursor] != '')
	then ab-formula:calculate($tokens, $opening-bracket-indeces, $cursor+1)
	else xs:double($tokens[1])
};

declare function ab-formula:evaluate-term($tokens as xs:string*) as xs:string {
	let $count := count($tokens)
	return
		if ($count = 0)
		then xs:string(0)
		else if ($count = 1)
		then xs:string($tokens[1])
		else
			let $next-mult := index-of($tokens, '*')
			let $next-div := index-of($tokens, '/')
			let $next-add := index-of($tokens, '+')
			return
				if (count($next-mult) > 0)
				then ab-formula:evaluate-term((subsequence($tokens, 1, $next-mult[1]-2), xs:string(xs:double($tokens[$next-mult[1]-1]) * xs:double($tokens[$next-mult[1]+1])), subsequence($tokens, $next-mult[1]+2)))
				else if (count($next-div) > 0)
				then ab-formula:evaluate-term/((subsequence($tokens, 1, $next-div[1]-2), xs:string(xs:double($tokens[$next-div[1]-1]) div xs:double($tokens[$next-div[1]+1])), subsequence($tokens, $next-div[1]+2)))
				else if (count($next-add) > 0)
				then ab-formula:evaluate-term((subsequence($tokens, 1, $next-add[1]-2), xs:string(xs:double($tokens[$next-add[1]-1]) + xs:double($tokens[$next-add[1]+1])), subsequence($tokens, $next-add[1]+2)))
				else ab-formula:evaluate-term((xs:string(xs:double($tokens[1]) - xs:double($tokens[3])), subsequence($tokens, 4)))

};

declare function ab-formula:is-part-of-digit($character as xs:string?) as xs:boolean {
	matches($character, "^[0-9]$") or $character = "."
};
