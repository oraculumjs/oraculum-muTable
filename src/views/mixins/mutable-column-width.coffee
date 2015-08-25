define [
  'oraculum'
  'oraculum/libs'

  'oraculum/plugins/tabular/views/mixins/variable-width-cell'

  'jquery-ui/resizable'
], (Oraculum) ->
  'use strict'

  _ = Oraculum.get 'underscore'

  # Extracted from http://api.jqueryui.com/resizable/
  RESIZE_EVENTS = [
    'resize'
    'resizestop'
    'resizestart'
    'resizecreate'
  ]

  # This could be broken out as part of an Oraculum-jQueryUI project.
  Oraculum.defineMixin 'jQueryResizable.ViewMixin',

    mixinOptions:
      jQueryResizable: {}
        # '.selector': {
        #   # All configuration following selector are from jQueryUI Resizable.
        #   # @see: http://api.jqueryui.com/resizable/
        # }

    mixconfig: (mixinOptions, {jQueryResizable} = {}) ->
      mixinOptions.jQueryResizable = Oraculum.composeConfig(
        mixinOptions.jQueryResizable, jQueryResizable
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
      options = @mixinOptions.jQueryResizable
      options = options.call this if _.isFunction options
      # Iterate over our selectors, configs
      _.each options, (options, selector) =>
        options = options.call this if _.isFunction options
        $target = Oraculum.resolveViewTarget this, selector or null
        $target.resizable options # Init the plugin

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
      resizableOptions: {} # jQuery UI resizable options

  # The mixconfig for the following mixins are contextual configurations
  # for using jQueryResizable.ViewMixin with the Oraculum 'Tabular' subsystem.
  mixconfig = (mixinOptions, options = {}) ->
    {muTableColumnWidthCellSelector, muTableColumnWidthResizableOptions} = options
    cellSelector = muTableColumnWidthCellSelector or mixinOptions.muTableColumnWidth.cellSelector
    resizableOptions = Oraculum.composeConfig mixinOptions.muTableColumnWidth.resizableOptions, muTableColumnWidthResizableOptions
    (jQueryResizableSpec = {})[cellSelector] = resizableOptions if cellSelector?
    mixinOptions.jQueryResizable = Oraculum.composeConfig mixinOptions.jQueryResizable, jQueryResizableSpec

  Oraculum.defineMixin 'muTableColumnWidth.RowMixin', {

    mixinOptions, mixconfig

    mixinitialize: ->
      @_ensureResizableColumnCells()
      @on 'visibilityChange', =>
        @_ensureResizableColumnCells arguments...

    _ensureResizableColumnCells: ->
      _.each @getModelViews(), (view) ->
        view.__mixin 'muTableColumnWidth.CellMixin', {}

  }, mixins: ['jQueryResizable.ViewMixin']

  Oraculum.defineMixin 'muTableColumnWidth.TableMixin', {

    mixinOptions, mixconfig

    mixinitialize: ->
      @_ensureResizableColumnRows()
      @on 'visibilityChange', =>
        @_ensureResizableColumnRows arguments...

    _ensureResizableColumnRows: ->
      _.each @getModelViews(), (view) ->
        view.__mixin 'muTableColumnWidth.RowMixin', {}

  }, mixins: ['jQueryResizable.ViewMixin']
