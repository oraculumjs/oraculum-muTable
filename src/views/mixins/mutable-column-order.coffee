define [
  'oraculum'
  'oraculum/libs'

  'oraculum/views/mixins/static-classes'
  'oraculum/plugins/tabular/views/mixins/row'
  'oraculum/plugins/tabular/views/mixins/cell'

  'jquery-ui/sortable'
], (Oraculum) ->
  'use strict'

  _ = Oraculum.get 'underscore'

  Oraculum.defineMixin 'jQueryUISortable.ViewMixin',

    mixinOptions:
      jQueryUISortable: {}
        # '.selector': {
        #   # All configuration following selector are from jQueryUI Sortable.
        #   # @see: http://api.jqueryui.com/sortable/
        # }

    mixconfig: (mixinOptions, {jQueryUISortable} = {}) ->
      mixinOptions.jQueryUISortable = Oraculum.composeConfig(
        mixinOptions.jQueryUISortable, jQueryUISortable
      )

    mixinitialize: ->
      # Debounce our initialize method to prevent flooding the plugin
      # Check if we're disposed, since we're no longer on a synchronous call stack.
      initializeSortablePlugin = _.debounce (=>
        @_initializeSortablePlugin() unless @disposed
      ), 100
      # Reinitialize on subviewCreated for Subview.ViewMixin
      @on 'subviewCreated', initializeSortablePlugin
      # Reinitialize on visibilityChange for List.ViewMixin
      @on 'visibilityChange', initializeSortablePlugin
      # Initialize immediately
      initializeSortablePlugin()

    _initializeSortablePlugin: ->
      options = @mixinOptions.jQueryUISortable
      options = options.call this if _.isFunction options
      # Iterate over our selectors, configs
      _.each options, (options, selector) =>
        selector = null if selector is '' # De-normalize for null selector.
        options = options.call this if _.isFunction options
        $target = Oraculum.resolveViewTarget this, selector
        if $target.data('sortable')?
        then $target.sortable 'refresh' # Refresh if it's already initialized.
        else $target.sortable options # Init the plugin.

  Oraculum.defineMixin 'muTableColumnOrder.CellMixin',

    mixinitialize: ->
      @listenTo @column, 'change:orderable', => @_updateColumnOrderable()
      @_updateColumnOrderable()

    _updateColumnOrderable: ->
      @$el.toggleClass 'unorderable-cell', not Boolean @column.get 'orderable'

  # These mixins use iterators with List.ViewMixin to enhance incoming views
  # Such that they can support our muTableWidth behaviors.
  mixinOptions =
    muTableColumnOrder:
      rowSelector: undefined # Does nothing if not configured.
      sortableOptions: {
        axis: 'x'
        items: '.cell_view-mixin'
        cursor: 'move'
        helper: 'clone'
        cancel: '.unorderable-cell'
        placeholder: 'sortable-placeholder'
      } # jQuery UI resizable options

  # The mixconfig for the following mixins are contextual configurations
  # for using jQueryUISortable.ViewMixin with the Oraculum 'Tabular' subsystem.
  mixconfig = (mixinOptions, options = {}) ->
    {muTableColumnOrderCellSelector, muTableColumnOrderSortableOptions} = options
    rowSelector = muTableColumnOrderCellSelector or mixinOptions.muTableColumnOrder.rowSelector
    rowSelector = '' if rowSelector is null # Normalize for 'null' target.
    sortableOptions = Oraculum.composeConfig mixinOptions.muTableColumnOrder.sortableOptions, muTableColumnOrderSortableOptions
    (jQueryUISortableSpec = {})[rowSelector] = sortableOptions if rowSelector?
    mixinOptions.jQueryUISortable = Oraculum.composeConfig mixinOptions.jQueryUISortable, jQueryUISortableSpec

  Oraculum.defineMixin 'muTableColumnOrder.RowMixin', {

    mixinOptions, mixconfig

    mixinitialize: ->
      # Handle sort events.
      @$el.on 'sortupdate', => @_handleSortableUpdate()
      # Ensure all our cells support our interface.
      ensureSortableColumnCells = _.debounce =>
        @_ensureSortableColumnCells() unless @disposed
      @on 'visibilityChange', ensureSortableColumnCells
      ensureSortableColumnCells()

    getSortableAttributeOrder: ->
      return @$el.sortable 'toArray',
        attribute: 'data-column-attr'

    _ensureSortableColumnCells: ->
      _.each @getModelViews(), (view) ->
        view.__mixin 'muTableColumnOrder.CellMixin'

    _handleSortableUpdate: ->
      nwo = @getSortableAttributeOrder()
      @collection.models = @collection.sortBy (model) =>
        index = nwo.indexOf model.get 'attribute'
        return if index > -1 then index else @collection.length
      @collection.trigger 'sort', @collection, {}

  }, mixins: ['jQueryUISortable.ViewMixin']

  Oraculum.defineMixin 'muTableColumnOrder.TableMixin', {

    mixinOptions, mixconfig

    mixinitialize: ->
      ensureSortableColumnRows = _.debounce =>
        @_ensureSortableColumnRows() unless @disposed
      @on 'visibilityChange', ensureSortableColumnRows
      ensureSortableColumnRows()

    _ensureSortableColumnRows: ->
      _.each @getModelViews(), (view) ->
        view.__mixin 'muTableColumnOrder.RowMixin'

  }, mixins: ['jQueryUISortable.ViewMixin']
