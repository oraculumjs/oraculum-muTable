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

    describe 'muTableColumnWidth.CellMixin', ->

      resizable = undefined
      resizableInit = undefined
      resizableDisable = undefined
      resizableDestroy = undefined

      mockEvent = {}
      mockUIObject = size: width: 100

      beforeEach ->
        cell = Oraculum.get 'muTableColumnWidth.CellMixin.Test.View', {model, column}
        resizable = sinon.stub $.fn, 'resizable'
        resizableInit = resizable.withArgs cell.mixinOptions.muTableColumnWidth
        resizableDestroy = resizable.withArgs 'destroy'
        resizableDisable = resizable.withArgs 'option', 'disabled'

      afterEach ->
        cell.dispose()
        resizable.restore()

      it 'should throw if mixed into an object that fails to implement Cell.ViewMixin', ->
        expect(-> Oraculum.get('View').__mixin 'muTableColumnWidth.CellMixin').toThrow()

      it 'should forward plugin events through the view', ->
        cell.trigger 'addedToParent'
        _.each ['resize','resizestop','resizestart','resizecreate'], (eventName) ->
          cell.on eventName, stub = sinon.stub()
          cell._resolveResizableTarget().trigger eventName, mockUIObject
          expect(stub).toHaveBeenCalledOnce()

      it 'should initialize the jQuery UI resizable plugin in the target cell element only once', ->
        expect(resizable).not.toHaveBeenCalled()
        cell.trigger 'addedToParent'
        expect(resizableInit).toHaveBeenCalledOnce()
        cell.trigger 'addedToParent'
        expect(resizableInit).toHaveBeenCalledOnce()

      it 'should update the column\'s width attribute when cell is resized', ->
        expect(column.get 'width').not.toBeDefined()
        cell.trigger 'resize', mockEvent, mockUIObject
        expect(column.get 'width').toBe 100

      it 'should disable the resizable plugin when the columns resizable bit is set to false', ->
        expect(resizable).not.toHaveBeenCalled()
        cell.trigger 'addedToParent'
        expect(resizableDisable).toHaveBeenCalledOnce()
        expect(resizableDisable).toHaveBeenCalledWith 'option', 'disabled', true
        column.set resizable: true
        expect(resizableDisable).toHaveBeenCalledTwice()
        expect(resizableDisable).toHaveBeenCalledWith 'option', 'disabled', false

      it 'should destroy the resizable plugin when the cell is disposed', ->
        expect(resizableDestroy).not.toHaveBeenCalled()
        cell.trigger 'addedToParent'
        expect(resizableDestroy).not.toHaveBeenCalled()
        cell.dispose()
        expect(resizableDestroy).toHaveBeenCalledOnce()

    describe 'muTableColumnWidth.RowMixin', ->

      beforeEach ->
        row = Oraculum.get 'muTableColumnWidth.RowMixin.Test.View', {
          columns, collection
        }

      afterEach ->
        row.dispose()

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

      it 'should throw if mixed into an object that fails to implement Table.ViewMixin', ->
        expect(-> Oraculum.get('View').__mixin 'muTableColumnWidth.TableMixin').toThrow()

      it 'should throw if a row is rendered that fails to implement Row.ViewMixin', ->
        table.mixinOptions.list.modelView = 'View'
        expect(-> table.render()).toThrow()

      it 'should apply muTableColumnWidth.RowMixin to all rows', ->
        table.render()
        _.each table.getModelViews(), (row) ->
          expect(row).toUseMixin 'muTableColumnWidth.RowMixin'
