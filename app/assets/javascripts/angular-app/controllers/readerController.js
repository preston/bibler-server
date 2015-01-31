angular.module('BiblerApp').controller('ReaderController', ['$scope', '$location', 'growl', 'Restangular', function($scope, $location, growl, Restangular) {

	var port = $location.port();
	var proto = $location.protocol();
	$scope.urlRoot = proto + "://" + $location.host();
	if((proto == 'http' && port == 80) || (proto == 'https' && port == 443)) {
		// We don't need to explicitly set the port.
	} else {
		$scope.urlRoot += ":" + port;
	}

	Restangular.all('bibles').getList().then(function(bibles) {
		$scope.bibles = bibles;
		$scope.selectedBible = bibles[0].slug;
		console.log("Loaded " + bibles.length + " bibles.");
		$scope.updateChapters();
	});

	Restangular.all('books').getList().then(function(books) {
		$scope.books = books;
		$scope.selectedBook = books[0].slug;
		console.log("Loaded " + books.length + " books.");
		$scope.updateChapters();
	});

	Restangular.all('testaments').getList().then(function(testaments) {
		$scope.testaments = testaments;
		console.log("Loaded " + testaments.length + " testaments.");
	});



	$scope.selectBible = function() {
		$scope.updateChapters();
	};

	$scope.selectBook = function() {
		$scope.updateChapters();
	};

	$scope.selectChapter = function() {
		console.log("Fetching verses...");
		var bible = $scope.selectedBible;
		var book = $scope.selectedBook;
		var chapter = $scope.selectedChapter;
		Restangular.all(bible + '/' + book + '/' + chapter).getList().then(function(verses) {
			$scope.verses = verses;
		});
	};

	$scope.updateChapters = function() {
		var bible = $scope.selectedBible;
		var book = $scope.selectedBook;
		if(bible != null && book != null) {
			console.log("Updating chapter list.");
			Restangular.all(bible + '/' + book).getList().then(function(chapters) {
				$scope.chapters = chapters;
				$scope.selectedChapter = chapters[0];
				$scope.selectChapter();
			});
		} else {
			console.log("Bible and book must be selected to update chapter counts.");
		}
	}

	$scope.bibleForSlug = function(slug) {
		return $scope.objectForSlug($scope.bibles, slug);
	};

	$scope.bookForSlug = function(slug) {
		return $scope.objectForSlug($scope.books, slug);
	};

	$scope.objectForSlug = function(array, slug) {
		for(var i = 0; i < array.length; i++) {
			if(array[i].slug == slug) {
				return array[i];
			}
		}
	};

	$scope.verseMailTo = function(verse) {
		return "subject=" + $scope.bookForSlug($scope.selectedBook).name + '%20' + $scope.selectedChapter + ':' + verse.ordinal
		+ '%20-%20' + $scope.bibleForSlug($scope.selectedBible).name
		+ '&body=%22' + verse.text + "%22%0D%0A%0D%0A%0D%0A%0D%0A%20%20%20%20" + $scope.versePermalink(verse, 'html')
		+ '%0D%0A%0D%0A--%0D%0APowered by Bibler.';
	}

	$scope.versePermalink = function(verse, format) {
		return $scope.urlRoot + '/' + $scope.selectedBible + '/' + $scope.selectedBook + '/' + $scope.selectedChapter + '/' + verse.ordinal + '.' + format
	}

	console.log("ReaderController has been initialized.");
}]);