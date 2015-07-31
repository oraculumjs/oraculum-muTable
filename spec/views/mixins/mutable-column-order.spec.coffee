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

  describe 'muTableColumnOrder mixin suite', ->

    Oraculum.extend 'View', 'muTableColumnOrder.CellMixin.Test.View', {
    }, mixins: [
      'Disposable.Mixin'
      'Cell.ViewMixin'
      'muTableColumnOrder.CellMixin'
    ]

    Oraculum.extend 'View', 'muTableColumnOrder.RowMixin.Test.View', {
      mixinOptions: list: modelView: 'Text.Cell'
    }, mixins: [
      'Disposable.Mixin'
      'Row.ViewMixin'
      'muTableColumnOrder.RowMixin'
    ]

    Oraculum.extend 'View', 'muTableColumnOrder.RowMixin.Test1.View', {
      mixinOptions: list: modelView: 'Text.Cell'
    }, mixins: [
      'Disposable.Mixin'
      'Row.ViewMixin'
    ]

    Oraculum.extend 'View', 'muTableColumnOrder.TableMixin.Test.View', {
      mixinOptions: list: modelView: 'muTableColumnOrder.RowMixin.Test1.View'
    }, mixins: [
      'Disposable.Mixin'
      'Table.ViewMixin'
      'muTableColumnOrder.TableMixin'
    ]

    row = undefined
    cell = undefined
    table = undefined
    collection = model = undefined
    columns = attrColumn = nameColumn = undefined

    beforeEach ->
      model = Oraculum.get 'Model', {'name', 'attribute'}
      attrColumn = Oraculum.get 'Model', {'attribute'}, idAttribute: 'attribute'
      nameColumn = Oraculum.get 'Model', {attribute: 'name'}, idAttribute: 'attribute'
      columns = Oraculum.get 'Collection', [attrColumn, nameColumn]
      collection = Oraculum.get 'Collection', [model]

    afterEach ->
      model.__mixin 'Disposable.Mixin'
      attrColumn.__mixin 'Disposable.Mixin'
      nameColumn.__mixin 'Disposable.Mixin'
      columns.__mixin('Disposable.CollectionMixin', { disposable: disposeModels: true }).dispose()
      collection.__mixin('Disposable.CollectionMixin', { disposable: disposeModels: true }).dispose()

    describe 'muTableColumnOrder.CellMixin', ->

      beforeEach -> cell = Oraculum.get 'muTableColumnOrder.CellMixin.Test.View', {model, column: attrColumn}
      afterEach -> cell.dispose()

      it 'should throw if mixed into an object that fails to implement Cell.ViewMixin', ->
        expect(-> Oraculum.get('View').__mixin 'muTableColumnOrder.CellMixin').toThrow()

      it 'should toggle the `.unorderable-cell` css class based on the column\'s `orderable` flag', ->
        expect(cell.el).toHaveClass 'unorderable-cell'
        attrColumn.set orderable: true
        expect(cell.el).not.toHaveClass 'unorderable-cell'

    describe 'muTableColumnOrder.RowMixin', ->

      sortable = undefined
      sortableInit = undefined
      sortableRefresh = undefined
      sortableDestroy = undefined

      beforeEach ->
        sortable = sinon.spy $.fn, 'sortable'
        row = Oraculum.get 'muTableColumnOrder.RowMixin.Test.View', {
          model
          modelView: 'Text.Cell'
          collection: columns
        }
        sortableInit = sortable.withArgs row.mixinOptions.muTableColumnOrder
        sortableRefresh = sortable.withArgs 'refresh'
        sortableDestroy = sortable.withArgs 'destroy'

      afterEach ->
        row.dispose()
        sortable.restore()

      it 'should throw if mixed into an object that fails to implement Row.ViewMixin', ->
        expect(-> Oraculum.get('View').__mixin 'muTableColumnOrder.RowMixin').toThrow()

      it 'should throw if a cell is rendered that fails to implement Cell.ViewMixin', ->
        row.mixinOptions.list.modelView = 'View'
        expect(-> row.render()).toThrow()

      it 'should apply muTableColumnOrder.CellMixin to all cells', ->
        row.render()
        _.each row.getModelViews(), (cell) ->
          expect(cell).toUseMixin 'muTableColumnOrder.CellMixin'

      it 'should initialize the jQuery UI sortable plugin in the target row element only once', ->
        expect(sortable).not.toHaveBeenCalled()
        row.render()
        expect(sortableInit).toHaveBeenCalledOnce()
        row.render()
        expect(sortableInit).toHaveBeenCalledOnce()

      it 'should refresh the jQuery UI sortable plugin on all `visibilityChange` events', ->
        expect(sortable).not.toHaveBeenCalled()
        row.render()
        expect(sortableRefresh).toHaveBeenCalled()
        expect(sortableRefresh).toHaveBeenCalledAfter sortableInit
        sortableRefresh.reset()
        row.render()
        expect(sortableRefresh).toHaveBeenCalled()

      it 'should update the comparator on the target collection post sort', ->
        # Emulate a dom-level sorting event
        [attrCellView, nameCellView] = row.render()._subviews
        nameCellView.$el.insertBefore attrCellView.el
        attrColumnIndex = columns.indexOf attrColumn
        nameColumnIndex = columns.indexOf nameColumn
        expect(attrColumnIndex < nameColumnIndex).toBe true
        row.$el.trigger 'sortupdate'
        attrColumnIndex = columns.indexOf attrColumn
        nameColumnIndex = columns.indexOf nameColumn
        expect(attrColumnIndex < nameColumnIndex).toBe false

      it 'should destroy the sortable plugin when the row is disposed', ->
        expect(sortableDestroy).not.toHaveBeenCalled()
        row.render()
        expect(sortableDestroy).not.toHaveBeenCalled()
        row.dispose()
        expect(sortableDestroy).toHaveBeenCalledOnce()

    describe 'muTableColumnOrder.TableMixin', ->

      beforeEach ->
        table = Oraculum.get 'muTableColumnOrder.TableMixin.Test.View', {
          columns, collection
        }

      afterEach ->
        table.dispose()

      it 'should throw if mixed into an object that fails to implement Table.ViewMixin', ->
        expect(-> Oraculum.get('View').__mixin 'muTableColumnOrder.TableMixin').toThrow()

      it 'should throw if a row is rendered that fails to implement Row.ViewMixin', ->
        table.mixinOptions.list.modelView = 'View'
        expect(-> table.render()).toThrow()

      it 'should apply muTableColumnOrder.RowMixin to all rows', ->
        table.render()
        _.each table.getModelViews(), (row) ->
          expect(row).toUseMixin 'muTableColumnOrder.RowMixin'
