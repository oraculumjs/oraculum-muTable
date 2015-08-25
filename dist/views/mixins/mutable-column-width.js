(function() {
  define(['oraculum', 'oraculum/libs', 'oraculum/plugins/tabular/views/mixins/variable-width-cell', 'jquery-ui/resizable'], function(Oraculum) {
    'use strict';
    var RESIZE_EVENTS, _, mixconfig, mixinOptions;
    _ = Oraculum.get('underscore');
    RESIZE_EVENTS = ['resize', 'resizestop', 'resizestart', 'resizecreate'];
    Oraculum.defineMixin('jQueryResizable.ViewMixin', {
      mixinOptions: {
        jQueryResizable: {}
      },
      mixconfig: function(mixinOptions, arg) {
        var jQueryResizable;
        jQueryResizable = (arg != null ? arg : {}).jQueryResizable;
        return mixinOptions.jQueryResizable = Oraculum.composeConfig(mixinOptions.jQueryResizable, jQueryResizable);
      },
      mixinitialize: function() {
        var initializeResizablePlugin;
        initializeResizablePlugin = _.debounce(((function(_this) {
          return function() {
            if (!_this.disposed) {
              return _this._initializeResizablePlugin();
            }
          };
        })(this)), 100);
        this.on('subviewCreated', initializeResizablePlugin);
        this.on('visibilityChange', initializeResizablePlugin);
        return initializeResizablePlugin();
      },
      _initializeResizablePlugin: function() {
        var options;
        options = this.mixinOptions.jQueryResizable;
        if (_.isFunction(options)) {
          options = options.call(this);
        }
        return _.each(options, (function(_this) {
          return function(options, selector) {
            var $target;
            if (_.isFunction(options)) {
              options = options.call(_this);
            }
            $target = Oraculum.resolveViewTarget(_this, selector || null);
            return $target.resizable(options);
          };
        })(this));
      }
    });
    Oraculum.defineMixin('muTableColumnWidth.CellMixin', {
      mixinitialize: function() {
        this.$el.on('resize', (function(_this) {
          return function(e, arg) {
            var width;
            width = arg.size.width;
            return _this.column.set({
              width: width
            });
          };
        })(this));
        return this.listenTo(this.column, 'change:resizable', (function(_this) {
          return function() {
            return _this.$el.resizable('option', 'disabled', !_this.column.get('resizable'));
          };
        })(this));
      }
    }, {
      mixins: ['VariableWidth.CellMixin']
    });
    mixinOptions = {
      muTableColumnWidth: {
        cellSelector: void 0,
        resizableOptions: {}
      }
    };
    mixconfig = function(mixinOptions, options) {
      var cellSelector, jQueryResizableSpec, muTableColumnWidthCellSelector, muTableColumnWidthResizableOptions, resizableOptions;
      if (options == null) {
        options = {};
      }
      muTableColumnWidthCellSelector = options.muTableColumnWidthCellSelector, muTableColumnWidthResizableOptions = options.muTableColumnWidthResizableOptions;
      cellSelector = muTableColumnWidthCellSelector || mixinOptions.muTableColumnWidth.cellSelector;
      resizableOptions = Oraculum.composeConfig(mixinOptions.muTableColumnWidth.resizableOptions, muTableColumnWidthResizableOptions);
      if (cellSelector != null) {
        (jQueryResizableSpec = {})[cellSelector] = resizableOptions;
      }
      return mixinOptions.jQueryResizable = Oraculum.composeConfig(mixinOptions.jQueryResizable, jQueryResizableSpec);
    };
    Oraculum.defineMixin('muTableColumnWidth.RowMixin', {
      mixinOptions: mixinOptions,
      mixconfig: mixconfig,
      mixinitialize: function() {
        this._ensureResizableColumnCells();
        return this.on('visibilityChange', (function(_this) {
          return function() {
            return _this._ensureResizableColumnCells.apply(_this, arguments);
          };
        })(this));
      },
      _ensureResizableColumnCells: function() {
        return _.each(this.getModelViews(), function(view) {
          return view.__mixin('muTableColumnWidth.CellMixin', {});
        });
      }
    }, {
      mixins: ['jQueryResizable.ViewMixin']
    });
    return Oraculum.defineMixin('muTableColumnWidth.TableMixin', {
      mixinOptions: mixinOptions,
      mixconfig: mixconfig,
      mixinitialize: function() {
        this._ensureResizableColumnRows();
        return this.on('visibilityChange', (function(_this) {
          return function() {
            return _this._ensureResizableColumnRows.apply(_this, arguments);
          };
        })(this));
      },
      _ensureResizableColumnRows: function() {
        return _.each(this.getModelViews(), function(view) {
          return view.__mixin('muTableColumnWidth.RowMixin', {});
        });
      }
    }, {
      mixins: ['jQueryResizable.ViewMixin']
    });
  });

}).call(this);
