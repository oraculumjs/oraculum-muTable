define ['oraculum'], (Oraculum) ->
  'use strict'

  describe 'muTableColumnOrder.CellMixin', ->

    Oraculum.extend 'Model', 'Disposable.muTableColumnOrder.CellMixin.Test.Model', {
    }, mixins: ['Disposable.Mixin']

    Oraculum.extend 'Collection', 'Disposable.muTableColumnOrder.CellMixin.Test.Collection', {
      model: 'Disposable.muTableColumnOrder.CellMixin.Test.Model'
    }, mixins: ['Disposable.CollectionMixin']

    Oraculum.extend 'View', 'muTableColumnOrder.CellMixin.Test.Cell', {
      mixinOptions:
        disposable:
          disposeAll: true
    }, mixins: [
      'Disposable.Mixin'
      'Attach.ViewMixin'
      'muTableColumnOrder.CellMixin'
      'AutoRender.ViewMixin'
    ]

    column1 = null
    column2 = null
    testView1 = null
    testView2 = null

    beforeEach ->
      columns = Oraculum.get 'Disposable.muTableColumnOrder.CellMixin.Test.Collection'
      column1 = columns.add attribute: 'attribute1'
      column2 = columns.add attribute: 'attribute2'
      testView1 = Oraculum.get 'muTableColumnOrder.CellMixin.Test.Cell',
        model: column1
        container: document.body
      testView2 = Oraculum.get 'muTableColumnOrder.CellMixin.Test.Cell',
        model: column2
        container: document.body

    afterEach ->
      testView1.dispose()
      testView2.dispose()

    describe 'draggable behavior', ->
      # TODO
