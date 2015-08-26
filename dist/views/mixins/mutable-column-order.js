(function() {
  define(['oraculum', 'oraculum/libs', 'oraculum/views/mixins/static-classes', 'oraculum/plugins/tabular/views/mixins/row', 'oraculum/plugins/tabular/views/mixins/cell', 'jquery-ui/sortable'], function(Oraculum) {
    'use strict';
    var _, mixconfig, mixinOptions;
    _ = Oraculum.get('underscore');
    Oraculum.defineMixin('jQueryUISortable.ViewMixin', {
      mixinOptions: {
        jQueryUISortable: {}
      },
      mixconfig: function(mixinOptions, arg) {
        var jQueryUISortable;
        jQueryUISortable = (arg != null ? arg : {}).jQueryUISortable;
        return mixinOptions.jQueryUISortable = Oraculum.composeConfig(mixinOptions.jQueryUISortable, jQueryUISortable);
      },
      mixinitialize: function() {
        var initializeSortablePlugin;
        initializeSortablePlugin = _.debounce(((function(_this) {
          return function() {
            if (!_this.disposed) {
              return _this._initializeSortablePlugin();
            }
          };
        })(this)), 100);
        this.on('subviewCreated', initializeSortablePlugin);
        this.on('visibilityChange', initializeSortablePlugin);
        return initializeSortablePlugin();
      },
      _initializeSortablePlugin: function() {
        var options;
        options = this.mixinOptions.jQueryUISortable;
        if (_.isFunction(options)) {
          options = options.call(this);
        }
        return _.each(options, (function(_this) {
          return function(options, selector) {
            var $target;
            if (selector === '') {
              selector = null;
            }
            if (_.isFunction(options)) {
              options = options.call(_this);
            }
            $target = Oraculum.resolveViewTarget(_this, selector);
            if ($target.data('sortable') != null) {
              return $target.sortable('refresh');
            } else {
              return $target.sortable(options);
            }
          };
        })(this));
      }
    });
    Oraculum.defineMixin('muTableColumnOrder.CellMixin', {
      mixinitialize: function() {
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
    mixinOptions = {
      muTableColumnOrder: {
        rowSelector: void 0,
        sortableOptions: {
          axis: 'x',
          items: '.cell_view-mixin',
          cursor: 'move',
          helper: 'clone',
          cancel: '.unorderable-cell',
          placeholder: 'sortable-placeholder'
        }
      }
    };
    mixconfig = function(mixinOptions, options) {
      var jQueryUISortableSpec, muTableColumnOrderCellSelector, muTableColumnOrderSortableOptions, rowSelector, sortableOptions;
      if (options == null) {
        options = {};
      }
      muTableColumnOrderCellSelector = options.muTableColumnOrderCellSelector, muTableColumnOrderSortableOptions = options.muTableColumnOrderSortableOptions;
      rowSelector = muTableColumnOrderCellSelector || mixinOptions.muTableColumnOrder.rowSelector;
      if (rowSelector === null) {
        rowSelector = '';
      }
      sortableOptions = Oraculum.composeConfig(mixinOptions.muTableColumnOrder.sortableOptions, muTableColumnOrderSortableOptions);
      if (rowSelector != null) {
        (jQueryUISortableSpec = {})[rowSelector] = sortableOptions;
      }
      return mixinOptions.jQueryUISortable = Oraculum.composeConfig(mixinOptions.jQueryUISortable, jQueryUISortableSpec);
    };
    Oraculum.defineMixin('muTableColumnOrder.RowMixin', {
      mixinOptions: mixinOptions,
      mixconfig: mixconfig,
      mixinitialize: function() {
        var ensureSortableColumnCells;
        this.$el.on('sortupdate', (function(_this) {
          return function() {
            return _this._handleSortableUpdate();
          };
        })(this));
        ensureSortableColumnCells = _.debounce((function(_this) {
          return function() {
            if (!_this.disposed) {
              return _this._ensureSortableColumnCells();
            }
          };
        })(this));
        this.on('visibilityChange', ensureSortableColumnCells);
        return ensureSortableColumnCells();
      },
      getSortableAttributeOrder: function() {
        return this.$el.sortable('toArray', {
          attribute: 'data-column-attr'
        });
      },
      _ensureSortableColumnCells: function() {
        return _.each(this.getModelViews(), function(view) {
          return view.__mixin('muTableColumnOrder.CellMixin');
        });
      },
      _handleSortableUpdate: function() {
        var nwo;
        nwo = this.getSortableAttributeOrder();
        this.collection.models = this.collection.sortBy((function(_this) {
          return function(model) {
            var index;
            index = nwo.indexOf(model.get('attribute'));
            if (index > -1) {
              return index;
            } else {
              return _this.collection.length;
            }
          };
        })(this));
        return this.collection.trigger('sort', this.collection, {});
      }
    }, {
      mixins: ['jQueryUISortable.ViewMixin']
    });
    return Oraculum.defineMixin('muTableColumnOrder.TableMixin', {
      mixinOptions: mixinOptions,
      mixconfig: mixconfig,
      mixinitialize: function() {
        var ensureSortableColumnRows;
        ensureSortableColumnRows = _.debounce((function(_this) {
          return function() {
            if (!_this.disposed) {
              return _this._ensureSortableColumnRows();
            }
          };
        })(this));
        this.on('visibilityChange', ensureSortableColumnRows);
        return ensureSortableColumnRows();
      },
      _ensureSortableColumnRows: function() {
        return _.each(this.getModelViews(), function(view) {
          return view.__mixin('muTableColumnOrder.RowMixin');
        });
      }
    }, {
      mixins: ['jQueryUISortable.ViewMixin']
    });
  });

}).call(this);
