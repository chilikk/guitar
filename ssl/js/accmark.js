function unique(list) {
  var result = [];
  $.each(list, function(i, e) {
    if ($.inArray(e, result) == -1) result.push(e);
  });
  return result;
}

acc = "[A-H][#b]?(?:m|6|m6|69|7|m7|maj7|7b5|7#5|m7b5|7b9|9|m9|maj9|add9|13|sus2|sus4|dim|dim7|aug)?";
accpatn = new RegExp(acc,"g");
accline = new RegExp("^(?:<.*>|[ |])*(?:"+acc+"[ /|]*)+$","mg");

function getChords(text) {
	return "<div class='jtab chordonly'>"+unique(text.match(accline).join(";").match(accpatn)).join(" ")+"</div>";
}
