# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use LiveScript in this file: http://gkz.github.com/LiveScript
angular.module 'test-scenario.home' <[]>
.controller 'RemoteFormCtrl' <[
        $scope
]> ++ !($scope) ->

  $scope.$on 'rails:remote:success' !->
    $scope.success = 'Yo!'