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
      mixconfig: function(_arg, _arg1) {
        var handleWidth, muTableColumnWidth, widthFunction, _ref;
        muTableColumnWidth = _arg.muTableColumnWidth;
        _ref = _arg1 != null ? _arg1 : {}, handleWidth = _ref.handleWidth, widthFunction = _ref.widthFunction;
        if (handleWidth != null) {
          muTableColumnWidth.handleWidth = handleWidth;
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
        var firstVisibleRow, handleWidth, widthFunction;
        if (!(firstVisibleRow = _.find(this.getModelViews(), function(view) {
          return view.$el.is(':visible');
        }))) {
          return;
        }
        handleWidth = this.mixinOptions.muTableColumnWidth.handleWidth;
        widthFunction = this.mixinOptions.muTableColumnWidth.widthFunction;
        return _.each(firstVisibleRow.getModelViews(), function(view) {
          var handleLeft, width;
          width = _.isString(widthFunction) ? view.$el[widthFunction]() : widthFunction.call(view);
          handleLeft = view.$el.position().left;
          return view.column.set({
            width: width,
            handleLeft: handleLeft,
            handleWidth: handleWidth
          });
        });
      }
    }, {
      mixins: ['Disposable.Mixin', 'Table.ViewMixin', 'Subview.ViewMixin', 'StaticClasses.ViewMixin']
    });
  });

}).call(this);
