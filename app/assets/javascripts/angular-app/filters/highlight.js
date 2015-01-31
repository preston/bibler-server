app.filter('highlight', function($sce) {
  return function(str, terms) {
    if(terms == null) {
      return $sce.trustAsHtml(str);
    }
  	var termsToHighlight = terms.split(/\s+/);
    // Sort terms by length
    termsToHighlight.sort(function(a, b) {
      return b.length - a.length;
    });
    // Regex to simultaneously replace terms
    var regex = new RegExp('(' + termsToHighlight.join('|') + ')', 'gi');
    return $sce.trustAsHtml(str.replace(regex, '<span class="highlight">$&</span>'));
  };
});
