(function() {
  var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    slice = [].slice;

  define(['oraculum', 'oraculum/libs', 'oraculum/views/mixins/static-classes', 'oraculum/plugins/tabular/views/mixins/row', 'oraculum/plugins/tabular/views/mixins/cell', 'jquery-ui/sortable'], function(Oraculum) {
    'use strict';
    var SORT_EVENTS, _, composeConfig, resolveViewTarget;
    _ = Oraculum.get('underscore');
    composeConfig = Oraculum.get('composeConfig');
    resolveViewTarget = Oraculum.get('resolveViewTarget');
    SORT_EVENTS = ['sortactivate', 'sortdeactivate', 'sortstart', 'sortbeforeStop', 'sortstop', 'sortcreate', 'sortremove', 'sortchange', 'sortupdate', 'sort', 'sortout', 'sortover', 'sortreceive'];
    Oraculum.defineMixin('muTableColumnOrder.CellMixin', {
      mixinOptions: {
        staticClasses: ['mutable-column-order-cell-mixin']
      },
      mixinitialize: function() {
        var column;
        column = this._resolveCellColumn();
        this.listenTo(column, 'change:attribute', (function(_this) {
          return function() {
            return _this._updateColumnAttribute();
          };
        })(this));
        this.listenTo(column, 'change:orderable', (function(_this) {
          return function() {
            return _this._updateColumnOrderable();
          };
        })(this));
        return this._updateMutableColumnOrderAttributes();
      },
      _updateMutableColumnOrderAttributes: function() {
        this._updateColumnAttribute();
        return this._updateColumnOrderable();
      },
      _updateColumnAttribute: function() {
        var column;
        column = this._resolveCellColumn();
        return this.$el.attr('data-column-attr', column.get('attribute'));
      },
      _updateColumnOrderable: function() {
        var column;
        column = this._resolveCellColumn();
        return this.$el.toggleClass('unorderable-cell', !Boolean(column.get('orderable')));
      },
      _resolveCellColumn: function() {
        var cellOptions;
        cellOptions = this.mixinOptions.cell;
        if (_.isFunction(cellOptions)) {
          cellOptions = cellOptions.call(this);
        }
        return cellOptions.column;
      }
    }, {
      mixins: ['StaticClasses.ViewMixin', 'Cell.ViewMixin']
    });
    return Oraculum.defineMixin('muTableColumnOrder.RowMixin', {
      mixinOptions: {
        staticClasses: ['mutable-column-order-row-mixin'],
        eventedMethods: {
          initModelView: {}
        },
        muTableColumnOrder: {
          target: null,
          axis: 'x',
          items: '> .cell',
          cursor: 'move',
          helper: 'clone',
          cancel: '.unorderable-cell',
          placeholder: 'sortable-placeholder'
        }
      },
      mixconfig: function(mixinOptions, arg) {
        var muTableColumnOrder;
        muTableColumnOrder = (arg != null ? arg : {}).muTableColumnOrder;
        return mixinOptions.muTableColumnOrder = composeConfig(mixinOptions.muTableColumnOrder, muTableColumnOrder);
      },
      mixinitialize: function() {
        this.once('visibilityChange', (function(_this) {
          return function() {
            return _this._initSortable.apply(_this, arguments);
          };
        })(this));
        this.on('visibilityChange', (function(_this) {
          return function() {
            return _this._refreshSortable.apply(_this, arguments);
          };
        })(this));
        this.on('dispose:before', (function(_this) {
          return function() {
            return _this._destroySortable.apply(_this, arguments);
          };
        })(this));
        return this.on('sortupdate', (function(_this) {
          return function() {
            return _this._handleSortableUpdate.apply(_this, arguments);
          };
        })(this));
      },
      initModelView: function(model) {
        var modelView, view, viewOptions;
        view = this.resolveModelView(model);
        viewOptions = this.resolveViewOptions(model);
        modelView = this.createView({
          view: view,
          viewOptions: viewOptions
        });
        if (indexOf.call(modelView.__mixins(), 'muTableColumnOrder.CellMixin') < 0) {
          throw new TypeError(view + " fails to implement muTableColumnOrder.CellMixin");
        }
        return modelView;
      },
      getSortableAttributeOrder: function() {
        var $target;
        $target = this._resolveSortableTarget();
        return $target.sortable('toArray', {
          attribute: 'data-column-attr'
        });
      },
      _initSortable: function() {
        var $target, options;
        options = this.mixinOptions.muTableColumnOrder;
        if (_.isFunction(options)) {
          options = options.call(this);
        }
        $target = this._resolveSortableTarget();
        $target.sortable(options);
        return _.each(SORT_EVENTS, (function(_this) {
          return function(sortEvent) {
            return $target.on(sortEvent, function() {
              console.log(sortEvent);
              return _this.trigger.apply(_this, [sortEvent].concat(slice.call(arguments)));
            });
          };
        })(this));
      },
      _refreshSortable: function() {
        var $target;
        $target = this._resolveSortableTarget();
        return $target.sortable('refresh');
      },
      _destroySortable: function() {
        var $target;
        $target = this._resolveSortableTarget();
        return $target.sortable('destroy');
      },
      _resolveSortableTarget: function() {
        var $target, options;
        options = this.mixinOptions.muTableColumnOrder;
        if (_.isFunction(options)) {
          options = options.call(this);
        }
        return $target = resolveViewTarget(this, options.target);
      },
      _handleSortableUpdate: function() {
        var nwo;
        nwo = this.getSortableAttributeOrder();
        this.collection.comparator = function(model) {
          var index;
          index = nwo.indexOf(model.get('attribute'));
          if (index > -1) {
            return index;
          } else {
            return this.length;
          }
        };
        return this.collection.sort();
      }
    }, {
      mixins: ['Row.ViewMixin', 'StaticClasses.ViewMixin']
    });
  });

}).call(this);
