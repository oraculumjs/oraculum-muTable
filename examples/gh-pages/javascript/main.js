requirejs.config({
  baseUrl: 'bower_components/oraculum/examples/gh-pages/coffee',

  paths: {

    // RequireJS plugins
    'cs': '../../../../require-cs/cs',
    'text': '../../../../requirejs-text/text',
    'coffee-script': '../../../../coffee-script/extras/coffee-script',

    // FactoryJS
    'Factory': '../../../../factoryjs/dist/Factory',
    'BackboneFactory': '../../../../factoryjs/dist/BackboneFactory',

    // Util libs
    'jquery': '../../../../jquery/dist/jquery',
    'backbone': '../../../../backbone/backbone',
    'interact': '../../../../interact/interact',
    'bootstrap': '../../../../bootstrap-css/js/bootstrap',
    'underscore': '../../../../underscore/underscore',

    // Other stuff
    'md': '../markdown',
    'mu': '../../../../../',

    // Markdown
    'marked': '../../../../marked/lib/marked',
    'highlight': '../../../../highlightjs/highlight.pack'
  },

  shim: {
    bootstrap: {deps: ['jquery']},

    marked: { exports: 'marked' },
    highlight: { exports: 'hljs' },

    jquery: { exports: 'jQuery' },
    underscore: { exports: '_' },
    backbone: {
      deps: ['jquery', 'underscore'],
      exports: 'Backbone'
    }
  },

  packages: [{
    name: 'oraculum',
    location: '../../../../oraculum/dist'
  }, {
    name: 'muTable',
    location: '../../../../../dist'
  }],

  callback: function () {
    require(['cs!../../../../../examples/gh-pages/coffee/index']);
  }
});
