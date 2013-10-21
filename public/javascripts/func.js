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
	var toggle_fav = $("#lbl-fav i").hasClass('icon-star-empty') ? 1 : 0;
	$.getJSON('/article/' + $("#read").val() + '/favorite/' + toggle_fav, function(data) {
		if(data.error) {
			//alert("Error!");
		} else { 
			if($("#lbl-fav i").hasClass('icon-star-empty')) {
				$("#lbl-fav i").removeClass('icon-star-empty').addClass('icon-star');
			} else {
				$("#lbl-fav i").removeClass('icon-star').addClass('icon-star-empty');
			}
		}
	});
});

$( ".feed" ).on( "click", function(event) {
	var sub_id = this.id;
	$( "#icon-" + sub_id ).addClass('icon-spin');
	$.getJSON('/subs/' + sub_id + '/refresh', function(data) {
		$( "#icon-" + sub_id ).removeClass('icon-spin');
		$( "#unread-" + sub_id ).text(data.unread);
		$(	"#count-" + sub_id ).text(data.count);
		$( "#" + sub_id ).after("<span id=\"new-not-" + sub_id + "\" class=\"label label-success\">" + data.new + "</span>");
		$( "#new-not-" + sub_id ).delay(5000).fadeOut(600);
	});
});

