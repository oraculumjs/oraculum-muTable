define [
  'oraculum'
  'oraculum/libs'

  'oraculum/mixins/disposable'
  'oraculum/models/mixins/disposable'

  'oraculum/plugins/tabular/views/mixins/table'
  'oraculum/plugins/tabular/views/mixins/row'
  'oraculum/plugins/tabular/views/mixins/cell'

  'oraculum/plugins/tabular/views/cells/text'
], (Oraculum) ->
  'use strict'

  $ = Oraculum.get 'jQuery'

  describe 'muTableColumnWidth mixin suite', ->

    Oraculum.extend 'View', 'jQueryUIResizable.ViewMixin.Test.View', {
      mixinOptions: jQueryUIResizable: '': { handles: 'e' }
    }, mixins: [
      'Disposable.Mixin'
      'jQueryUIResizable.ViewMixin'
    ]

    Oraculum.extend 'View', 'muTableColumnWidth.CellMixin.Test.View', {
    }, mixins: [
      'Disposable.Mixin'
      'Cell.ViewMixin'
      'muTableColumnWidth.CellMixin'
    ]

    Oraculum.extend 'View', 'muTableColumnWidth.RowMixin.Test.View', {
      mixinOptions: list: modelView: 'Text.Cell'
    }, mixins: [
      'Disposable.Mixin'
      'Row.ViewMixin'
      'muTableColumnWidth.RowMixin'
    ]

    Oraculum.extend 'View', 'muTableColumnWidth.RowMixin.Test1.View', {
      mixinOptions: list: modelView: 'Text.Cell'
    }, mixins: [
      'Disposable.Mixin'
      'Row.ViewMixin'
    ]

    Oraculum.extend 'View', 'muTableColumnWidth.TableMixin.Test.View', {
      mixinOptions: list: modelView: 'muTableColumnWidth.RowMixin.Test1.View'
    }, mixins: [
      'Disposable.Mixin'
      'Table.ViewMixin'
      'muTableColumnWidth.TableMixin'
    ]

    row = undefined
    cell = undefined
    table = undefined
    columns = column = undefined
    collection = model = undefined

    beforeEach ->
      model = Oraculum.get 'Model', {'attribute'}
      column = Oraculum.get 'Model', {'attribute'}
      columns = Oraculum.get 'Collection', [column]
      collection = Oraculum.get 'Collection', [model]

    afterEach ->
      model.__mixin 'Disposable.Mixin'
      column.__mixin 'Disposable.Mixin'
      columns.__mixin('Disposable.CollectionMixin', { disposable: disposeModels: true }).dispose()
      collection.__mixin('Disposable.CollectionMixin', { disposable: disposeModels: true }).dispose()

    describe 'jQueryUIResizable.ViewMixin', ->

      view = undefined
      resizable = undefined

      beforeEach ->
        resizable = sinon.stub $.fn, 'resizable'
        view = Oraculum.get 'jQueryUIResizable.ViewMixin.Test.View'

      afterEach ->
        view.dispose()
        resizable.restore()

      it 'should debounce initialize the plugin automatically', (done) ->
        expect(resizable).not.toHaveBeenCalled()
        setTimeout (-> done expect(resizable).toHaveBeenCalledOnce()), 110

      it 'should debounce re-initialize the plugin on subviewCreated events', (done) ->
        expect(resizable).not.toHaveBeenCalled()
        view.trigger 'subviewCreated' # Multiple invocations to testing debounced behavior
        view.trigger 'subviewCreated' # Multiple invocations to testing debounced behavior
        view.trigger 'subviewCreated' # Multiple invocations to testing debounced behavior
        setTimeout (-> done expect(resizable).toHaveBeenCalledOnce()), 110

      it 'should debounce re-initialize the plugin on visibilityChange events', (done) ->
        expect(resizable).not.toHaveBeenCalled()
        view.trigger 'visibilityChange' # Multiple invocations to testing debounced behavior
        view.trigger 'visibilityChange' # Multiple invocations to testing debounced behavior
        view.trigger 'visibilityChange' # Multiple invocations to testing debounced behavior
        setTimeout (-> done expect(resizable).toHaveBeenCalledOnce()), 110

    describe 'muTableColumnWidth.CellMixin', ->

      resizable = undefined
      resizableDisable = undefined

      beforeEach ->
        cell = Oraculum.get 'muTableColumnWidth.CellMixin.Test.View', {model, column}
        resizable = sinon.stub $.fn, 'resizable'
        resizableDisable = resizable.withArgs 'option', 'disabled'

      afterEach ->
        cell.dispose()
        resizable.restore()

      it 'should update the column\'s width attribute when cell is resized', ->
        expect(column.get 'width').not.toBeDefined()
        cell.$el.trigger 'resize', size: width: 100
        expect(column.get 'width').toBe 100

      it 'should disable the resizable plugin when the columns resizable bit is set to false', ->
        expect(resizable).not.toHaveBeenCalled()
        column.set resizable: true
        expect(resizableDisable).toHaveBeenCalledOnce()
        expect(resizableDisable.firstCall).toHaveBeenCalledWith 'option', 'disabled', false
        column.set resizable: false
        expect(resizableDisable).toHaveBeenCalledTwice()
        expect(resizableDisable.secondCall).toHaveBeenCalledWith 'option', 'disabled', true

    describe 'muTableColumnWidth.RowMixin', ->

      beforeEach ->
        row = Oraculum.get 'muTableColumnWidth.RowMixin.Test.View', {
          columns, collection
        }

      afterEach ->
        row.dispose()

      it 'should use jQueryUIResizable.ViewMixin', ->
        expect(row).toUseMixin 'jQueryUIResizable.ViewMixin'

      it 'should debounce apply muTableColumnWidth.CellMixin to all rows', (done) ->
        row.render()
        setTimeout (-> done _.each row.getModelViews(), (cell) ->
          expect(cell).toUseMixin 'muTableColumnWidth.CellMixin'
        ), 100

    describe 'muTableColumnWidth.TableMixin', ->

      beforeEach ->
        table = Oraculum.get 'muTableColumnWidth.TableMixin.Test.View', {
          columns, collection
        }

      afterEach ->
        table.dispose()

      it 'should use jQueryUIResizable.ViewMixin', ->
        expect(table).toUseMixin 'jQueryUIResizable.ViewMixin'

      it 'should debounce apply muTableColumnWidth.RowMixin to all rows', (done) ->
        table.render()
        setTimeout (-> done _.each table.getModelViews(), (row) ->
          expect(row).toUseMixin 'muTableColumnWidth.RowMixin'
        ), 100
