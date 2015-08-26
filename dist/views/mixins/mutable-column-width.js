(function() {
  define(['oraculum', 'oraculum/libs', 'oraculum/plugins/tabular/views/mixins/variable-width-cell', 'jquery-ui/resizable'], function(Oraculum) {
    'use strict';
    var _, mixconfig, mixinOptions;
    _ = Oraculum.get('underscore');
    Oraculum.defineMixin('jQueryUIResizable.ViewMixin', {
      mixinOptions: {
        jQueryUIResizable: {}
      },
      mixconfig: function(mixinOptions, arg) {
        var jQueryUIResizable;
        jQueryUIResizable = (arg != null ? arg : {}).jQueryUIResizable;
        return mixinOptions.jQueryUIResizable = Oraculum.composeConfig(mixinOptions.jQueryUIResizable, jQueryUIResizable);
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
        options = this.mixinOptions.jQueryUIResizable;
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
            if ($target.data('resizable') == null) {
              return $target.resizable(options);
            }
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
        resizableOptions: {
          handles: 'e'
        }
      }
    };
    mixconfig = function(mixinOptions, options) {
      var cellSelector, jQueryUIResizableSpec, muTableColumnWidthCellSelector, muTableColumnWidthResizableOptions, resizableOptions;
      if (options == null) {
        options = {};
      }
      muTableColumnWidthCellSelector = options.muTableColumnWidthCellSelector, muTableColumnWidthResizableOptions = options.muTableColumnWidthResizableOptions;
      cellSelector = muTableColumnWidthCellSelector || mixinOptions.muTableColumnWidth.cellSelector;
      if (cellSelector === null) {
        cellSelector = '';
      }
      resizableOptions = Oraculum.composeConfig(mixinOptions.muTableColumnWidth.resizableOptions, muTableColumnWidthResizableOptions);
      if (cellSelector != null) {
        (jQueryUIResizableSpec = {})[cellSelector] = resizableOptions;
      }
      return mixinOptions.jQueryUIResizable = Oraculum.composeConfig(mixinOptions.jQueryUIResizable, jQueryUIResizableSpec);
    };
    Oraculum.defineMixin('muTableColumnWidth.RowMixin', {
      mixinOptions: mixinOptions,
      mixconfig: mixconfig,
      mixinitialize: function() {
        var ensureResizableColumnCells;
        ensureResizableColumnCells = _.debounce((function(_this) {
          return function() {
            if (!_this.disposed) {
              return _this._ensureResizableColumnCells();
            }
          };
        })(this));
        this.on('visibilityChange', ensureResizableColumnCells);
        return ensureResizableColumnCells();
      },
      _ensureResizableColumnCells: function() {
        return _.each(this.getModelViews(), function(view) {
          return view.__mixin('muTableColumnWidth.CellMixin', {});
        });
      }
    }, {
      mixins: ['jQueryUIResizable.ViewMixin']
    });
    return Oraculum.defineMixin('muTableColumnWidth.TableMixin', {
      mixinOptions: mixinOptions,
      mixconfig: mixconfig,
      mixinitialize: function() {
        var ensureResizableColumnRows;
        ensureResizableColumnRows = _.debounce((function(_this) {
          return function() {
            if (!_this.disposed) {
              return _this._ensureResizableColumnRows();
            }
          };
        })(this));
        this.on('visibilityChange', ensureResizableColumnRows);
        return ensureResizableColumnRows();
      },
      _ensureResizableColumnRows: function() {
        return _.each(this.getModelViews(), function(view) {
          return view.__mixin('muTableColumnWidth.RowMixin', {});
        });
      }
    }, {
      mixins: ['jQueryUIResizable.ViewMixin']
    });
  });

}).call(this);
