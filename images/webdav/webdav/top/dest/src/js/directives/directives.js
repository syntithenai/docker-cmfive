(function(angular) {
    'use strict';
    var app = angular.module('FileManagerApp');

    app.directive('angularFilemanager', ['$parse', 'fileManagerConfig','fileNavigator','apiMiddleware', function($parse, fileManagerConfig, fileNavigator, apiMiddleware) {
		var that=this;
		return {
			restrict: 'EA',
            templateUrl: fileManagerConfig.tplPath + '/main.html',
            link: function(scope, element, attrs, ngModel) {
				var controllerScope=angular.element(element[0].children[0]).scope();
				//console.log(['link',scope, element[0].children[0], angular.element(element[0].children[0]).scope(), attrs, ngModel,fileNavigator.currentPath,apiMiddleware]);
				//scope.uploadFiles();
				//console.log(scope.selectedPath);
				//console.log(['link2',scope, element, attrs, ngModel,fileNavigator.currentPath,apiMiddleware]);
				var uppie = new Uppie();
				uppie(element[0], function (event, files, folders) { 
					console.log(['uppie',event,files,folders]);
					controllerScope.dropFiles(files,folders);
					console.log(['uppie',event,files,folders]);
					
				//	console.log(['scope',$scope]);
					/*
					 // THIS WORKS
					 * for (var i = 0, f; f = files[i]; i++) {
						if (f.file) { 
							var reader = new FileReader();
							reader.readAsArrayBuffer(f.file);
							reader.onload = (function(theFile) {
								return function(e) {
									var newFile = { name : theFile.name,
										type : theFile.type,
										size : theFile.size,
										lastModifiedDate : theFile.lastModifiedDate
									}

									console.log(['NEWFILE',newFile,e.target.result]);
								};
							})(f.file);
						}
					}*/
					//alert('aa');
				});
			},
	//		controller: function() {
	//			alert('d');
	//		}
        };
    }]);

    app.directive('ngFile', ['$parse', function($parse) {
        return {
            restrict: 'A',
            link: function(scope, element, attrs) {
                var model = $parse(attrs.ngFile);
                var modelSetter = model.assign;

                element.bind('change', function() {
                    scope.$apply(function() {
                        modelSetter(scope, element[0].files);
                    });
                });
            }
        };
    }]);

    app.directive('ngRightClick', ['$parse', function($parse) {
        return function(scope, element, attrs) {
            var fn = $parse(attrs.ngRightClick);
            element.bind('contextmenu', function(event) {
                scope.$apply(function() {
                    event.preventDefault();
                    fn(scope, {$event: event});
                });
            });
        };
    }]);
    
})(angular);
