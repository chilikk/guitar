function toggle_chords() {
	var object = $('#chords');
	var trigger = $('#showchordsbtn');
	var link = $('#openchords');
	if (link.val()=="0") {
		link.val("1");
		object.show(400);
		trigger.addClass('active');
	}
	else {
		link.val("0");
		object.hide(400);
		trigger.removeClass('active');
	}
}

function load_song(urlGetQuery) {
	var current = $('#activesong');
	$.get("/song.yaws"+urlGetQuery, 
		function(msg) {
			$('#content').html(msg);
			if ($('#chords')[0]) {
				$('#showchordsbtn').show(0);
				if ($('#openchords').val()=="1")
					$("#chords").show(0);
			}
			else
				$('#showchordsbtn').hide(0);
			jtab.renderimplicit();
			current.val($('#content').find('h3').html());
			$('#list').find('a:contains("'+current.val()+'")').addClass('active');
		}
	);
	if (current.val()!='') {
		$('#list').find('a:contains("'+current.val()+'")').removeClass('active');
		current.val('');
	}
	$('#content').html("<center><h2>Loading...</h2></center>");
}
