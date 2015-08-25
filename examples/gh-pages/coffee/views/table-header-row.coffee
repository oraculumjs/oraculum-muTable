define [
  'oraculum'

  'oraculum/views/mixins/attach'
  'oraculum/views/mixins/auto-render'
  'oraculum/views/mixins/static-classes'

  'oraculum/plugins/tabular/views/mixins/row'
  'oraculum/plugins/tabular/views/cells/header'
  'oraculum/plugins/tabular/views/mixins/variable-width-cell'

  'muTable/views/mixins/mutable-column-order'
], (Oraculum) ->
  'use strict'

  # Create a header row/cells that can be drag-sorted
  Oraculum.extend 'Header.Cell', 'SortableColumnHeader.Cell', {
    tagName: 'th'
  }, {
    inheritMixins: true
    mixins: ['VariableWidth.CellMixin']
  }

  Oraculum.extend 'View', 'SortableColumnHeader.Row', {
    tagName: 'tr'

    mixinOptions:
      list:
        modelView: 'SortableColumnHeader.Cell'

  }, mixins: [
    'Row.ViewMixin'
    'Attach.ViewMixin'
    'StaticClasses.ViewMixin'
    'muTableColumnOrder.RowMixin'
    'AutoRender.ViewMixin'
  ]
