$(document).ready(function() {
	var elem = document.createElement('input');  
	elem.setAttribute('type', 'date');  
	if ( elem.type === 'text' ) {  
		$("input.date").datepicker({ dateFormat: 'yy-mm-dd' });
	}
});

