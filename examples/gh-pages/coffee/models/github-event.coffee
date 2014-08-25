define [
  'oraculum'
  'oraculum/libs'
  'oraculum/models/mixins/auto-fetch'
  'oraculum/models/mixins/sort-by-attribute-direction'
], (Oraculum) ->
  'use strict'

  _ = Oraculum.get 'underscore'
  Backbone = Oraculum.get 'Backbone'

  Oraculum.extend 'Collection', 'GithubEvent.Collection', {
    url: 'https://api.github.com/users/lookout/events'

    sync: (method, model, options) ->
      Backbone.sync method, model, _.extend {
        dataType: 'jsonp'
      }, options

    parse: (response) ->
      return response.data

  }, {
    singleton: true
    mixins: [
      'AutoFetch.ModelMixin'
      'SortByAttributeDirection.CollectionMixin'
    ]
  }
