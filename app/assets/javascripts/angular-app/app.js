app = angular.module('BiblerApp', [
	'templates',
	'restangular',
	'ngRoute',
	'relativeDate',
	'humanizeFilters',
	'angular-growl',
	// 'ui.utils',
	'ngAnimate',
]);

// For compatibility with Rails CSRF protection

app.config(
	['$httpProvider', 'RestangularProvider', function($httpProvider, RestangularProvider) {
		$httpProvider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
		RestangularProvider.setRequestSuffix('.json');
		// RestangularProvider.setRestangularFields({
		// 	id: "slug"
		// });
	}]);

app.config(['growlProvider', function(growlProvider) {
    growlProvider.globalTimeToLive(2000);
}]);


app.run(function() {
	console.log('Bibler is up and running!');
});
