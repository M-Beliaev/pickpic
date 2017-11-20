<pic class="pic" style="background-color: { opts.data.color};">
	<div class="{loaded: loaded, pic__inner: true}" style="padding-top: calc({ opts.data.height / ( opts.data.width / 100) }% - 2px);">
		<!-- <img src="{ opts.data.urls.small }" onload="{ load }"> -->
		<div class="pic__img" style="background: url('{ opts.data.urls.small }') center / cover no-repeat;"></div>
		<div class="cover"><i class="material-icons search-icon">search</i></div>
	</div>
	<script>
		let scope = this;
		scope.loaded = false;
		let image  = new Image();
		
		image.onload = () => {
			scope.loaded = true;
			scope.update();
		};

		image.src =  opts.data.urls.small;
	</script>
</pic>
