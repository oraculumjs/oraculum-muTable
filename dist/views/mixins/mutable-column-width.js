(function() {
  define(['oraculum', 'muTable/libs', 'oraculum/mixins/listener', 'oraculum/mixins/disposable', 'oraculum/mixins/evented-method', 'oraculum/views/mixins/attach', 'oraculum/views/mixins/subview', 'oraculum/views/mixins/auto-render', 'oraculum/views/mixins/static-classes', 'oraculum/plugins/tabular/views/mixins/row', 'oraculum/plugins/tabular/views/mixins/cell', 'oraculum/plugins/tabular/views/mixins/table'], function(Oraculum) {
    'use strict';
    var interact;
    interact = Oraculum.get('interact');
    Oraculum.extend('View', '_MutableColumnWidthHandle.View', {
      mixinOptions: {
        staticClasses: ['muTable-column-width-handle-view'],
        eventedMethods: {
          render: {}
        },
        listen: {
          'render:after this': '_update',
          'change:handleWidth model': '_updateWidth',
          'change:handleWidth change:handleLeft model': '_updateOffset'
        }
      },
      _update: function() {
        this._updateWidth();
        this._updateOffset();
        return this._interact();
      },
      _updateWidth: function() {
        var handleWidth;
        handleWidth = this.model.get('handleWidth');
        return this.$el.css({
          width: handleWidth
        });
      },
      _updateOffset: function() {
        var handleLeft, handleWidth;
        handleLeft = this.model.get('handleLeft');
        handleWidth = this.model.get('handleWidth');
        return this.$el.css({
          left: handleLeft - (handleWidth / 2)
        });
      },
      _interact: function() {
        var interactable;
        interactable = interact(this.el);
        interactable.origin(this.el);
        return interactable.draggable({
          onmove: (function(_this) {
            return function() {
              return _this._onmove.apply(_this, arguments);
            };
          })(this),
          axis: 'x'
        });
      },
      _onmove: function(_arg) {
        var columns, handleLeft, pageX, prevColumn, prevWidth, thisIndex, thisWidth;
        pageX = _arg.pageX;
        columns = this.column.collection;
        thisWidth = this.column.get('width');
        thisIndex = columns.indexOf(this.column);
        handleLeft = this.column.get('handleLeft');
        prevColumn = columns.at(thisIndex - 1);
        prevWidth = prevColumn.get('width');
        prevColumn.set({
          width: prevWidth + pageX
        });
        return this.column.set({
          width: thisWidth - pageX,
          handleLeft: handleLeft + pageX
        });
      }
    }, {
      mixins: ['Listener.Mixin', 'Disposable.Mixin', 'EventedMethod.Mixin', 'Cell.ViewMixin', 'StaticClasses.ViewMixin']
    });
    Oraculum.extend('View', '_MutableColumnWidthHandles.View', {
      tagName: 'aside',
      mixinOptions: {
        staticClasses: ['muTable-column-width-handles-view'],
        list: {
          modelView: '_MutableColumnWidthHandle.View'
        }
      }
    }, {
      mixins: ['Disposable.Mixin', 'Row.ViewMixin', 'Attach.ViewMixin', 'StaticClasses.ViewMixin', 'AutoRender.ViewMixin']
    });
    return Oraculum.defineMixin('muTableColumnWidth.TableMixin', {
      mixinOptions: {
        staticClasses: ['muTable-column-width-table-mixin'],
        muTableColumnWidth: {
          handleWidth: 4,
          cellSelector: null,
          widthFunction: 'outerWidth'
        },
        subviews: {
          muTableHandles: function() {
            return {
              view: '_MutableColumnWidthHandles.View',
              viewOptions: {
                container: this.el,
                collection: this.columns
              }
            };
          }
        }
      },
      mixconfig: function(_arg, options) {
        var cellSelector, handleWidth, muTableColumnWidth, widthFunction;
        muTableColumnWidth = _arg.muTableColumnWidth;
        if (options == null) {
          options = {};
        }
        handleWidth = options.handleWidth, cellSelector = options.cellSelector, widthFunction = options.widthFunction;
        if (handleWidth != null) {
          muTableColumnWidth.handleWidth = handleWidth;
        }
        if (cellSelector != null) {
          muTableColumnWidth.cellSelector = cellSelector;
        }
        if (widthFunction != null) {
          return muTableColumnWidth.widthFunction = widthFunction;
        }
      },
      mixinitialize: function() {
        var debouncedUpdate;
        debouncedUpdate = _.debounce(((function(_this) {
          return function() {
            return _this._updateOffsets();
          };
        })(this)), 10);
        this.on('visibilityChange', debouncedUpdate);
        $(window, document).resize(debouncedUpdate);
        this.listenTo(this.columns, 'add remove reset sort', debouncedUpdate);
        return this.listenTo(this.columns, 'change:width change:handleLeft', debouncedUpdate);
      },
      _updateOffsets: function() {
        var firstVisibleRow;
        if (!(firstVisibleRow = _.find(this.getModelViews(), function(view) {
          return view.$el.is(':visible');
        }))) {
          return;
        }
        if (_.isFunction(firstVisibleRow.getModelViews)) {
          return this._updateViewOffsets(firstVisibleRow);
        } else {
          return this._updateElementOffsets(firstVisibleRow);
        }
      },
      _updateViewOffsets: function(row) {
        return _.each(row.getModelViews(), (function(_this) {
          return function(view) {
            return _this._updateCellOffset(view, view.$el, view.column);
          };
        })(this));
      },
      _updateElementOffsets: function(row) {
        var cellSelector;
        cellSelector = this.mixinOptions.muTableColumnWidth.cellSelector;
        return _.each(row.$(cellSelector), (function(_this) {
          return function(element) {
            var $element, column;
            $element = $(element);
            column = $element.data('column');
            column || (column = element.column);
            return _this._updateCellOffset(null, $element, column);
          };
        })(this));
      },
      _updateCellOffset: function(view, $element, column) {
        var handleLeft, handleWidth, width, widthFunction;
        handleWidth = this.mixinOptions.muTableColumnWidth.handleWidth;
        widthFunction = this.mixinOptions.muTableColumnWidth.widthFunction;
        width = _.isString(widthFunction) ? $element[widthFunction]() : widthFunction.call(view || $element);
        handleLeft = $element.position().left;
        return column.set({
          width: width,
          handleLeft: handleLeft,
          handleWidth: handleWidth
        });
      }
    }, {
      mixins: ['Disposable.Mixin', 'Table.ViewMixin', 'Subview.ViewMixin', 'StaticClasses.ViewMixin']
    });
  });

}).call(this);
