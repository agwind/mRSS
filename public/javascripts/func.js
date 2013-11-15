$( "#read" ).on( "change",  function(event) {
	var toggle_read = $("#lbl-read span").text() == "Read" ? 0 : 1;
	$.getJSON('/article/' + $("#read").val() + '/read/' + toggle_read, function(data) {
		if(data.error) {
			//alert("Error!");
		} else { 
			if($("#lbl-read span").text() == "Read") {
				$("#lbl-read span").text("New");
			} else {
				$("#lbl-read span").text("Read");
			}
		}
	});
});

$( "#favorite" ).on( "change",  function(event) {
	var toggle_fav = $("#lbl-fav i").hasClass('fa-star-o') ? 1 : 0;
	$.getJSON('/article/' + $("#read").val() + '/favorite/' + toggle_fav, function(data) {
		if(data.error) {
			//alert("Error!");
		} else { 
			if($("#lbl-fav i").hasClass('fa-star-o')) {
				$("#lbl-fav i").removeClass('fa-star-o').addClass('fa-star');
			} else {
				$("#lbl-fav i").removeClass('fa-star').addClass('fa-star-o');
			}
		}
	});
});

$( ".feed-refresh" ).on( "click", function(event) {
	var sub_id = this.id;
	$( "#icon-" + sub_id ).addClass('fa-spin');
	$.getJSON('/subs/' + sub_id + '/refresh', function(data) {
		$( "#icon-" + sub_id ).removeClass('fa-spin');
		$( "#unread-" + sub_id ).text(data.unread);
		$(	"#count-" + sub_id ).text(data.count);
		$( "#" + sub_id ).after("<span id=\"new-not-" + sub_id + "\" class=\"label label-success\">" + data.new + "</span>");
		$( "#new-not-" + sub_id ).delay(5000).fadeOut(600);
	});
});

