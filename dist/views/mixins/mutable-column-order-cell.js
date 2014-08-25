(function() {
  define(['oraculum', 'muTable/libs', 'oraculum/libs', 'oraculum/mixins/evented-method', 'oraculum/views/mixins/static-classes'], function(Oraculum) {
    'use strict';
    var interact, _;
    _ = Oraculum.get('underscore');
    interact = Oraculum.get('interact');
    return Oraculum.defineMixin('muTableColumnOrder.CellMixin', {
      mixinOptions: {
        eventedMethods: {
          render: {}
        }
      },
      mixinitialize: function() {
        return this.on('render:after', (function(_this) {
          return function() {
            return _this._interact();
          };
        })(this));
      },
      _interact: function() {
        var interactable;
        interactable = interact(this.el);
        interactable.origin(this.el);
        return interactable.draggable({
          onmove: _.debounce((function(_this) {
            return function() {
              return _this._onmove.apply(_this, arguments);
            };
          })(this)),
          axis: 'x'
        });
      },
      _onmove: function(_arg) {
        var columns, dx, indexOffset, newIndex, newModels, pageX, thisIndex;
        pageX = _arg.pageX, dx = _arg.dx;
        if (!(pageX < 0 || pageX > this.$el.outerWidth())) {
          return;
        }
        columns = this.column.collection;
        thisIndex = columns.indexOf(this.column);
        indexOffset = pageX < 0 ? -1 : 1;
        newIndex = thisIndex + indexOffset;
        if (newIndex < 0) {
          return;
        }
        if (indexOffset <= 0 && dx >= 0) {
          return;
        }
        if (indexOffset >= 0 && dx <= 0) {
          return;
        }
        newModels = columns.models.slice();
        newModels.splice(thisIndex, 1);
        newModels.splice(newIndex, 0, this.column);
        return columns.reset(newModels, {
          merge: true
        });
      }
    }, {
      mixins: ['EventedMethod.Mixin', 'StaticClasses.ViewMixin']
    });
  });

}).call(this);
