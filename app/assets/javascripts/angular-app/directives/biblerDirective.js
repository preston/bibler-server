angular.module('BiblerApp').directive('biblerVerse', function() {
	return {
		restrict: 'E',
		// require: ['^bible', '^book', '^chapter', '^verse'],
		template: '<div class="bibler verse"><h3 class="text-uppercase ordinal">{{book.name}} {{verse.chapter}} : {{verse.ordinal}}</h3><i class="bible name" ng-bind="bible.name"/><p class="verse text" ng-bind="verse.text"/></div>',
		scope: {
			bible: '@',
			book: '@',
			chapter: '@',
			verse: '@'
		},
		controller: ['$scope', '$http', 'Restangular', function($scope, $http, Restangular) {
			$scope.loadVerse = function(bible, book, chapter, verse) {
				var path = '/' + bible + '/' + book + '/' + chapter;
				Restangular.one(path, verse).get().then(function(v) {
					$scope.verse = v;
				});
				Restangular.one('books', book).get().then(function(b) {
					$scope.book = b;
				});
				Restangular.one('bibles', bible).get().then(function(b) {
					$scope.bible = b;
				});
				// $scope.
			}
		}],
		link: function(scope, iElement, iAttrs, ctrl) {
			scope.verse = scope.loadVerse(iAttrs.bible, iAttrs.book, iAttrs.chapter, iAttrs.verse);
		}
	}
});