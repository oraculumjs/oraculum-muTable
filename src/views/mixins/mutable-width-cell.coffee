define [
  'oraculum'
  'oraculum/views/mixins/static-classes'
], (Oraculum) ->
  'use strict'

  ###
  muTableWidth.CellMixin
  ======================
  This mixin enhances Cell.ViewMixin to provide variable width
  behavior on a cell based on its column's width attribute.
  ###

  Oraculum.defineMixin 'muTableWidth.CellMixin', {

    mixinOptions:
      staticClasses: ['muTable-width-cell-mixin']

    mixinitialize: ->
      @listenTo @column, 'change:width', @_updateWidth
      @_updateWidth()

    _updateWidth: ->
      return unless (width = @column.get 'width')?
      @$el.css {width}

  }, mixins: ['StaticClasses.ViewMixin']
