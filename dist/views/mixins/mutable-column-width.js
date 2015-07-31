(function() {
  var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    slice = [].slice;

  define(['oraculum', 'oraculum/plugins/tabular/views/mixins/variable-width-cell', 'jquery-ui/resizable'], function(Oraculum) {
    'use strict';
    var RESIZE_EVENTS;
    RESIZE_EVENTS = ['resize', 'resizestop', 'resizestart', 'resizecreate'];
    Oraculum.defineMixin('muTableColumnWidth.CellMixin', {
      mixinOptions: {
        muTableColumnWidth: {
          target: null,
          handles: 'e',
          minWidth: 100,
          containment: 'parent'
        }
      },
      mixconfig: function(mixinOptions, arg) {
        var muTableColumnWidth;
        muTableColumnWidth = (arg != null ? arg : {}).muTableColumnWidth;
        return mixinOptions.muTableColumnWidth = Oraculum.composeConfig(mixinOptions.muTableColumnWidth, muTableColumnWidth);
      },
      mixinitialize: function() {
        if (indexOf.call(this.__activeMixins(), 'Cell.ViewMixin') < 0) {
          throw new TypeError('muTableColumnWidth.CellMixin must be used with Cell.ViewMixin.');
        }
        if (this.$el.parent().length > 0) {
          this._initializeResizablePlugin();
        }
        this.on('addedToParent', (function(_this) {
          return function() {
            return _this._initializeResizablePlugin.apply(_this, arguments);
          };
        })(this));
        this.on('dispose', (function(_this) {
          return function() {
            return _this._destroyResizablePlugin.apply(_this, arguments);
          };
        })(this));
        this.on('resize', (function(_this) {
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
            return _this._updateResizableEnabled();
          };
        })(this));
      },
      _initializeResizablePlugin: function() {
        var $target, options;
        if (this._resizablePluginInitialized) {
          return;
        }
        this._resizablePluginInitialized = true;
        options = this.mixinOptions.muTableColumnWidth;
        if (_.isFunction(options)) {
          options = options.call(this);
        }
        $target = this._resolveResizableTarget();
        $target.resizable(options);
        _.each(RESIZE_EVENTS, (function(_this) {
          return function(resizeEvent) {
            return $target.on(resizeEvent, function() {
              return _this.trigger.apply(_this, [resizeEvent].concat(slice.call(arguments)));
            });
          };
        })(this));
        return this._updateResizableEnabled();
      },
      _updateResizableEnabled: function() {
        var $target, enabled, options;
        if (!this._resizablePluginInitialized) {
          return;
        }
        enabled = Boolean(this.column.get('resizable'));
        options = this.mixinOptions.muTableColumnWidth;
        if (_.isFunction(options)) {
          options = options.call(this);
        }
        $target = this._resolveResizableTarget();
        $target.find('.ui-resizable-handle').toggle(enabled);
        return $target.resizable('option', 'disabled', !enabled);
      },
      _destroyResizablePlugin: function() {
        if (!this._resizablePluginInitialized) {
          return;
        }
        this._resolveResizableTarget().resizable('destroy');
        return this._resizablePluginInitialized = false;
      },
      _resolveResizableTarget: function() {
        var options;
        options = this.mixinOptions.muTableColumnWidth;
        if (_.isFunction(options)) {
          options = options.call(this);
        }
        return Oraculum.resolveViewTarget(this, options.target);
      }
    }, {
      mixins: ['VariableWidth.CellMixin']
    });
    Oraculum.defineMixin('muTableColumnWidth.RowMixin', {
      mixinitialize: function() {
        if (indexOf.call(this.__activeMixins(), 'Row.ViewMixin') < 0) {
          throw new TypeError('muTableColumnWidth.RowMixin must be used with Row.ViewMixin.');
        }
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
    });
    return Oraculum.defineMixin('muTableColumnWidth.TableMixin', {
      mixinitialize: function() {
        if (indexOf.call(this.__activeMixins(), 'Table.ViewMixin') < 0) {
          throw new TypeError('muTableColumnWidth.TableMixin must be used with Table.ViewMixin.');
        }
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
    });
  });

}).call(this);
