(...) <-! describe 'module angular.ujs'
$compile = $rootScope = $document = $httpBackend = $sniffer = void

beforeEach module 'angular.ujs'
beforeEach inject !(_$compile_, _$rootScope_, _$document_, _$httpBackend_, _$sniffer_) ->
  $compile      := _$compile_
  $rootScope    := _$rootScope_
  $document     := _$document_
  $httpBackend  := _$httpBackend_
  $sniffer      := _$sniffer_

afterEach !(...) ->
  $httpBackend.verifyNoOutstandingExpectation!
  $httpBackend.verifyNoOutstandingRequest!

it 'should start test' !(...) ->
  expect true .toBeTruthy!

describe '$getRailsCSRF conditional inject' !(...) ->
  const MOCK_META_TAGS = '''
    <meta content="authenticity_token" name="csrf-param">
    <meta content="qwertyuiopasdfghjklzxcvbnm=" name="csrf-token">
  '''

  it 'should return csrf meta tags' inject !($getRailsCSRF) ->
    $document.find 'head' .append MOCK_META_TAGS
    const metaTags = $getRailsCSRF!

    expect metaTags['csrf-param'] .toBe 'authenticity_token'
    expect metaTags['csrf-token'] .toBe 'qwertyuiopasdfghjklzxcvbnm='

describe 'noopRailsConfirmCtrl' !(...) ->
  noopCtrl = $scope = void

  beforeEach inject !($controller) ->
    $scope    := $rootScope.$new!
    noopCtrl  := $controller 'noopRailsConfirmCtrl' {$scope}

  afterEach !(...) ->
    $scope.$destroy!

  it 'should be like RailsConfirmCtrl' !(...) ->    
    expect noopCtrl.allowAction .toBeDefined!
    expect noopCtrl.denyDefaultAction .toBeDefined!
    expect noopCtrl.allowAction! .toBeTruthy!

  it 'should supress event when denyDefaultAction called' !(...) ->
    const event = $.Event 'click'
    noopCtrl.denyDefaultAction event

    expect event.isDefaultPrevented! .toBeTruthy!
    expect event.isPropagationStopped! .toBeTruthy!

describe 'RailsConfirmCtrl' !(...) ->
  railsConfirmCtrl = confirmSpy = $scope = void

  beforeEach inject !($controller) ->
    $scope            := $rootScope.$new!
    railsConfirmCtrl  := $controller 'RailsConfirmCtrl' {$scope}
    confirmSpy        := spyOn window, 'confirm'

  afterEach !(...) ->
    $scope.$destroy!

  it 'should have a denyDefaultAction method' !(...) ->
    expect railsConfirmCtrl.denyDefaultAction .toBeDefined!

  it 'should have a allowAction method' !(...) ->
    expect railsConfirmCtrl.allowAction .toBeDefined!

  it "shouldn't allow action when message missing" !(...) ->
    const $attrs = do
      confirm: void

    expect railsConfirmCtrl.allowAction($attrs) .toBeFalsy!
    expect confirmSpy .not.toHaveBeenCalled!

  it "shouldn't allow action when cancel confirm" !(...) ->
    confirmSpy := confirmSpy.andReturn false
    const $attrs = do
      confirm: 'iMessage'

    expect railsConfirmCtrl.allowAction($attrs) .toBeFalsy!
    expect confirmSpy .toHaveBeenCalled!

  it 'should allow action when message provided and confirmed' !(...) ->
    confirmSpy := confirmSpy.andReturn true
    const $attrs = do
      confirm: 'iMessage'

    expect railsConfirmCtrl.allowAction($attrs) .toBeTruthy!
    expect confirmSpy .toHaveBeenCalled!

describe 'noopRailsRemoteFormCtrl' !(...) ->
  noopCtrl = $scope = void

  beforeEach inject !($controller) ->
    $scope   := $rootScope.$new!
    noopCtrl := $controller 'noopRailsRemoteFormCtrl' {$scope}

  afterEach !(...) ->
    $scope.$destroy!

  it 'should have a submit method' !(...) ->
    expect noopCtrl.submit .toBeDefined!

describe 'RailsRemoteFormCtrl' !(...) ->
  railsRemoteFormCtrl = $scope = void

  beforeEach inject !($controller) ->
    $scope              := $rootScope.$new!
    railsRemoteFormCtrl := $controller 'RailsRemoteFormCtrl' {$scope}

  afterEach !(...) ->
    $scope.$destroy!

  it 'should have a submit method' !(...) ->
    expect railsRemoteFormCtrl.submit .toBeDefined!

  it 'should submit simple form using $http' !(...) ->
    const EXPECTED_NAME = 'angular-ujs'
    
    $httpBackend.expectPOST '/users' do
      name: EXPECTED_NAME
    .respond 201

    const $element = $compile('''
      <form method="POST" action="/users">
        <input ng-model="name" type="text">
      </form>
    ''')($scope)
    $document.find 'body' .append $element

    $element.find 'input' .eq 0 .val EXPECTED_NAME .change!
    $scope.$digest!

    railsRemoteFormCtrl.submit $element, true
    $httpBackend.flush!
    $element.remove!

  it 'should submit complex, named form using $http' !(...) ->
    const EXPECTED_NAME = 'angular-ujs'
    const EXPECTED_EMAIL = 'developer@tomchentw.com'
    const EXPECTED_TOS = 'read'
    const EXPECTED_AGE = 18
    const EXPECTED_COMMIT = 'private'

    const EXPECTED_COLOR = 'green'
    const EXPECTED_DESC = 'angular-ujs is ready to work with your awesome project!!'
    const COLORS = <[red green blue]>

    $scope.colors = COLORS

    $httpBackend.expectPOST '/users' do
      user:
        name: EXPECTED_NAME
        email: EXPECTED_EMAIL
        tos: EXPECTED_TOS
        age: EXPECTED_AGE
        commit: EXPECTED_COMMIT
        color: EXPECTED_COLOR
        desc: EXPECTED_DESC
    .respond 201

    const $element = $compile('''
      <form method="POST" action="/users">
        <input ng-model="user.name" type="text">
        <input ng-model="user.email" type="email">
        <input ng-model="user.tos" type="checkbox" ng-true-value="read">
        <input ng-model="user.age" type="number">

        <input ng-model="user.commit" value="public" type="radio">
        <input ng-model="user.commit" value="protected" type="radio">
        <input ng-model="user.commit" value="private" type="radio">

        <select ng-model="user.color" ng-options="color for color in colors"></select>
        <textarea ng-model="user.desc"></textarea>
      </form>
    ''')($scope)
    $document.find 'body' .append $element

    const inputs = $element.find 'input'
    inputs.eq 0 .val EXPECTED_NAME .change!
    inputs.eq 1 .val EXPECTED_EMAIL .change!
    inputs.2.click!
    inputs.eq 3 .val EXPECTED_AGE .change!
    inputs.6.click!
    
    $element.find 'select' .val COLORS.indexOf(EXPECTED_COLOR) .change!
    $element.find 'textarea' .val EXPECTED_DESC .change!
    $scope.$digest!

    railsRemoteFormCtrl.submit $element, 'user'
    $httpBackend.flush!
    $element.remove!

describe 'remote directive' !(...) ->
  $scope = void

  beforeEach !(...) ->
    $scope       := $rootScope.$new!

  afterEach !(...) ->
    $scope.$destroy!

  it 'should submit using $http for form element' !(...) ->
    const EXPECTED_NAME = 'angular-ujs'
    const confirmSpy = spyOn window, 'confirm'
    
    $httpBackend.expectPOST '/users' do
      user:
        name: EXPECTED_NAME
    .respond 201

    const $element = $compile('''
      <form method="POST" action="/users" data-remote="true">
        <input ng-model="user.name" type="text">
        <input type='submit'>
      </form>
    ''')($scope)
    $document.find 'body' .append $element

    $element.find 'input' .eq 0 .val EXPECTED_NAME .change!
    $scope.$digest!
    
    $element.find 'input' .eq 1 .click!
    $httpBackend.flush!
    expect confirmSpy .not.toHaveBeenCalled!
    $element.remove!

  it 'should submit with named data-remote' !(...) ->
    const EXPECTED_NAME = 'angular-ujs'
    const confirmSpy = spyOn window, 'confirm'
    
    $httpBackend.expectPOST '/users' do
      user:
        name: EXPECTED_NAME
    .respond 201

    const $element = $compile('''
      <form method="POST" action="/users" data-remote="user">
        <input ng-model="user.name" type="text">
        <input type='submit'>
      </form>
    ''')($scope)
    $document.find 'body' .append $element

    $element.find 'input' .eq 0 .val EXPECTED_NAME .change!
    $scope.$digest!
    
    $element.find 'input' .eq 1 .click!
    $httpBackend.flush!
    expect confirmSpy .not.toHaveBeenCalled!
    $element.remove!

  it 'should work with confirm directive' !(...) ->
    const EXPECTED_NAME = 'angular-ujs'
    const confirmSpy = spyOn window, 'confirm' .andReturn true
    
    $httpBackend.expectPOST '/users' do
      user:
        name: EXPECTED_NAME
    .respond 201

    const $element = $compile('''
      <form method="POST" action="/users" data-confirm="Are u sure?" data-remote="true">
        <input ng-model="user.name" type="text">
        <input type='submit'>
      </form>
    ''')($scope)
    $document.find 'body' .append $element

    $element.find 'input' .eq 0 .val EXPECTED_NAME .change!
    $scope.$digest!
    
    $element.find 'input' .eq 1 .click!

    expect confirmSpy .toHaveBeenCalled!

    $httpBackend.flush!
    $element.remove!

describe 'method directive with remote directive' !(...) ->
  $scope = void

  beforeEach inject !($controller) ->
    $scope       := $rootScope.$new!

  afterEach !(...) ->
    $scope.$destroy!

  it "should submit with remote form" !(...) ->
    response = false
    runs !->
      $httpBackend.expectPOST '/users/sign_out' do
        _method: 'DELETE'
      .respond 201

      const $element = $compile('''
        <a href="/users/sign_out" data-method="DELETE" data-remote="true">SignOut</a>
      ''')($scope)
      $document.find 'body' .append $element

      $scope.$on 'rails:remote:success' !->
        response := true

      $element.click!
      $httpBackend.flush!

    waitsFor ->
      response
    , 'response should be returned', 500

  it 'should work with confirm and remote form' !(...) ->
    response = false

    runs !->
      spyOn window, 'confirm' .andReturn true
      $httpBackend.expectPOST '/users/sign_out' do
        _method: 'DELETE'
      .respond 201

      const $element = $compile('''
        <a href="/users/sign_out" data-method="DELETE" data-remote="true" data-confirm="Are u sure?">SignOut</a>
      ''')($scope)
      $document.find 'body' .append $element

      $scope.$on 'rails:remote:success' !->
        response := true

      $element.click!
      $httpBackend.flush!

    waitsFor ->
      response
    , 'response should be returned', 500










