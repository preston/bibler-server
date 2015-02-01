angular.module('BiblerApp').controller('SearchController', ['$scope', '$location', 'growl', 'Restangular', function($scope, $location, growl, Restangular) {

	Restangular.all('bibles').getList().then(function(bibles) {
		$scope.bibles = bibles;
		$scope.selectedBible = bibles[0].slug;
		console.log("Loaded " + bibles.length + " bibles.");
	});

	$scope.search = function() {
		var bible = $scope.selectedBible;
		var text = $scope.search.text;
		if($scope.validSearch()) {
			Restangular.all(bible + '/search').post({'text' : $scope.search.text}).then(function(verses) {
				$scope.verses = verses;
			});

		} else {
			$scope.verses = [];
		}
	}

	$scope.validSearch = function() {
		return $scope.selectedBible != null && $scope.search.text != null && $scope.search.text.length >= 3
	}

	console.log("SearchController has been initialized.");

}]);