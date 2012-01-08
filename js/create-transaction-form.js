$(document).ready(function() {
	
	function addSubtransaction() {

		var groupId = $("#group-selection option:selected").val();

		$.get('get_environment.xql?current-group-id='+groupId, function(data) {
			var env = (new XMLSerializer()).serializeToString(data);
			var lastIndex = $(".sub-transaction-form").length;
			xml = "<parameters><sub-transaction-index>" + lastIndex +"</sub-transaction-index><transaction-entry><debtors /></transaction-entry>" + env + "</parameters>";
			var subTransElem = $.transform({async:false,xmlstr: xml, xsl:"stylesheets/transaction-common.xsl"});
			$("#sub-transactions-fieldset > div:last").after(subTransElem);
		});
	}

	$('#sub-transactions-input-yes').click(function() {

		if ($("#sub-transactions-input-yes:checked").val() == "yes") {
			$('#sub-transactions-fieldset').show(400);

			if( $('.sub-transaction-form').size() == 0)
				addSubtransaction();
		}
	});

	$('#sub-transactions-input-no').click(function() {

		if ($("#sub-transactions-input-no:checked").val() == "no") {
			$('#sub-transactions-fieldset').hide(400);

			$('.sub-transaction-form').remove();
		} 
	});

	$('#occurrences-input-multi').click(function() {

		if ($("#occurrences-input-multi:checked").val() == "multi") {
			$('#standing-order-fieldset').show(400);
			$('#start-date-input').prop('required', 'required')
			$('#booking-date-input').prop('required', '')
			$('#booking-date-field').hide(400);
		}
	});

	$('#occurrences-input-once').click(function() {

		if ($("#occurrences-input-once:checked").val() == "once") {
			$('#standing-order-fieldset').hide(400);
			$('#start-date-input').prop('required', '')
			$('#booking-date-input').prop('required', 'required')
			$('#booking-date-field').show(400);
		}
	});

	$('#recurrence-weekly-radio').click(function() {

		if ($("#recurrence-weekly-radio:checked").val() == "weekly") {
			$('#recurrence-weekly-details').show(400);
			$('#recurrence-monthly-details').hide(400);
			$('#recurrence-yearly-details').hide(400);

			$('#week-interval-input').prop('required', 'required')
                        $('#month-interval-field').prop('required', '')
                        $('#day-of-month-field').prop('required', '')
                        $('#weekday-number-field').prop('required', '')
		}
	});

	$('#recurrence-monthly-radio').click(function() {

		if ($("#recurrence-monthly-radio:checked").val() == "monthly") {
			$('#recurrence-weekly-details').hide(400);
			$('#recurrence-monthly-details').show(400);
			$('#recurrence-yearly-details').hide(400);
		}
	});

	$('#recurrence-yearly-radio').click(function() {

		if ($("#recurrence-yearly-radio:checked").val() == "yearly") {
			$('#recurrence-weekly-details').hide(400);
			$('#recurrence-monthly-details').hide(400);
			$('#recurrence-yearly-details').show(400);
		}
	});

	$('#add-sub-transaction-button').click(function(ev) {

		addSubtransaction();
		ev.preventDefault();
	});

	$('#remove-sub-transaction-button').click(function(ev) {

		if( $('.sub-transaction-form').size() == 1) {
			$('#sub-transactions-fieldset').hide(400);
			$('#sub-transactions-input-no').prop('checked', true);
			$('#sub-transactions-input-yes').prop('checked', false);
		}
		
		$('.sub-transaction-form:last').remove();
		
		ev.preventDefault();
	});

	$('#recurrence-weekly-details').hide();
	$('#recurrence-yearly-details').hide();

	if($(".sub-transaction-form").length == 0)
		$('#sub-transactions-fieldset').hide();

	$('#standing-order-fieldset').hide();

	$('#booking-date-input').prop('required', 'required')
});

