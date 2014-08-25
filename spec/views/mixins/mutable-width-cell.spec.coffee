define [
  'oraculum'
  'oraculum/mixins/disposable'
  'oraculum/plugins/tabular/views/mixins/cell'
  'muTable/views/mixins/mutable-width-cell'
], (Oraculum) ->
  'use strict'

  describe 'muTableWidth.CellMixin', ->

    Oraculum.extend 'Model', 'Disposable.muTableWidth.CellMixin.Test.Model', {
    }, mixins: ['Disposable.Mixin']

    Oraculum.extend 'View', 'muTableWidth.CellMixin.Test.Cell', {
      mixinOptions:
        disposable:
          disposeAll: true
    }, mixins: [
      'Disposable.Mixin'
      'Cell.ViewMixin'
      'muTableWidth.CellMixin'
    ]

    column = null
    testCell = null

    beforeEach ->
      column = Oraculum.get 'Disposable.muTableWidth.CellMixin.Test.Model'
      testCell = Oraculum.get 'muTableWidth.CellMixin.Test.Cell', {column}

    afterEach ->
      testCell.dispose()

    it 'should set the elements width to the models width attribute', ->
      column.set width: 200
      expect(testCell.$el.width()).toBe 200
