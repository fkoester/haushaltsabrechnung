$(document).ready(function() {


	function calculateArithmeticExpression (event) {

		var inputElement = this
		var resultElement = $(this).nextAll(".arithmetic-result:first");

		try {
			var result = Parser.evaluate(inputElement.value.replace(/,/g, "."), {}).toString();
			result = new String(Math.round(result * 100) / 100);
			result = result.replace(/\./g, ",");
			resultElement.text(result == undefined ? "" : "= "+result);

		} catch(exception) {

			resultElement.text("");
		}
	}
	
	$("input.arithmetic").live('keyup', calculateArithmeticExpression );
});

