(function() {
  define(['oraculum', 'interact'], function(Oraculum, interact) {
    'use strict';
    return Oraculum.define('interact', (function() {
      return interact;
    }), {
      singleton: true
    });
  });

}).call(this);
