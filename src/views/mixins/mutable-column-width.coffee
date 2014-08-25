define [
  'oraculum'
  'muTable/libs'

  'oraculum/mixins/listener'
  'oraculum/mixins/disposable'
  'oraculum/mixins/evented-method'

  'oraculum/views/mixins/attach'
  'oraculum/views/mixins/subview'
  'oraculum/views/mixins/auto-render'
  'oraculum/views/mixins/static-classes'
  'oraculum/plugins/tabular/views/mixins/row'
  'oraculum/plugins/tabular/views/mixins/cell'
  'oraculum/plugins/tabular/views/mixins/table'
], (Oraculum) ->
  'use strict'

  interact = Oraculum.get 'interact'

  Oraculum.extend 'View', '_MutableColumnWidthHandle.View', {

    mixinOptions:
      staticClasses: ['muTable-column-width-handle-view']
      eventedMethods:
        render: {}
      listen:
        'render:after this': '_update'
        'change:handleWidth model': '_updateWidth'
        'change:handleWidth change:handleLeft model': '_updateOffset'

    _update: ->
      @_updateWidth()
      @_updateOffset()
      @_interact()

    _updateWidth: ->
      handleWidth = @model.get 'handleWidth'
      @$el.css width: handleWidth

    _updateOffset: ->
      handleLeft = @model.get 'handleLeft'
      handleWidth = @model.get 'handleWidth'
      @$el.css left: handleLeft - (handleWidth / 2)

    _interact: ->
      interactable = interact @el
      interactable.origin @el
      interactable.draggable
        onmove: => @_onmove arguments...
        axis: 'x'

    _onmove: ({pageX}) ->
      columns = @column.collection
      thisWidth = @column.get 'width'
      thisIndex = columns.indexOf @column
      handleLeft = @column.get 'handleLeft'
      prevColumn = columns.at thisIndex - 1
      prevWidth = prevColumn.get 'width'
      prevColumn.set width: prevWidth + pageX
      @column.set
        width: thisWidth - pageX
        handleLeft: handleLeft + pageX

  }, mixins: [
    'Listener.Mixin'
    'Disposable.Mixin'
    'EventedMethod.Mixin'
    'Cell.ViewMixin'
    'StaticClasses.ViewMixin'
  ]

  Oraculum.extend 'View', '_MutableColumnWidthHandles.View', {
    tagName: 'aside'

    mixinOptions:
      staticClasses: ['muTable-column-width-handles-view']
      list: modelView: '_MutableColumnWidthHandle.View'

  }, mixins: [
    'Disposable.Mixin'
    'Row.ViewMixin'
    'Attach.ViewMixin'
    'StaticClasses.ViewMixin'
    'AutoRender.ViewMixin'
  ]

  Oraculum.defineMixin 'muTableColumnWidth.TableMixin', {

    mixinOptions:
      staticClasses: ['muTable-column-width-table-mixin']
      muTableColumnWidth:
        handleWidth: 4
        widthFunction: 'outerWidth'
      subviews:
        muTableHandles: ->
          view: '_MutableColumnWidthHandles.View'
          viewOptions:
            container: @el
            collection: @columns

    mixconfig: ({muTableColumnWidth}, {handleWidth, widthFunction} = {}) ->
      muTableColumnWidth.handleWidth = handleWidth if handleWidth?
      muTableColumnWidth.widthFunction = widthFunction if widthFunction?

    mixinitialize: ->
      debouncedUpdate = _.debounce (=> @_updateOffsets()), 10
      @on 'visibilityChange', debouncedUpdate
      $(window, document).resize debouncedUpdate
      @listenTo @columns, 'add remove reset sort', debouncedUpdate
      @listenTo @columns, 'change:width change:handleLeft', debouncedUpdate

    _updateOffsets: ->
      return unless firstVisibleRow = _.find @getModelViews(), (view) ->
        return view.$el.is ':visible'
      handleWidth = @mixinOptions.muTableColumnWidth.handleWidth
      widthFunction = @mixinOptions.muTableColumnWidth.widthFunction
      _.each firstVisibleRow.getModelViews(), (view) ->
        width = if _.isString widthFunction
        then view.$el[widthFunction]()
        else widthFunction.call view
        handleLeft = view.$el.position().left
        view.column.set {width, handleLeft, handleWidth}

  }, mixins: [
    'Disposable.Mixin'
    'Table.ViewMixin'
    'Subview.ViewMixin'
    'StaticClasses.ViewMixin'
  ]
