define [
  'oraculum'
  'oraculum/plugins/tabular/views/mixins/variable-width-cell'
  'jquery-ui/resizable'
], (Oraculum) ->
  'use strict'

  # Extracted from http://api.jqueryui.com/resizable/
  RESIZE_EVENTS = [
    'resize'
    'resizestop'
    'resizestart'
    'resizecreate'
  ]

  Oraculum.defineMixin 'muTableColumnWidth.CellMixin', {

    mixinOptions:
      muTableColumnWidth:
        target: null # # Defaults to this.$el
        # All configuration under this line are options from jQueryUI Resizable.
        # @see: http://api.jqueryui.com/resizable/
        handles: 'e'
        minWidth: 100
        containment: 'parent'

    mixconfig: (mixinOptions, {muTableColumnWidth} = {}) ->
      mixinOptions.muTableColumnWidth = Oraculum.composeConfig(
        mixinOptions.muTableColumnWidth, muTableColumnWidth
      )

    mixinitialize: ->
      # Ensure our interface is respected.
      throw new TypeError '''
        muTableColumnWidth.CellMixin must be used with Cell.ViewMixin.
      ''' unless 'Cell.ViewMixin' in @__activeMixins()
      # Initialize immediately if we're attached to a node
      @_initializeResizablePlugin() if @$el.parent().length > 0
      # Else, wait for an event that denotes we've been attached
      @on 'addedToParent', => @_initializeResizablePlugin arguments...
      # Ensure that the plugin gets disposed for memory management.
      @on 'dispose', => @_destroyResizablePlugin arguments...
      # Update the column model's width attribute on resize
      @on 'resize', (e, {size:{width}}) => @column.set { width }
      # Ensure that we update the plugin if the column changes
      @listenTo @column, 'change:resizable', => @_updateResizableEnabled()

    _initializeResizablePlugin: ->
      return if @_resizablePluginInitialized
      @_resizablePluginInitialized = true
      options = @mixinOptions.muTableColumnWidth
      options = options.call this if _.isFunction options
      $target = @_resolveResizableTarget()
      $target.resizable options
      _.each RESIZE_EVENTS, (resizeEvent) =>
        $target.on resizeEvent, =>
          @trigger resizeEvent, arguments...
      @_updateResizableEnabled()

    _updateResizableEnabled: ->
      return unless @_resizablePluginInitialized
      enabled = Boolean @column.get 'resizable'
      options = @mixinOptions.muTableColumnWidth
      options = options.call this if _.isFunction options
      $target = @_resolveResizableTarget()
      $target.find('.ui-resizable-handle').toggle enabled
      $target.resizable 'option', 'disabled', not enabled

    _destroyResizablePlugin: ->
      return unless @_resizablePluginInitialized
      @_resolveResizableTarget().resizable 'destroy'
      @_resizablePluginInitialized = false

    _resolveResizableTarget: ->
      options = @mixinOptions.muTableColumnWidth
      options = options.call this if _.isFunction options
      return Oraculum.resolveViewTarget this, options.target

  }, mixins: ['VariableWidth.CellMixin']

  Oraculum.defineMixin 'muTableColumnWidth.RowMixin', {

    mixinitialize: ->
      # Ensure our interface is respected.
      throw new TypeError '''
        muTableColumnWidth.RowMixin must be used with Row.ViewMixin.
      ''' unless 'Row.ViewMixin' in @__activeMixins()
      @_ensureResizableColumnCells()
      @on 'visibilityChange', =>
        @_ensureResizableColumnCells arguments...

    _ensureResizableColumnCells: ->
      _.each @getModelViews(), (view) ->
        view.__mixin 'muTableColumnWidth.CellMixin', {}

  }

  Oraculum.defineMixin 'muTableColumnWidth.TableMixin', {

    mixinitialize: ->
      # Ensure our interface is respected.
      throw new TypeError '''
        muTableColumnWidth.TableMixin must be used with Table.ViewMixin.
      ''' unless 'Table.ViewMixin' in @__activeMixins()
      @_ensureResizableColumnRows()
      @on 'visibilityChange', =>
        @_ensureResizableColumnRows arguments...

    _ensureResizableColumnRows: ->
      _.each @getModelViews(), (view) ->
        view.__mixin 'muTableColumnWidth.RowMixin', {}

  }
