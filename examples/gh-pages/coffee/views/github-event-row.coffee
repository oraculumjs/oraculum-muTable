define [
  'oraculum'
  'oraculum/plugins/tabular/views/cells/text'
  'oraculum/plugins/tabular/views/mixins/row'
  'oraculum/plugins/tabular/views/mixins/variable-width-cell'
], (Oraculum) ->
  'use strict'

  # Extend the standard text cell to support width tracking
  Oraculum.extend 'Text.Cell', 'GithubEvent.Cell', {
    tagName: 'td'
  }, {
    inheritMixins: true
    mixins: ['VariableWidth.CellMixin']
  }

  # Extend a view to make it behave like a row
  Oraculum.extend 'View', 'GithubEvent.Row', {
    tagName: 'tr'
    mixinOptions:
      list: modelView: 'GithubEvent.Cell'
  }, mixins: ['Row.ViewMixin']
