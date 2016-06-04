(function(angular) {
    'use strict';
    angular.module('FileManagerApp').service('apiMiddleware', ['$window', 'fileManagerConfig', 'apiHandler','$q', '$timeout','item',
        function ($window, fileManagerConfig, ApiHandler, $q, $timeout,Item) {

		var jio = null;

/*		
		 type: "query",  // queryable using allDocs(options)
         sub_storage: {
           type: "uuid",  // auto ids
           sub_storage: {
             type: "document",
             document_id: "/",
             sub_storage: {
               type: "zip",
               sub_storage: {
                 type: "local"
*/


        var getStorageConfig = function(config,path) {
			return fileManagerConfig.storageold;
			
			//angular.forEach(config,function (value,key) {
				//if (path.indexOf('/'+key)==0) {
					//console.log(['found',key,config[key]]);
				//}
				////console.log(['A',config,path,path.indexOf('/'.key),key]);
			//});
		}


		// CONSTRUCTOR
		var ApiMiddleware = function() {
			//console.log(['seek browserfs in storage']);
			//getStorageConfig(fileManagerConfig.storage,'/browserfs');
			
			jio = jIO.createJIO(getStorageConfig());
			this.apiHandler = new Object();
        };
        
        
        
		// UTIL
		
		// error handler
		function  errHandler(e) {
			console.log(['err',e]);
		}
		
		// remove blanks from path array
		ApiMiddleware.prototype.cleanPath = function(arrayPath) {
			var newArrayPath=[];
			angular.forEach(arrayPath,function(entry) {
				if (entry && entry.length) {
					newArrayPath.push(entry);
				}
			});
			return newArrayPath;
		}
		// get the path as a string
		ApiMiddleware.prototype.getPath = function(arrayPath) {
			arrayPath=this.cleanPath(arrayPath);
			var path= '/' +arrayPath.join('/');
            return path;
            
        };
        // get the path and name as a full path to the file/dir
        ApiMiddleware.prototype.getFullPath = function(arrayPath,name) {
			arrayPath=this.cleanPath(arrayPath);
			arrayPath.push(name);
			var path= '/' +arrayPath.join('/');
            return path;
            
        };
        // filter array of files for empties
        ApiMiddleware.prototype.getFileList = function(files) {
            return (files || []).map(function(file) {
                if (file && file.model && file.model.fullPath) {
					return file.model.fullPath();
				} else {
					return file;
				}
            });
        };
		// extract the full path from an item
        ApiMiddleware.prototype.getFilePath = function(item) {
            return item && item.model.fullPath();
        };
        
        ApiMiddleware.prototype.explodePath = function(pathString) {
			return pathString && pathString.split("/").slice(0,-1);
		}
        
        ApiMiddleware.prototype.explodeName = function(pathString) {
			return pathString && pathString.split("/").slice(-1)[0];
		}
		// check if path is a directory (or file)
		// assume directories always end in slash (/)
		ApiMiddleware.prototype.isFolder = function(pathString) {
			if (pathString.slice(-1)=="/")  {
				return true;
			} else {
				return false
			}
		}
		// ensire directory path string always end in slash (/)
		ApiMiddleware.prototype.ensureTrailingSlash = function(mystr) {
			mystr=mystr.trim();
			if (mystr.slice(-1)=="/")  {
				return mystr;
			} else {
				return mystr+"/";
			}
		}
        
		// EXTERNAL ACTIONS
		// GETTERS 
		/** 
		 * Create a record with id matching folder name 
		 */
        ApiMiddleware.prototype.createFolder = function(item) {
			var that=this;
			//console.log(['create folder',item]);
			var data={};
			var pathParts=this.cleanPath(item.model.path.split("/")).slice(0,-1);
			item.tempModel.path=pathParts;
			//console.log(['reset path',item.model.path,item.tempModel.path]);
			// If we can store properties in this storage, store the path and other meta.
			try {
				jio.hasCapacity('properties');
				data={name : item.tempModel.name,path: item.tempModel.path,size:0,type:'dir'};
				data.pathJoined=this.getPath(data.path);
			} catch (e) { 
				// no properties	
			}
			//console.log(['create folder mapped',data]);
			var deferred = $q.defer();
			jio.put(that.ensureTrailingSlash(item.tempModel.fullPath()),data).then(function() {
				//console.log(['created folder DONE']);
				deferred.resolve();
			},that.errHandler);
			return deferred.promise;
		};
        
        
        ApiMiddleware.prototype.upload = function(fileList, path, folderList=null) {
			var that=this;
			var promises=[];
			console.log(['UPLOAD ',fileList,path,folderList]);
			
			 // ensure all folders are created
			if (folderList) {
				for (var i = 0; i < folderList.length; i++) {
					console.log(['CREATE FOLDER',folderList[i]]);
					//promises.push(
					//jio.put(folderList[i]);
					//);
				}
			}
			console.log(['CREATED FOLDERS']);
			// then handle files
			$q.all(promises).then(function() {
				angular.forEach(fileList,function(f) {
					var deferred = $q.defer();
					// upload input (compared to DND)
					console.log(['file',f,f]);
					if (f instanceof File) {
						f={fullPath: '/', file: f};
					}
					if (f) {
						//f.fullPath=fileList[i].fullPath;
						var reader = new FileReader();
						// Closure to capture the file information.
						var filePath=path;
						if (f.fullPath) {
							var uploadPathParts=f.fullPath.split('/');
							uploadPathParts=uploadPathParts.slice(0,uploadPathParts.length-1);
							filePath=that.cleanPath(path.concat(uploadPathParts));
						}
						console.log(['FILEPATH',path,filePath]);
							
						reader.onload = (function(theFile,filePath) {
							console.log(['ONLOAD',path,filePath]);
							return function(e) {
								console.log(['ONLOADED',theFile,filePath,e]);
								
								//var data={name : theFile.name,path:filePath,pathJoined:that.getPath(filePath),size:theFile.size,type:'file'};
								//data.pathJoined="(data.path);
								console.log(['upload file ',theFile,e.target]);
								//var recordId=that.getFullPath(that.cleanPath(path.concat(uploadPathParts)),data.name);
								//console.log(['recordId ',recordId]);
								// ensure folder 
								//jio.put(that.getPath(filePath),{}).then(function() {
								//	console.log(['put folder ',that.getPath(filePath)]);
									var blob=new Blob([e.target.result]);
									console.log(['blob',that.getPath(filePath),that.getFullPath(filePath,theFile.name),blob]);
									var pathString=that.getPath(filePath);
									if (pathString.length>1) pathString+= "/";
									function saveAttachment(pathString,theFile,blob) {
										jio.putAttachment(that.ensureTrailingSlash(pathString),theFile.name,blob).then(function(res) {
											console.log(['blob saved',res]);
											deferred.resolve(recordId);
										},that.errHandler);
									}
									
									jio.put(pathString,{}).then(function() {
										console.log(['blob folder saved']);
										saveAttachment(that.ensureTrailingSlash(pathString),theFile,blob);
									},function() {
										console.log(['blob folder NOT saved']);
										saveAttachment(that.ensureTrailingSlash(pathString),theFile,blob);
									},that.errHandler);
										
									
								// })
							};
						})(f.file,filePath);

						// Read in the image file as a data URL.
						reader.readAsArrayBuffer(f.file,filePath);
						promises.push(deferred);  
					}
				});
			});
			// read and save all files
			
			return $q.all(promises);
            //return this.apiHandler.upload(fileManagerConfig.uploadUrl, form);
        };

		
		// GETTERS
		ApiMiddleware.prototype.getUrl = function(fullPath) {
			var that=this;
			console.log(['getURL',fullPath]);
			return;
			var deferred=$q.defer();
			jio.get(that.ensureTrailingSlash(fullPath)).then(function(item) {
				//console.log(['loaded item ',item,'item',fullPath]);
				jio.getAttachment(that.ensureTrailingSlash(fullPath),'attachment').then(function(f) {
					//console.log(['loaded attachment ',f]);
					var reader = new FileReader();
					// Closure to capture the file information.
					reader.onload = (function(theFile) {
						//console.log(['loaded attachmenti ',theFile]);
						return function(e) {
							deferred.resolve(e.target.result);
						};
					})(f);
					// Read in the image file as a data URL.
					reader.readAsDataURL(f);
				},that.errHandler);
				//console.log(['after loaded item ',item,'item',fullPath]);
			},that.errHandler);
			return deferred.promise;
            //var itemPath = this.getFilePath(item);
            //return this.apiHandler.getUrl(fileManagerConfig.downloadFileUrl, itemPath);
        };



		ApiMiddleware.prototype.list = function(path, customDeferredHandler) {
			console.log(['da list',path,this.getPath(path)]);
			var that=this;
			var promises=[];
			var masterDeferred=$q.defer();
			var pathString=this.getPath(path);
			//pathString="/";
			//if (pathString.length > 1 ) pathString += "/";
			// LOAD RECORD AND CHILD FOLDERS
			jio.get(that.ensureTrailingSlash(pathString)).then(
				function(results) {
					console.log(['got path ',pathString,results]);
					// sub storage supports loading children on get()
					if (results.hasOwnProperty('children')) {
						console.log(['have kids ',results.children]);
						angular.forEach(results.children,function(child,key) {
							//console.log(['load child item ',key,child,that.getFullPath(path,key)]);
						//	promises.push($q.defer().resolve(child).promise);
							var ideferred = $q.defer();
							// map child to filesystem item
							try {
								var item=new Item ({name: child.name, size: child.size, jsdate: new Date(child.date),type:child.type},child.id);
								console.log(['created child item ',item]);
								ideferred.resolve(item.model);
							} catch (e) {
								console.log(['EEK',e]);
							}
							//{name : item.name,path: item.path,size:0,type:'dir'};
							//jio.get(that.getFullPath(path,key)).then(function(item) {
							//	console.log(['loaded child item ',item]);
								
							//});
							promises.push(ideferred.promise);
						});
						
					// otherwise try search for children
					} else {
						//console.log(['NO kids ']);
						if (jio.hasCapacity('list')) {
							var options = {};
							options.query = '(pathJoined:"'+this.getPath(path)+'")';
							jio.allDocs(options)
							.then(function(results) {
								angular.forEach(results.data.rows,function(result) {
							//		console.log(['result',result]);
									var ideferred = $q.defer();
									jio.get(result.id).then(function(item) {
								//		console.log(['loaded item ',item]);
										ideferred.resolve(item);
									});
									promises.push(ideferred.promise);
								});
							},that.errHandler);
						// OR FAIL
						} else {
							throw new Exception('Unable to load children from storage');
						}
					}
							
							
					// NOW FILES
					//console.log(['getallattach',pathString]);
					//jio.getAllAttachments(pathString).then(function(attachments) {
						//console.log(['gotallattach',pathString,attachments]);
						//angular.forEach(attachments,function(child) {
							//var ideferred = $q.defer();
							//// map child to filesystem item
							//try {
								//var item=new Item ({name: child.name, size: child.size, jsdate: new Date(child.date),type:'file'},child.id);
								//console.log(['item',item]);
								//ideferred.resolve(item);
							//} catch (e) {
								//console.log(['EEK',e]);
								//ideferred.resolve(item);
							//}
							//ideferred.resolve(item);
							//promises.push(ideferred.promise);
						//});
					//});		
										
					$q.all(promises).then(function(combined) {
							//customDeferredHandler(combined,masterDeferred);
							masterDeferred.resolve({'result': combined});
							//console.log(['all done ',combined]);
					});
			
					//masterDeferred.resolve({'result': results.data.rows});
				},that.errHandler
			);

			return masterDeferred.promise;
        };


		ApiMiddleware.prototype.copyFolderRecursive = function(src,destination) {
			var masterDeferred=$q.defer();
			var promises=[];
			var that=this;
			console.log(['CR start',src,destination]);
			jio.put(that.ensureTrailingSlash(destination),{}).then(function() {
				console.log(['CR put',src]);
				jio.get(that.ensureTrailingSlash(src)).then(function(content) {
					console.log(['CR got children',content,content.children]);
					angular.forEach(content.children,function(child) {
						var deferred=$q.defer();
						promises.push(deferred);
						console.log(['CR child',child]);
						if (that.isFolder(child.id)) {
							// call recursive
							console.log(['CR folder',child.id,destination + child.name + "/"]);
							promises.push(that.copyFolderRecursive(child.id,destination + child.name + "/"));
							//deferred.resolve//
						} else {
							// copy attachment
							console.log(['CR attach',child.id,destination]);
							promises.push(that.copyAttachment(child.id,destination));
							//deferred
						}
					});
				},that.errHandler);
			},that.errHandler);
			//deferred.resolve();
			$q.all(promises).then(function(combined) {
				masterDeferred.resolve(combined);
			});
			
			return masterDeferred.promise;
		}
		
		ApiMiddleware.prototype.copyAttachment = function(source,destination) {
			var that=this;
			var deferred=$q.defer();
			console.log(['CR copy attachment',that.ensureTrailingSlash(that.getPath(that.explodePath(source))),that.explodeName(source),source,destination,that.getPath(that.explodePath(source)),that.explodeName(source)]);
			jio.getAttachment(that.ensureTrailingSlash(that.getPath(that.explodePath(source))),that.explodeName(source)).then(function(blob) {
				console.log(['CR got attachment now put to destination',that.ensureTrailingSlash(destination),that.explodeName(source),blob]);
				jio.putAttachment(that.ensureTrailingSlash(destination),that.explodeName(source),blob).then(function() {
					console.log(['CR saved']);
					deferred.resolve(['copied',source,'to',destination]);
				},that.errHandler);
			},that.errHandler);
			return deferred.promise;
		}

		/**
		 * Copy records and attachments to a new path.
		 * @param files [Item] - array of Items to copy.
		 * @param path [] - array of path segments
		 */
        ApiMiddleware.prototype.copy = function(items, path) {
			path=this.cleanPath(path); 
			var masterDeferred=$q.defer();
			var that=this;
			var promises=[];
			console.log(['copy items',items,path,this.getPath(path)]);
			
			angular.forEach(items,function(item) {
				console.log(['copy item',item]);
				var deferred = $q.defer();
				if (item.model.type=="dir") {
					console.log(['FOLDER',item.model.fullPath()]);
					promises.push(that.copyFolderRecursive(item.model.fullPath(),that.getPath(path) + "/" + item.model.name + "/"));
				} else {
					console.log(['FILE',that.getFullPath(item.model.path,item.model.name),that.getPath(path)]);
					promises.push(that.copyAttachment(that.getFullPath(item.model.path,item.model.name),that.getPath(path)));
				}
			});
			$q.all(promises).then(function(combined) {
				masterDeferred.resolve(combined);
			});
			
			return masterDeferred.promise;
        
        };

		ApiMiddleware.prototype.move = function(files, path) {
			path=this.cleanPath(path);
			var masterDeferred=$q.defer();
			var that=this;
			var promises=[];
			var items = this.getFileList(files);
			console.log(['move items',items,path,this.getPath(path)]);
			jio.put(that.ensureTrailingSlash(that.getPath(path))).then(function() {
				angular.forEach(items,function(item) {
					var deferred = $q.defer();
					promises.push(deferred);
					var itemParts=item.split("/");
					var name = itemParts[itemParts.length-2];
					//var itemPath=that.getPath(that.explodePath(item));
					if (that.isFolder(item))  {
						console.log(['move copy recursive',item,that.ensureTrailingSlash(that.getPath(path)) + name + "/"]);
						promises.push(that.copyFolderRecursive(item,that.ensureTrailingSlash(that.getPath(path)) + name + "/"));
					}	else { 
						console.log(['FILE',item,that.getPath(path)]);
						promises.push(that.copyAttachment(item,that.ensureTrailingSlash(that.getPath(path))));
					}
				});
				$q.all(promises).then(function(combined) {
					console.log(['MOVE all copied now cleanup ',combined]);
					var innerPromises=[];
					angular.forEach(items,function(item) {
						var deferred = $q.defer();
						//innerPromises.push(that.remove([item]));
					});
					$q.all(innerPromises).then(function() {
						masterDeferred.resolve(combined);
					});
					
				});
			});
			
			return masterDeferred.promise;
        };

        ApiMiddleware.prototype.remove = function(files) {
			console.log(['rEMOVE',files]);
			var that=this;	
           var items = this.getFileList(files);
            var promises=[];
            angular.forEach(items,function(item) {
				var deferred = $q.defer();
				console.log(['removeitem',item]);
				jio.remove(item).then(function(data) {
					console.log('removed',data);
					deferred.resolve(data);
				},function() {
					deferred.resolve();
				});
				//deferred.resolve();
				promises.push(deferred.promise);
			});
			// TODO fix this - ignore promises because GET after DELETE causes exception
			return $q.all([]);
        };

		// TODO
        ApiMiddleware.prototype.getContent = function(item) {
			console.log(['GETCONTENT',item]);
			var that=this;
			var deferred = $q.defer();
			jio.getAttachment(that.ensureTrailingSlash(this.getFullPath(item.model.path)),item.model.name).then(function(f) {
				var reader = new FileReader();
				// Closure to capture the file information.
				reader.onload = (function(theFile) {
					console.log(['loaded attachmenti ',theFile]);
					return function(e) {
						console.log(['loaded attachmenti read ',e.target.result]);
						deferred.resolve(e.target);
					};
				})(f);
				// Read in the image file as a data URL.
				reader.readAsText(f);
			},that.errHandler);
			return deferred.promise;
        };

        ApiMiddleware.prototype.rename = function(item) {
			var deferred = $q.defer();
			var that=this;
			try {
				console.log(['REANME',item]);
				
				var that=this;
				jio.get(that.ensureTrailingSlash(this.getFilePath(item))).then(function(content) {
					//console.log(['got itme',content]);
					var oldName=content.name;
					content.name=item.tempModel.name;
					//console.log(['save updated item',content]);
					jio.put(that.ensureTrailingSlash(that.getFullPath(item.model.path,content.name)),content).then(function() {
						//console.log(['cleanup ',that.getFullPath(item.model.path,oldName)]);
						jio.remove(that.ensureTrailingSlash(that.getFullPath(item.model.path,oldName))).then(function() {
							//console.log(['del old item',that.getFullPath(item.model.path,oldName)]);
							//console.log(['type',content.type]);
							// if is dir, update all children
							if (content.type=="dir") {
								//console.log(['have dir',item.model.path]);
								var promises=[];
								var options = {};
								options.query = '(pathJoined:"'+that.getFullPath(item.model.path,oldName)+'%")';
								//console.log(['list',content.path,options]);
								jio.allDocs(options).then(function(results) {
									//console.log(['got all child docs',results]);
									angular.forEach(results.data.rows,function(result) {
										//console.log(['result',result]);
										var ideferred = $q.defer();
										jio.get(that.ensureTrailingSlash(result.id)).then(function(resultitem) {
											//console.log(['loaded item ',resultitem]);
											var base=that.getFullPath(resultitem.path,resultitem.name);
											var search=that.getFullPath(item.model.path,oldName);
											var replace=that.getFullPath(item.model.path,content.name);
											//console.log(['load ',base,search,replace]);
											var newPath=base.replace(
															search,
															replace
														);
											var newPathParts=newPath.split('/').slice(1);
											//console.log('hai');
											var newContainingPathParts=newPathParts.slice(0,newPathParts.length-1);
											//console.log('hai');
											resultitem.path=newContainingPathParts;
											//console.log('hai');
											resultitem.pathJoined=that.getPath(newContainingPathParts);
											//console.log(['now save ',newContainingPathParts,resultitem]);
											jio.put(that.ensureTrailingSlash(newPath),resultitem).then(function() {
												//console.log(['saved new repathed child ',newPath,resultitem]);
												jio.remove(base).then(function() {
													ideferred.resolve(resultitem);
												});
											},that.errHandler);
											
											
										},that.errHandler);
										promises.push(ideferred.promise);
									});
									$q.all(promises).then(function(combined) {
										//console.log(['all done ',combined]);
										deferred.resolve(combined);
									});
									//masterDeferred.resolve({'result': results.data.rows});
								},that.errHandler);
							}
							
						});
						
						
						
						
					},function(e) {
						//console.log(['err',e]);
					});
				});
			} catch (e) {
				console.log(['ERR',e]);
			}
				
			return deferred.promise;

        };
        

        ApiMiddleware.prototype.edit = function(item) {
			//console.log(['EDIT',item]);
			var that=this;
			var deferred = $q.defer();
			jio.putAttachment(that.ensureTrailingSlash(this.getPath(item.model.path)),item.model.name, new Blob([item.tempModel.content])).then(function(blob) {
				//console.log(['EDIT now saved',blob,item.model.name]);
				deferred.resolve();
            },that.errHandler);
            
			
            deferred.resolve();
            return deferred.promise;
        };

		
        ApiMiddleware.prototype.download = function(item, forceNewWindow) {
            //console.log(['DOWNLOD',item,forceNewWindow,this.getPath(item.model.path),item.model.name]);
            var that=this;
            var deferred = $q.defer();
            jio.getAttachment(that.ensureTrailingSlash(this.getPath(item.model.path)),item.model.name).then(function(blob) {
				//console.log(['GTATT now save',blob,item.model.name]);
				saveAs(blob,item.model.name);
				deferred.resolve();
            },that.errHandler);
            return deferred.promise;
        };

		ApiMiddleware.prototype.downloadMultiple = function(files, forceNewWindow) {
			//console.log(['DOWNLOD',item,forceNewWindow,this.getPath(item.model.path),item.model.name]);
			var that=this;
            var deferred = $q.defer();
			var items = this.getFileList(files);
			angular.forEach(items,function(item) {
				jio.getAttachment(that.ensureTrailingSlash(this.getPath(item.model.path)),item.model.name).then(function(blob) {
					//console.log(['GTATT now save',blob,item.model.name]);
					saveAs(blob,item.model.name);
				},that.errHandler);
				deferred.resolve();
			});
			return deferred.promise;
		};

        ApiMiddleware.prototype.changePermissions = function(files, dataItem) {
            var that=this;
            var deferred = $q.defer();
            deferred.resolve();
            return deferred.promise;
            //var items = this.getFileList(files);
            //var code = dataItem.tempModel.perms.toCode();
            //var octal = dataItem.tempModel.perms.toOctal();
            //var recursive = !!dataItem.tempModel.recursive;

            //return this.apiHandler.changePermissions(fileManagerConfig.permissionsUrl, items, code, octal, recursive);
        };
        
// ZIP
		ApiMiddleware.prototype.compress = function(files, compressedFilename, path) {
			//var items = this.getFileList(files);
			//return this.apiHandler.compress(fileManagerConfig.compressUrl, items, compressedFilename, this.getPath(path));
			var that=this;
            var deferred = $q.defer();
			deferred.resolve();
			return deferred.promise;
		};

		ApiMiddleware.prototype.recursePath = function(path,callBack) {
			
		}
        
		ApiMiddleware.prototype.extract = function(item, folderName, path) {
			var that=this;
            var deferred = $q.defer();
			deferred.resolve();
			return deferred.promise;
			//var itemPath = this.getFilePath(item);
			//return this.apiHandler.extract(fileManagerConfig.extractUrl, itemPath, folderName, this.getPath(path));
		};
	
		
        return ApiMiddleware;

    }]);
})(angular);
