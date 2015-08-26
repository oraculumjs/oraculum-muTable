# Modify objects in memory before we bootstrap the application
# Modifying entire applications in Oraculum is trivially easy.
define [
  'oraculum'

  'cs!mu/examples/gh-pages/coffee/templates/home'

  'oraculum/models/mixins/disposable'

  'cs!libs'
  'cs!models/pages'
  'cs!mu/examples/gh-pages/coffee/models/column'
  'cs!mu/examples/gh-pages/coffee/models/github-event'
  'cs!mu/examples/gh-pages/coffee/views/github-event-table'
], (Oraculum, home) ->

  # Since we're daisy chaining off an existing Oraculum application,
  # Grab a reference to the singleton Pages collection
  # And dispose of it/all its models.
  Oraculum.get('Pages.Collection').__mixin('Disposable.CollectionMixin', {
    disposable: disposeModels: true
  }).dispose()

  Oraculum.get 'Pages.Collection', [{
    id: 'home'
    name: 'Home'
    markdown: home
  }], parse: true

  # Use FactoryJS' object-level AOP hook to intercept the Index controller
  Oraculum.onTag 'Index.Controller', (controller) ->

    # Use Oraculum's method-level AOP mechanism to event the index action
    Oraculum.makeEventedMethod controller, 'index'

    # Add an event listener for our index action hook
    controller.on 'index:after', ({page}) ->

      # Create our data collection
      collection = Oraculum.get 'GithubEvent.Collection'

      # And our tabular column definition
      columns = Oraculum.get 'Columns', [{
        width: '20%'
        label: 'Unique Identifier'
        sortable: true
        orderable: true
        resizable: true
        attribute: 'id'
      }, {
        width: '20%'
        label: 'Actor'
        sortable: true
        orderable: true
        resizable: true
        attribute: 'actor_login'
      }, {
        width: '20%'
        label: 'Event Type'
        sortable: true
        orderable: true
        resizable: true
        attribute: 'type'
      }, {
        width: '40%'
        label: 'Repo Name'
        sortable: true
        orderable: true
        resizable: true
        attribute: 'repo_name'
      }], sortCollection: collection

      # Inject our table into the dom
      table = controller.reuse 'table-demo', 'GithubEvents.Table',
        columns: columns
        container: '#muTable-demo'
        collection: collection

  # Bootstrap the app
  require ['cs!index']
