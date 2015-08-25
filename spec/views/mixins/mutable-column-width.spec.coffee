define [
  'oraculum'
  'oraculum/libs'

  'oraculum/mixins/disposable'
  'oraculum/views/mixins/attach'
  'oraculum/models/mixins/disposable'

  'oraculum/plugins/tabular/views/mixins/table'
  'oraculum/plugins/tabular/views/mixins/row'
  'oraculum/plugins/tabular/views/mixins/cell'

  'oraculum/plugins/tabular/views/cells/text'
], (Oraculum) ->
  'use strict'

  $ = Oraculum.get 'jQuery'

  describe 'muTableColumnWidth mixin suite', ->

    Oraculum.extend 'View', 'jQueryResizable.ViewMixin.Test.View', {
      mixinOptions: jQueryResizable: '': { handles: 'e' }
    }, mixins: [
      'Disposable.Mixin'
      'Attach.ViewMixin'
      'jQueryResizable.ViewMixin'
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

    describe 'jQueryResizable.ViewMixin', ->

      view = undefined
      resizable = undefined

      beforeEach ->
        resizable = sinon.stub $.fn, 'resizable'
        view = Oraculum.get 'jQueryResizable.ViewMixin.Test.View'

      afterEach ->
        view.remove().dispose()
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

      it 'should use jQueryResizable.ViewMixin', ->
        expect(row).toUseMixin 'jQueryResizable.ViewMixin'

      it 'should throw if mixed into an object that fails to implement Row.ViewMixin', ->
        expect(-> Oraculum.get('View').__mixin 'muTableColumnWidth.RowMixin').toThrow()

      it 'should throw if a row is rendered that fails to implement Row.ViewMixin', ->
        row.mixinOptions.list.modelView = 'View'
        expect(-> row.render()).toThrow()

      it 'should apply muTableColumnWidth.CellMixin to all rows', ->
        row.render()
        _.each row.getModelViews(), (cell) ->
          expect(cell).toUseMixin 'muTableColumnWidth.CellMixin'

    describe 'muTableColumnWidth.TableMixin', ->

      beforeEach ->
        table = Oraculum.get 'muTableColumnWidth.TableMixin.Test.View', {
          columns, collection
        }

      afterEach ->
        table.dispose()

      it 'should use jQueryResizable.ViewMixin', ->
        expect(table).toUseMixin 'jQueryResizable.ViewMixin'

      it 'should throw if mixed into an object that fails to implement Table.ViewMixin', ->
        expect(-> Oraculum.get('View').__mixin 'muTableColumnWidth.TableMixin').toThrow()

      it 'should throw if a row is rendered that fails to implement Row.ViewMixin', ->
        table.mixinOptions.list.modelView = 'View'
        expect(-> table.render()).toThrow()

      it 'should apply muTableColumnWidth.RowMixin to all rows', ->
        table.render()
        _.each table.getModelViews(), (row) ->
          expect(row).toUseMixin 'muTableColumnWidth.RowMixin'
