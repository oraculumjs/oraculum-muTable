define [
  'oraculum'
  'oraculum/libs'

  'oraculum/plugins/tabular/views/mixins/variable-width-cell'

  'jquery-ui/resizable'
], (Oraculum) ->
  'use strict'

  _ = Oraculum.get 'underscore'

  # This could be broken out as part of an Oraculum-jQueryUI project.
  Oraculum.defineMixin 'jQueryUIResizable.ViewMixin',

    mixinOptions:
      jQueryUIResizable: {}
        # '.selector': {
        #   # All configuration following selector are from jQueryUI Resizable.
        #   # @see: http://api.jqueryui.com/resizable/
        # }

    mixconfig: (mixinOptions, {jQueryUIResizable} = {}) ->
      mixinOptions.jQueryUIResizable = Oraculum.composeConfig(
        mixinOptions.jQueryUIResizable, jQueryUIResizable
      )

    mixinitialize: ->
      # Debounce our initialize method to prevent flooding the plugin
      # Check if we're disposed, since we're no longer on a synchronous call stack.
      initializeResizablePlugin = _.debounce (=>
        @_initializeResizablePlugin() unless @disposed
      ), 100
      # Reinitialize on subviewCreated for Subview.ViewMixin
      @on 'subviewCreated', initializeResizablePlugin
      # Reinitialize on visibilityChange for List.ViewMixin
      @on 'visibilityChange', initializeResizablePlugin
      # Initialize immediately
      initializeResizablePlugin()

    _initializeResizablePlugin: ->
      options = @mixinOptions.jQueryUIResizable
      options = options.call this if _.isFunction options
      # Iterate over our selectors, configs
      _.each options, (options, selector) =>
        selector = null if selector is '' # De-normalize for null selector.
        options = options.call this if _.isFunction options
        $target = Oraculum.resolveViewTarget this, selector
        $target.resizable options unless $target.data('resizable')?

  Oraculum.defineMixin 'muTableColumnWidth.CellMixin', {

    mixinitialize: ->
      # Update the column model's width attribute on resize
      @$el.on 'resize', (e, {size:{width}}) => @column.set { width }
      # Ensure that we update the plugin if the column changes
      @listenTo @column, 'change:resizable', =>
        @$el.resizable 'option', 'disabled', not @column.get 'resizable'

  }, mixins: ['VariableWidth.CellMixin']

  # These mixins use iterators with List.ViewMixin to enhance incoming views
  # Such that they can support our muTableWidth behaviors.
  mixinOptions =
    muTableColumnWidth:
      cellSelector: undefined # Does nothing it not configured.
      resizableOptions: {
        handles: 'e'
      } # jQuery UI resizable options

  # The mixconfig for the following mixins are contextual configurations
  # for using jQueryUIResizable.ViewMixin with the Oraculum 'Tabular' subsystem.
  mixconfig = (mixinOptions, options = {}) ->
    {muTableColumnWidthCellSelector, muTableColumnWidthResizableOptions} = options
    cellSelector = muTableColumnWidthCellSelector or mixinOptions.muTableColumnWidth.cellSelector
    cellSelector = '' if cellSelector is null # Normalize for 'null' target.
    resizableOptions = Oraculum.composeConfig mixinOptions.muTableColumnWidth.resizableOptions, muTableColumnWidthResizableOptions
    (jQueryUIResizableSpec = {})[cellSelector] = resizableOptions if cellSelector?
    mixinOptions.jQueryUIResizable = Oraculum.composeConfig mixinOptions.jQueryUIResizable, jQueryUIResizableSpec

  Oraculum.defineMixin 'muTableColumnWidth.RowMixin', {

    mixinOptions, mixconfig

    mixinitialize: ->
      ensureResizableColumnCells = _.debounce =>
        @_ensureResizableColumnCells() unless @disposed
      @on 'visibilityChange', ensureResizableColumnCells
      ensureResizableColumnCells()

    _ensureResizableColumnCells: ->
      _.each @getModelViews(), (view) ->
        view.__mixin 'muTableColumnWidth.CellMixin', {}

  }, mixins: ['jQueryUIResizable.ViewMixin']

  Oraculum.defineMixin 'muTableColumnWidth.TableMixin', {

    mixinOptions, mixconfig

    mixinitialize: ->
      ensureResizableColumnRows = _.debounce =>
        @_ensureResizableColumnRows() unless @disposed
      @on 'visibilityChange', ensureResizableColumnRows
      ensureResizableColumnRows()

    _ensureResizableColumnRows: ->
      _.each @getModelViews(), (view) ->
        view.__mixin 'muTableColumnWidth.RowMixin', {}

  }, mixins: ['jQueryUIResizable.ViewMixin']
