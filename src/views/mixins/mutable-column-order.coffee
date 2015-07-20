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
  composeConfig = Oraculum.get 'composeConfig'
  resolveViewTarget = Oraculum.get 'resolveViewTarget'

  # List of events extracted from http://api.jqueryui.com/sortable/
  SORT_EVENTS = [
    'sortactivate', 'sortdeactivate'
    'sortstart','sortbeforeStop','sortstop'
    'sortcreate','sortremove','sortchange','sortupdate','sort'
    'sortout','sortover','sortreceive'
  ]

  Oraculum.defineMixin 'muTableColumnOrder.CellMixin', {

    mixinOptions:
      staticClasses: ['mutable-column-order-cell-mixin']

    mixinitialize: ->
      column = @_resolveCellColumn()
      @listenTo column, 'change:attribute', => @_updateColumnAttribute()
      @listenTo column, 'change:orderable', => @_updateColumnOrderable()
      @_updateMutableColumnOrderAttributes()

    _updateMutableColumnOrderAttributes: ->
      @_updateColumnAttribute()
      @_updateColumnOrderable()

    _updateColumnAttribute: ->
      column = @_resolveCellColumn()
      @$el.attr 'data-column-attr', column.get 'attribute'

    _updateColumnOrderable: ->
      column = @_resolveCellColumn()
      @$el.toggleClass 'unorderable-cell', not Boolean column.get 'orderable'

    _resolveCellColumn: ->
      cellOptions = @mixinOptions.cell
      cellOptions = cellOptions.call this if _.isFunction cellOptions
      return cellOptions.column

  }, mixins: [
    'StaticClasses.ViewMixin'
    'Cell.ViewMixin'
  ]

  Oraculum.defineMixin 'muTableColumnOrder.RowMixin', {

    mixinOptions:
      staticClasses: ['mutable-column-order-row-mixin']
      eventedMethods: initModelView: {} # Default config
      muTableColumnOrder:
        target: null # Defaults to this.$el
        # All configuration under this line are options from jQueryUI Sortable.
        # @see: http://api.jqueryui.com/sortable/
        axis: 'x'
        items: '> .cell'
        cursor: 'move'
        helper: 'clone'
        cancel: '.unorderable-cell'
        placeholder: 'sortable-placeholder'

    mixconfig: (mixinOptions, {muTableColumnOrder} = {}) ->
      mixinOptions.muTableColumnOrder = composeConfig mixinOptions.muTableColumnOrder, muTableColumnOrder

    mixinitialize: ->
      # On the initial visibilityChage event, initialize the plugin.
      @once 'visibilityChange', => @_initSortable arguments...
      # On every visibility change, refresh the plugin.
      @on 'visibilityChange', => @_refreshSortable arguments...
      # Ensure that the plugin gets disposed for memory management.
      @on 'dispose:before', => @_destroySortable arguments...
      # Handle sort events.
      @on 'sortupdate', => @_handleSortableUpdate arguments...

    # List.ViewMixin API
    initModelView: (model) ->
      view = @resolveModelView model
      viewOptions = @resolveViewOptions model
      modelView = @createView { view, viewOptions }
      throw new TypeError """
        #{view} fails to implement muTableColumnOrder.CellMixin
      """ unless 'muTableColumnOrder.CellMixin' in modelView.__mixins()
      return modelView

    # Interface
    getSortableAttributeOrder: ->
      $target = @_resolveSortableTarget()
      return $target.sortable 'toArray', attribute: 'data-column-attr'

    # Implementation
    _initSortable: ->
      options = @mixinOptions.muTableColumnOrder
      options = options.call this if _.isFunction options
      $target = @_resolveSortableTarget()
      $target.sortable options
      _.each SORT_EVENTS, (sortEvent) => $target.on sortEvent, =>
        console.log sortEvent
        @trigger sortEvent, arguments...

    _refreshSortable: ->
      $target = @_resolveSortableTarget()
      $target.sortable 'refresh'

    _destroySortable: ->
      $target = @_resolveSortableTarget()
      $target.sortable 'destroy'

    _resolveSortableTarget: ->
      options = @mixinOptions.muTableColumnOrder
      options = options.call this if _.isFunction options
      $target = resolveViewTarget this, options.target

    _handleSortableUpdate: ->
      nwo = @getSortableAttributeOrder()
      @collection.comparator = (model) ->
        index = nwo.indexOf model.get 'attribute'
        return if index > -1 then index else @length
      @collection.sort()

  }, mixins: [
    'Row.ViewMixin'
    'StaticClasses.ViewMixin'
  ]
