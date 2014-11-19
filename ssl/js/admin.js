function edit_song(urlGetQuery) {
	$.get("edit.yaws"+urlGetQuery,
	function(msg) {
		$('#content').html(msg);
                textarea = $('#edittext');
                textarea.height(1);
                textarea.height(textarea[0].scrollHeight+4);
	}
	);
	$('#content').html("<center><h2>Loading...</h2></center>");
}

function new_song() {
	$.get("edit.yaws",
		function(msg) {
			$('#content').html(msg);
			textarea = $('#edittext');
			textarea.height(1);
			textarea.height(textarea[0].scrollHeight+4);
		}
	);
}

function save_song() {
	$.post("operation.yaws", 
		{ 	
			op : 'save',
			a : $('#editauthor').text(),
			t : $('#edittitle').text(),
			x : $('#edittext').val()
		},
		function(msg) {
			$('#opresult').html(msg);
		}
	);
}

function delete_song() {
	if (confirm("Are you sure you want to delete '"+$('#editauthor').html()+" :: "+$('#edittitle').html()+"'?")) {
		$.post("operation.yaws",
			{
				op: 'delete',
				a : $('#editauthor').text(),
				t : $('#edittitle').text()
			},
			function(msg) {
				$('#opresult').html(msg);
			}
		);
	}
}
