# Modify objects in memory before we bootstrap the application
# Modifying entire applications in Oraculum is trivially easy.
define [
  'oraculum'

  'cs!mu/examples/gh-pages/coffee/templates/home'

  'cs!libs'
  'cs!models/pages'
  'cs!mu/examples/gh-pages/coffee/models/column'
  'cs!mu/examples/gh-pages/coffee/models/github-event'
  'cs!mu/examples/gh-pages/coffee/views/github-event-table'
], (Oraculum, home) ->

  pages = Oraculum.get 'Pages.Collection'
  pages.__dispose()

  Oraculum.get 'Pages.Collection', [{
    id: 'home'
    name: 'Home'
    markdown: home
  }], parse: true

  makeEventedMethod = Oraculum.get 'makeEventedMethod'

  Oraculum.onTag 'Index.Controller', (controller) ->
    makeEventedMethod controller, 'index'
    controller.on 'index:after', ({page}) ->
      collection = Oraculum.get 'GithubEvent.Collection'
      columns = Oraculum.get 'Columns', [{
        label: 'Unique Identifier'
        sortable: true
        attribute: 'id'
      }, {
        label: 'Actor'
        sortable: true
        orderable: true
        attribute: 'actor.login'
      }, {
        label: 'Event Type'
        sortable: true
        orderable: true
        attribute: 'type'
      }, {
        label: 'Repo Name'
        sortable: true
        orderable: true
        attribute: 'repo.name'
      }], sortCollection: collection
      controller.reuse 'table-demo', 'GithubEvents.Table',
        container: '#muTable-demo'
        collection: collection
        columns: columns

  # Bootstrap the app
  require ['cs!index']
