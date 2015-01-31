angular.module('BiblerApp').controller('SearchController', ['$scope', '$location', 'growl', 'Restangular', function($scope, $location, growl, Restangular) {

	Restangular.all('bibles').getList().then(function(bibles) {
		$scope.bibles = bibles;
		$scope.selectedBible = bibles[0].slug;
		console.log("Loaded " + bibles.length + " bibles.");
	});

	$scope.search = function() {
		var bible = $scope.selectedBible;
		var text = $scope.search.text;
		if(bible != null && text.length >= 3) {
			Restangular.all(bible + '/search').post({'text' : $scope.search.text}).then(function(verses) {
				$scope.verses = verses;
			});

		} else {
			$scope.verses = [];
		}
	}

	console.log("SearchController has been initialized.");

}]);