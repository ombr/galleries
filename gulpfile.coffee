gulp = require('gulp')
concat = require('gulp-concat')
coffee = require('gulp-coffee')
debug = require('gulp-debug')
ngAnnotate = require('gulp-ng-annotate')

gulp.task 'default', [ 'coffee' ]

paths =
  coffee: ['./app/assets/javascripts/angular/**/*.coffee']
gulp.task 'coffee', () ->
  gulp
    .src(paths.coffee)
    .pipe(coffee(bare: true))
    .pipe(ngAnnotate())
    .pipe(concat('angular-app.js'))
    # .pipe(debug())
    .pipe(gulp.dest('./app/assets/javascripts/'))

gulp.task 'watch', ->
  gulp.watch paths.coffee, ['coffee']
  return
