<pic-list class="pic-list mdl-cell mdl-cell--12-col ">
	
	<div class="pic-list--inner hide-on-small-only mdl-grid row" >
		<div class="col l4 m4 s4">
			<pic each="{ columns[0] }" data="{ this }"></pic>
		</div>
		<div class="col l4 m4 s4">
			<pic each="{ columns[1] }" data="{ this }"></pic>
		</div>
		<div class="col l4 m4 s4">
			<pic each="{ columns[2] }" data="{ this }"></pic>
		</div>
	</div>
	
	<div class="pic-list--inner hide-on-med-and-up mdl-grid row" >
		<div class="col s12">
			<pic each="{ photos }" data="{ this }"></pic>
		</div>
	</div>
	<div class="loader--outer">
		<loader if="{ showLoader }"></loader>
	</div>
	<div if="{ error.visible }" class="card rate-limit">
		<div class="card-image grey darken-3">
          <i class="material-icons lock-sign">lock</i>
          <span class="card-title">Sorry!</span>
        </div>
		<div class="card-content grey darken-4 black">
			{ error.message }
		</div>
	</div>
	<script>
		let scope = this;
		let page = 1;
		let pending = false;
		let colHeigth = [0,0,0];
		let loader = {
			tm: false,
			show: () => {
				this.tm = setTimeout( () => {
					scope.showLoader = true;
					scope.update();
				}, 200 );
			},
			hide: () => {
				clearTimeout(this.tm);
				scope.showLoader = false;
			}
		};
		scope.photos = [];
		scope.photosSorted = [];
		scope.columns = [
			[], [], []
		];
		scope.showLoader = false;
		scope.exceeded = false;

		scope.error = {
			messages: [
				'Something went wrong :(',
				'API Rate Limit Exceeded. Try to get back within 1 hour',
				'API service does not recognize your credentials'
			],
			code: 0,
			message: '',
			visible: false,
			show: (errorCode) => {
				scope.error.code = errorCode;
				scope.error.message = scope.error.messages[errorCode];
				scope.error.visible = true;

			},
			hide: () => {
				scope.error.visible = false;
				scope.error.code = 0;
				scope.error.message = '';
			}
		};

		getPhotos(page);

		document.addEventListener('scroll', function(ev) {
			if((window.innerHeight + window.scrollY) >= document.body.scrollHeight &&
					!pending &&
					!scope.exceeded &&
					!(scope.error.visible && (scope.error.code === 1 || scope.error.code === 2))) {
				pending = true;
				getPhotos(++page);
			}
		});


		function getPhotos(page) {
			loader.show();
			scope.error.hide();
			getPageFromLS(page).then(function(data) {
				scope.photos = scope.photos.concat(data.data);
				sortPhotos(data.data);
				loader.hide();
				scope.update();
				pending = false;
				console.log('fropm LS');
			}).catch(function(error) {
				unsplash.photos.listPhotos(page, 9, "latest")
					.then(unsplash.toJson)
					.then(response => {
						if(response.status && response.status === 401) {
							scope.error.show(2);
						} else if(response.length) {
							console.log(response);
							scope.photos = scope.photos.concat(response);
							localStorage.setItem(
								'page_' + page,
								JSON.stringify({data: response, date: new Date()})
							);
							sortPhotos(response);
							console.log('from API');
						}
						loader.hide();
						pending = false;
						scope.update();
					}).catch(error => {
						scope.error.show(1);
						loader.hide();
						pending = false;
						scope.update();
					});
			});

		}


		function getPageFromLS (page) {
			return new Promise(function(resolve, reject) {
				if(!config.LS.cache) {
					reject();
				}
				let JSONData = localStorage.getItem('page_' + page);
				if(!JSONData) {
					reject('No data');
				} 
				let data = JSON.parse(JSONData);
				if(data && new Date(data.date) < new Date(new Date().getTime() - config.LS.term ? config.LS.term : 3e+5)) {
					reject('Expired');
				} else {
					resolve(data);
				}
			});
		}

		function sortPhotos(list) {

			if(!scope.columns[0].length) {
				scope.columns[0].push(list[0]);
				scope.columns[1].push(list[1]);
				scope.columns[2].push(list[2]);

				colHeigth[0] += getHeight(list[0]);
				colHeigth[1] += getHeight(list[1]);
				colHeigth[2] += getHeight(list[2]);
			}

			for (let i = scope.columns[0].length === 1 ? 3 : 0; i <= list.length-3; i += 3) {
				findVertexes(list.slice(i, i+3));
			}

		}

		function findVertexes(piece) {
			let heightOfThreeLast = piece.map(getHeight);

			let diffOfThreeLast = {
				max: heightOfThreeLast.indexOf(Math.max.apply(this, heightOfThreeLast)),
				min: heightOfThreeLast.indexOf(Math.min.apply(this, heightOfThreeLast)),
			};

			if(diffOfThreeLast.min === diffOfThreeLast.max) {
				diffOfThreeLast.min = 2 - diffOfThreeLast.min;
			}

			diffOfThreeLast.mid = 3 - diffOfThreeLast.min - diffOfThreeLast.max;

			let vertexes = {
				max: colHeigth.indexOf(Math.max.apply(this, colHeigth)),
				min: colHeigth.indexOf(Math.min.apply(this, colHeigth)),
			};

			if(vertexes.min === vertexes.max) {
				vertexes.min = 2 - vertexes.min;
			}

			vertexes.mid = 3 - vertexes.min - vertexes.max;


			for (let i = 0; i < 3; i++) {
				if(i === vertexes.min) {
					scope.columns[i].push(piece[diffOfThreeLast.max]);
					colHeigth[i] += heightOfThreeLast[diffOfThreeLast.max];
				} else if(i !== vertexes.max) {
					scope.columns[i].push(piece[diffOfThreeLast.min]);
					colHeigth[i] += heightOfThreeLast[diffOfThreeLast.min];
				} else {
					scope.columns[i].push(piece[diffOfThreeLast.mid]);
					colHeigth[i] += heightOfThreeLast[diffOfThreeLast.mid];
				}
			}

		}

		function getHeight(item) {
			return item.height / (item.width / 400);
		}
	</script>
</pic-list>
