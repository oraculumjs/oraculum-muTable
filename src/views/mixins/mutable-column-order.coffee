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

  # List of events extracted from http://api.jqueryui.com/sortable/
  SORT_EVENTS = [
    'sortactivate', 'sortdeactivate'
    'sortstart','sortbeforeStop','sortstop'
    'sortcreate','sortremove','sortchange','sortupdate','sort'
    'sortout','sortover','sortreceive'
  ]

  Oraculum.defineMixin 'muTableColumnOrder.CellMixin', {

    mixinitialize: ->
      @listenTo @column, 'change:orderable', => @_updateColumnOrderable()
      @_updateColumnOrderable()

    _updateColumnOrderable: ->
      @$el.toggleClass 'unorderable-cell', not Boolean @column.get 'orderable'

  }

  Oraculum.defineMixin 'muTableColumnOrder.RowMixin', {

    mixinOptions:
      muTableColumnOrder:
        target: null # Defaults to this.$el
        # All configuration under this line are options from jQueryUI Sortable.
        # @see: http://api.jqueryui.com/sortable/
        axis: 'x'
        items: '> .cell_view-mixin'
        cursor: 'move'
        helper: 'clone'
        cancel: '.unorderable-cell'
        placeholder: 'sortable-placeholder'

    mixconfig: (mixinOptions, {muTableColumnOrder} = {}) ->
      mixinOptions.muTableColumnOrder = Oraculum.composeConfig(
        mixinOptions.muTableColumnOrder, muTableColumnOrder
      )

    mixinitialize: ->
      @_ensureSortableColumnCells()
      # If we're late-bound, initilize the plugin
      @_initSortablePlugin() if @getModelViews().length > 0
      # Make sure we initialize the plugin post-render if we're not late-bound
      @once 'visibilityChange', => @_initSortablePlugin arguments...
      # On visibility change, ensure our cells are sortable & refresh the plugin
      @on 'visibilityChange', => @_refreshSortablePlugin arguments...
      # Ensure that the plugin gets disposed for memory management.
      @on 'dispose:before', => @_destroySortablePlugin arguments...
      # Handle sort events.
      @on 'sortupdate', => @_handleSortableUpdate arguments...

    _ensureSortableColumnCells: ->
      _.each @getModelViews(), (view) ->
        view.__mixin 'muTableColumnOrder.CellMixin'

    # Interface
    getSortableAttributeOrder: ->
      return unless @_sortablePluginInitialized
      return @_resolveSortableTarget().sortable 'toArray',
        attribute: 'data-column-attr'

    # Implementation
    _initSortablePlugin: ->
      return if @_sortablePluginInitialized
      options = @mixinOptions.muTableColumnOrder
      options = options.call this if _.isFunction options
      $target = @_resolveSortableTarget()
      $target.sortable options
      _.each SORT_EVENTS, (sortEvent) =>
        $target.on sortEvent, =>
          @trigger sortEvent, arguments...
      @_sortablePluginInitialized = true

    _refreshSortablePlugin: ->
      @_ensureSortableColumnCells()
      return unless @_sortablePluginInitialized
      @_resolveSortableTarget().sortable 'refresh'

    _destroySortablePlugin: ->
      return unless @_sortablePluginInitialized
      @_resolveSortableTarget().sortable 'destroy'
      @_sortablePluginInitialized = false

    _resolveSortableTarget: ->
      options = @mixinOptions.muTableColumnOrder
      options = options.call this if _.isFunction options
      return Oraculum.resolveViewTarget this, options.target

    _handleSortableUpdate: ->
      nwo = @getSortableAttributeOrder()
      @collection.models = @collection.sortBy (model) =>
        index = nwo.indexOf model.get 'attribute'
        return if index > -1 then index else @collection.length
      @collection.trigger 'sort', @collection, {}

  }

  Oraculum.defineMixin 'muTableColumnOrder.TableMixin', {

    mixinitialize: ->
      @on 'visibilityChange', => @_ensureSortableColumnRows()
      @_ensureSortableColumnRows()

    _ensureSortableColumnRows: ->
      _.each @getModelViews(), (view) ->
        view.__mixin 'muTableColumnOrder.RowMixin'

  }
