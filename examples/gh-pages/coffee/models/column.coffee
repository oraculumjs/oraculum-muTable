define [
  'oraculum'
  'oraculum/plugins/tabular/models/mixins/sortable-column'
], (Oraculum) ->
  'use strict'

  Oraculum.extend 'Model', 'Column', {
  }, mixins: ['SortableColumn.ModelMixin']

  Oraculum.extend 'Collection', 'Columns', {
    model: 'Column'
  }, singleton: true
