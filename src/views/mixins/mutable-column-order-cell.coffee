define [
  'oraculum'
  'muTable/libs'
  'oraculum/libs'
  'oraculum/mixins/evented-method'
  'oraculum/views/mixins/static-classes'
], (Oraculum) ->
  'use strict'

  _ = Oraculum.get 'underscore'
  interact = Oraculum.get 'interact'

  Oraculum.defineMixin 'muTableColumnOrder.CellMixin', {

    mixinOptions:
      eventedMethods:
        render: {}

    mixinitialize: ->
      @on 'render:after', => @_interact()

    _interact: ->
      interactable = interact @el
      interactable.origin @el
      interactable.draggable
        onmove: _.debounce =>
          @_onmove arguments...
        axis: 'x'

    _onmove: ({pageX, dx}) ->
      return unless pageX < 0 or pageX > @$el.outerWidth()
      columns = @column.collection
      thisIndex = columns.indexOf @column
      indexOffset = if pageX < 0 then -1 else 1
      newIndex = thisIndex + indexOffset
      return if newIndex < 0
      return if indexOffset <= 0 and dx >= 0
      return if indexOffset >= 0 and dx <= 0
      newModels = columns.models.slice()
      newModels.splice thisIndex, 1
      newModels.splice newIndex, 0, @column
      columns.reset newModels, {merge: true}

  }, mixins: [
    'EventedMethod.Mixin'
    'StaticClasses.ViewMixin'
  ]
