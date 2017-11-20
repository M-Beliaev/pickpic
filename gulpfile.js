
var gulp = require('gulp'),
	paths = require('./gulp.paths'),
	gutil = require('gulp-util'),
	concat = require('gulp-concat'),
	uglify = require('gulp-uglify-es').default,
	browserify = require('browserify'),
	babelify = require('babelify'),
	watchify = require('watchify'),
	source = require('vinyl-source-stream'),
	buffer = require('vinyl-buffer'),
	riot = require('gulp-riot'),
	less = require('gulp-less'),
	scss = require('gulp-sass'),
	merge = require('merge-stream'),
	cleanCSS = require('gulp-cleancss');


try {
	var config = require('./build.config.json');
} catch (error) {
	gutil.log(gutil.colors.red('There is no "build.config.json". Please, make it from the "build.config.sample.json"'));
	process.exit();
}

if(!config.API) {
	gutil.log(gutil.colors.red('Your config file does not contain API option. Check the "build.config.json"'));
	process.exit();
}

var bundler = watchify(browserify(paths.source.js + 'app.js', watchify.args).transform(babelify.configure({
	presets: ["es2015"]
})));
var bundlerPr = watchify(browserify(paths.source.js + 'app.js').transform(babelify.configure({
	presets: ["es2015"]
})));

bundler.transform('brfs');

gulp.task('js', bundle);
gulp.task('jspr', bundlePr);
bundler.on('update', bundle); 
bundler.on('log', gutil.log);

function bundle() {
	return bundler.bundle()
	// log errors if they happen
		.on('error', gutil.log.bind(gutil, 'Browserify Error'))
		.pipe(source('build.js'))
		.pipe(buffer())
		.pipe(gulp.dest(paths.build.js));
}

function bundlePr() {
	return bundlerPr.bundle()
		.on('error', gutil.log.bind(gutil, 'Browserify Error'))
		.pipe(source('build.js'))
		.pipe(buffer())
		.pipe(uglify())
		.pipe(gulp.dest(paths.build.js));
}

gulp.task("css", function() {
	var scssStream = gulp.src(paths.source.scss + 'index.scss')
		.pipe(scss())
		.pipe(concat('scss-files.scss'))

	var lessStream = gulp.src(paths.source.less + 'index.less')
		.pipe(less())
		.pipe(concat('less-files.less'));

	var mergedStream = merge(scssStream, lessStream)
		.pipe(concat('index.css'))
		.pipe(gulp.dest(paths.build.css));
});

gulp.task("csspr", function() {
	var scssStream = gulp.src(paths.source.scss + 'index.scss')
		.pipe(scss())
		.pipe(concat('scss-files.scss'))

	var lessStream = gulp.src(paths.source.less + 'index.less')
		.pipe(less())
		.pipe(concat('less-files.less'));

	var mergedStream = merge(scssStream, lessStream)
		.pipe(concat('index.css'))
		.pipe(cleanCSS())
		.pipe(gulp.dest(paths.build.css));
});

gulp.task('tags', function() {
	gulp.src(paths.source.main + 'tags/*.tag')
		.pipe(riot())
		.pipe(concat('tags.js'))
		.pipe(gulp.dest(paths.build.js));
});

gulp.task('tagspr', function() {
	gulp.src(paths.source.main + 'tags/*.tag')
		.pipe(riot())
		.pipe(concat('tags.js'))
		.pipe(uglify())
		.pipe(gulp.dest(paths.build.js));
});

gulp.task('watch', function() {
	gulp.watch(paths.source.js + '**.js', ['js']);
	gulp.watch(paths.source.main + 'tags/*.tag', ['tags']);
	gulp.watch(paths.source.less + '*.less', ['css']);
	gulp.watch(paths.source.scss + '*.scss', ['css']);
});

gulp.task('default', ['js', 'watch', 'css', 'tags']);
gulp.task('prod', ['jspr', 'tagspr', 'csspr'], function(){
	gutil.log(gutil.colors.green('Application builded'));
	gutil.log('You may start browsing by command', gutil.colors.blue('gulp server'));
	process.exit();
});
