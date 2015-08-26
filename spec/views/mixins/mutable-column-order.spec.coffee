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

    Oraculum.extend 'View', 'jQueryUISortable.ViewMixin.Test.View', {
      mixinOptions: jQueryUISortable: '': {}
    }, mixins: [
      'Disposable.Mixin'
      'jQueryUISortable.ViewMixin'
    ]

    Oraculum.extend 'View', 'muTableColumnOrder.CellMixin.Test.View', {
    }, mixins: [
      'Disposable.Mixin'
      'Cell.ViewMixin'
      'muTableColumnOrder.CellMixin'
    ]

    Oraculum.extend 'View', 'muTableColumnOrder.RowMixin.Test.View', {
      mixinOptions:
        list: modelView: 'Text.Cell'
        muTableColumnOrder: rowSelector: null
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
      mixinOptions:
        list: modelView: 'muTableColumnOrder.RowMixin.Test1.View'
        muTableColumnOrder: rowSelector: '.row_view-mixin'
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

    describe 'jQueryUISortable.ViewMixin', ->

      view = undefined
      sortable = undefined
      sortableRefresh = undefined

      beforeEach ->
        sortable = sinon.stub $.fn, 'sortable'
        sortableRefresh = sortable.withArgs 'refresh'
        view = Oraculum.get 'jQueryUISortable.ViewMixin.Test.View'

      afterEach ->
        view.dispose()
        sortable.restore()

      it 'should debounce initialize the plugin automatically', (done) ->
        expect(sortable).not.toHaveBeenCalled()
        setTimeout (-> done expect(sortable).toHaveBeenCalledOnce()), 110

      it 'should debounce re-initialize the plugin on subviewCreated events', (done) ->
        expect(sortable).not.toHaveBeenCalled()
        view.trigger 'subviewCreated' # Multiple invocations to testing debounced behavior
        view.trigger 'subviewCreated' # Multiple invocations to testing debounced behavior
        view.trigger 'subviewCreated' # Multiple invocations to testing debounced behavior
        setTimeout (-> done expect(sortable).toHaveBeenCalledOnce()), 110

      it 'should debounce re-initialize the plugin on visibilityChange events', (done) ->
        expect(sortable).not.toHaveBeenCalled()
        view.trigger 'visibilityChange' # Multiple invocations to testing debounced behavior
        view.trigger 'visibilityChange' # Multiple invocations to testing debounced behavior
        view.trigger 'visibilityChange' # Multiple invocations to testing debounced behavior
        setTimeout (-> done expect(sortable).toHaveBeenCalledOnce()), 110

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

      beforeEach ->
        row = Oraculum.get 'muTableColumnOrder.RowMixin.Test.View', {
          model
          modelView: 'Text.Cell'
          collection: columns
        }

      afterEach ->
        row.dispose()

      it 'should apply muTableColumnOrder.CellMixin to all cells', (done) ->
        row.render()
        setTimeout (-> done _.each row.getModelViews(), (cell) ->
          expect(cell).toUseMixin 'muTableColumnOrder.CellMixin'
        ), 110

      it 'should provide an interface to serialize the current sort order from the dom', (done) ->
        [attrCellView, nameCellView] = row.render().getModelViews()
        setTimeout (-> # Give the debounced plugin initializer an opportunity to execute.
          expect(row.getSortableAttributeOrder()).toEqual ['attribute', 'name']
          nameCellView.$el.insertBefore attrCellView.el
          expect(row.getSortableAttributeOrder()).toEqual ['name', 'attribute']
          done()
        ), 110

      it 'should update the sort order on the target collection post-sort', (done) ->
        # Emulate a dom-level sorting event
        [attrCellView, nameCellView] = row.render().getModelViews()
        setTimeout (-> # Give the debounced plugin initializer an opportunity to execute.
          nameCellView.$el.insertBefore attrCellView.el
          attrColumnIndex = columns.indexOf attrColumn
          nameColumnIndex = columns.indexOf nameColumn
          expect(attrColumnIndex < nameColumnIndex).toBe true
          row.$el.trigger 'sortupdate'
          attrColumnIndex = columns.indexOf attrColumn
          nameColumnIndex = columns.indexOf nameColumn
          expect(attrColumnIndex < nameColumnIndex).toBe false
          done()
        ), 110

    describe 'muTableColumnOrder.TableMixin', ->

      beforeEach ->
        table = Oraculum.get 'muTableColumnOrder.TableMixin.Test.View', {
          columns, collection
        }

      afterEach ->
        table.dispose()

      it 'should apply muTableColumnOrder.RowMixin to all rows', (done) ->
        table.render()
        setTimeout (-> done _.each table.getModelViews(), (row) ->
          expect(row).toUseMixin 'muTableColumnOrder.RowMixin'
        ), 110

