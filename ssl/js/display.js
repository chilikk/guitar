function check_text_empty() {
	if ($.trim($('#text').text())=="") {
		$('#text').width('0px');
		$('#text').hide(0);
		$('#leftwrapper').width('780px');
		$('#list').width('774px');
		$('#listwrapper').addClass('multicolumn');
	}
}

function check_text_open() {
	if ($('#text').width()==0)
		show_text();
}

function equalize_height() {
	size = window.innerHeight - 10;
	$('#list').height(size - ($('#footer').outerHeight(true)));
	$('#text').height(size);
}
function toggle_chords() {
	object = $('#chords');
	trigger = $('#showchordsbtn');
	link = $('#openchords');
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
	$.get("/song.yaws"+urlGetQuery, 
		function(msg) {
			//check_text_open();
			$('#content').html(msg);
			if ($('#chords')[0]) {
				$('#showchordsbtn').show(0);
				if ($('#openchords').val()=="1")
					$("#chords").show(0);
			}
			else
				$('#showchordsbtn').hide(0);
			jtab.renderimplicit();
		}
	);
	$('#content').html("<center><h2>Loading...</h2></center>");
}

function show_text() {
	$('#text').show(0);
	$('#text').animate({width:'534px'},{duration: 450, queue: false}); 
	$('#leftwrapper').animate({width:'240px'}, {queue: false}); 
	$('#list').animate({width: '224px'}, {complete: function() {$('#listwrapper').removeClass('multicolumn'); }});

}
function hide_text() {
	$('#leftwrapper').animate({width:'780px'}, {duration: 450, queue: false}); 
	$('#list').animate({width: '774px'},{ duration: 450, queue: false, complete: function() { $('#listwrapper').addClass('multicolumn'); } });
	$('#text').animate({width:'0px'},{complete:function(){$('#text').hide(0)}});
	
}
