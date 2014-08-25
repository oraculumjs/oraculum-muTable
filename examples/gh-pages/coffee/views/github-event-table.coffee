define [
  'oraculum'
  'oraculum/views/mixins/attach'
  'oraculum/views/mixins/auto-render'
  'oraculum/views/mixins/html-templating'
  'oraculum/plugins/tabular/views/mixins/table'
  'cs!mu/examples/gh-pages/coffee/views/github-event-row'
  'cs!mu/examples/gh-pages/coffee/views/table-header-row'
  'muTable/views/mixins/mutable-column-width'
], (Oraculum) ->
  'use strict'

  # Extend a view to make it behave like a table
  Oraculum.extend 'View', 'GithubEvents.Table', {
    tagName: 'table'
    className: 'table table-striped table-hover table-bordered'

    mixinOptions:
      subviews:
        header: ->
          view: 'SortableColumnHeader.Row'
          viewOptions:
            container: @$ 'thead'
            collection: @columns
      list:
        modelView: 'GithubEvent.Row'
        listSelector: 'tbody'
      template: '<thead/><tbody/>'

  }, {
    singleton: true
    mixins: [
      'Table.ViewMixin'
      'Attach.ViewMixin'
      'HTMLTemplating.ViewMixin'
      'muTableColumnWidth.TableMixin'
      'AutoRender.ViewMixin'
    ]
  }
