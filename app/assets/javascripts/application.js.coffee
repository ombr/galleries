#= require jquery
#= require angular/angular
#= require angular-ui-router/release/angular-ui-router
#= require angular-rails-templates
#= require_tree ./templates

angular.module('galleries.home', [])
  .controller 'homeCtrl', ['$scope', ($scope)->
    $scope.welcome = "Welcome home !!"
  ]
angular.module('galleries', ['ui.router', 'galleries.home', 'templates'])
  .config [ '$stateProvider', '$urlRouterProvider', ($stateProvider, $urlRouterProvider)->
    $stateProvider
      .state('index', {
        url: '/',
        templateUrl: 'templates/home.html',
        controller: 'homeCtrl'
      })
    $urlRouterProvider.otherwise('/')
  ]
   # .config (RestangularProvider)->
   #   # RestangularProvider.setBaseUrl('http://127.0.0.1:5000')
   #   RestangularProvider.setBaseUrl('http://poc-backend.herokuapp.com')
   #   return RestangularProvider
