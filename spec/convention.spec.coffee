define [
  'oraculum'
], (Oraculum) ->
  'use strict'

  describe 'Coding conventions', ->

    describe 'mixins', ->
      _.each Oraculum.mixins, ({mixinOptions}, name) ->
        settings = Oraculum.mixinSettings[name]

        describe name, ->

          if mixinOptions?
            # The correct way to add event handlers in mixins is to add them
            # programatically in mixinitialize or similar.
            it 'should not use Listener.Mixin mixinOptions', ->
              expect(mixinOptions.listen).not.toBeDefined()
