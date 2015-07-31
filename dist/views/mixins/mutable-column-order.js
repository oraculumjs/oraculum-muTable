(function() {
  var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    slice = [].slice;

  define(['oraculum', 'oraculum/libs', 'oraculum/views/mixins/static-classes', 'oraculum/plugins/tabular/views/mixins/row', 'oraculum/plugins/tabular/views/mixins/cell', 'jquery-ui/sortable'], function(Oraculum) {
    'use strict';
    var $, SORT_EVENTS, _;
    $ = Oraculum.get('jQuery');
    _ = Oraculum.get('underscore');
    SORT_EVENTS = ['sortactivate', 'sortdeactivate', 'sortstart', 'sortbeforeStop', 'sortstop', 'sortcreate', 'sortremove', 'sortchange', 'sortupdate', 'sort', 'sortout', 'sortover', 'sortreceive'];
    Oraculum.defineMixin('muTableColumnOrder.CellMixin', {
      mixinitialize: function() {
        if (indexOf.call(this.__activeMixins(), 'Cell.ViewMixin') < 0) {
          throw new TypeError('muTableColumnOrder.CellMixin must be used with Cell.ViewMixin.');
        }
        this.listenTo(this.column, 'change:orderable', (function(_this) {
          return function() {
            return _this._updateColumnOrderable();
          };
        })(this));
        return this._updateColumnOrderable();
      },
      _updateColumnOrderable: function() {
        return this.$el.toggleClass('unorderable-cell', !Boolean(this.column.get('orderable')));
      }
    });
    Oraculum.defineMixin('muTableColumnOrder.RowMixin', {
      mixinOptions: {
        muTableColumnOrder: {
          target: null,
          axis: 'x',
          items: '> .cell_view-mixin',
          cursor: 'move',
          helper: 'clone',
          cancel: '.unorderable-cell',
          placeholder: 'sortable-placeholder'
        }
      },
      mixconfig: function(mixinOptions, arg) {
        var muTableColumnOrder;
        muTableColumnOrder = (arg != null ? arg : {}).muTableColumnOrder;
        return mixinOptions.muTableColumnOrder = Oraculum.composeConfig(mixinOptions.muTableColumnOrder, muTableColumnOrder);
      },
      mixinitialize: function() {
        if (indexOf.call(this.__activeMixins(), 'Row.ViewMixin') < 0) {
          throw new TypeError('muTableColumnOrder.RowMixin must be used with Row.ViewMixin.');
        }
        this._ensureSortableColumnCells();
        if (this.getModelViews().length > 0) {
          this._initSortablePlugin();
        }
        this.once('visibilityChange', (function(_this) {
          return function() {
            return _this._initSortablePlugin.apply(_this, arguments);
          };
        })(this));
        this.on('visibilityChange', (function(_this) {
          return function() {
            return _this._refreshSortablePlugin.apply(_this, arguments);
          };
        })(this));
        this.on('dispose', (function(_this) {
          return function() {
            return _this._destroySortablePlugin.apply(_this, arguments);
          };
        })(this));
        return this.on('sortupdate', (function(_this) {
          return function() {
            return _this._handleSortableUpdate.apply(_this, arguments);
          };
        })(this));
      },
      _ensureSortableColumnCells: function() {
        return _.each(this.getModelViews(), function(view) {
          return view.__mixin('muTableColumnOrder.CellMixin');
        });
      },
      getSortableAttributeOrder: function() {
        if (!this._sortablePluginInitialized) {
          return;
        }
        return this._resolveSortableTarget().sortable('toArray', {
          attribute: 'data-column-attr'
        });
      },
      _initSortablePlugin: function() {
        var $target, options;
        if (this._sortablePluginInitialized) {
          return;
        }
        options = this.mixinOptions.muTableColumnOrder;
        if (_.isFunction(options)) {
          options = options.call(this);
        }
        $target = this._resolveSortableTarget();
        $target.sortable(options);
        _.each(SORT_EVENTS, (function(_this) {
          return function(sortEvent) {
            return $target.on(sortEvent, function() {
              return _this.trigger.apply(_this, [sortEvent].concat(slice.call(arguments)));
            });
          };
        })(this));
        return this._sortablePluginInitialized = true;
      },
      _refreshSortablePlugin: function() {
        this._ensureSortableColumnCells();
        if (!this._sortablePluginInitialized) {
          return;
        }
        return this._resolveSortableTarget().sortable('refresh');
      },
      _destroySortablePlugin: function() {
        if (!this._sortablePluginInitialized) {
          return;
        }
        this._resolveSortableTarget().sortable('destroy');
        return this._sortablePluginInitialized = false;
      },
      _resolveSortableTarget: function() {
        var options;
        options = this.mixinOptions.muTableColumnOrder;
        if (_.isFunction(options)) {
          options = options.call(this);
        }
        return Oraculum.resolveViewTarget(this, options.target);
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
    });
    return Oraculum.defineMixin('muTableColumnOrder.TableMixin', {
      mixinitialize: function() {
        if (indexOf.call(this.__activeMixins(), 'Table.ViewMixin') < 0) {
          throw new TypeError('muTableColumnOrder.TableMixin must be used with Table.ViewMixin.');
        }
        this.on('visibilityChange', (function(_this) {
          return function() {
            return _this._ensureSortableColumnRows();
          };
        })(this));
        return this._ensureSortableColumnRows();
      },
      _ensureSortableColumnRows: function() {
        return _.each(this.getModelViews(), function(view) {
          return view.__mixin('muTableColumnOrder.RowMixin');
        });
      }
    });
  });

}).call(this);
