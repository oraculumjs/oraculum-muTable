define [
  'oraculum'
  'oraculum/views/mixins/attach'
  'oraculum/views/mixins/auto-render'
  'oraculum/plugins/tabular/views/mixins/row'
  'oraculum/plugins/tabular/views/cells/header'
  'muTable/views/mixins/mutable-column-order'
], (Oraculum) ->
  'use strict'

  # Create a header row/cells that can be drag-sorted
  Oraculum.extend 'Header.Cell', 'SortableColumnHeader.Cell', {
    tagName: 'th'
  }, {
    inheritMixins: true
    mixins: ['muTableColumnOrder.CellMixin']
  }

  Oraculum.extend 'View', 'SortableColumnHeader.Row', {
    tagName: 'tr'
    mixinOptions:
      list:
        modelView: 'SortableColumnHeader.Cell'
  }, mixins: [
    'Row.ViewMixin'
    'muTableColumnOrder.RowMixin'
    'Attach.ViewMixin'
    'AutoRender.ViewMixin'
  ]
