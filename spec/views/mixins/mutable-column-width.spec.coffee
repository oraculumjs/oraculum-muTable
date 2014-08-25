define [
  'oraculum'
  'muTable/libs'
  'oraculum/libs'
  'oraculum/mixins/disposable'
  'oraculum/models/mixins/disposable'
  'oraculum/views/mixins/remove-disposed'
  'oraculum/plugins/tabular/views/cells/text'
  'oraculum/plugins/tabular/views/mixins/row'
  'oraculum/plugins/tabular/views/mixins/table'
  'muTable/views/mixins/mutable-column-width'
], (Oraculum) ->
  'use strict'

  $ = Oraculum.get 'jQuery'
  interact = Oraculum.get 'interact'

  describe 'muTableColumnWidth.TableMixin', ->

    Oraculum.extend 'Model', 'Disposable.muTableColumnWidth.TableMixin.Test.Model', {
    }, mixins: ['Disposable.Mixin']

    Oraculum.extend 'Collection', 'Disposable.muTableColumnWidth.TableMixin.Test.Collection', {
      model: 'Disposable.muTableColumnWidth.TableMixin.Test.Model'
    }, mixins: ['Disposable.CollectionMixin']

    Oraculum.extend 'View', 'muTableColumnWidth.TableMixin.Test.Row', {
      mixinOptions:
        list:
          modelView: 'Text.Cell'
          viewOptions: tagName: 'td'
    }, mixins: [
      'Disposable.Mixin'
      'Row.ViewMixin'
    ]

    Oraculum.extend 'View', 'muTableColumnWidth.TableMixin.Test.View', {
      tagName: 'table'

      mixinOptions:
        disposable:
          disposeAll: true
        list:
          modelView: 'muTableColumnWidth.TableMixin.Test.Row'
          viewOptions: tagName: 'tr'

    }, mixins: [
      'Disposable.Mixin'
      'Attach.ViewMixin'
      'RemoveDisposed.ViewMixin'
      'muTableColumnWidth.TableMixin'
    ]

    testView = null

    beforeEach ->
      testView = Oraculum.get 'muTableColumnWidth.TableMixin.Test.View',
        container: document.body
        columns: Oraculum.get 'Disposable.muTableColumnWidth.TableMixin.Test.Collection'
        collection: Oraculum.get 'Disposable.muTableColumnWidth.TableMixin.Test.Collection'

    afterEach ->
      testView.dispose()

    it 'should allow handleWidth to be be set at construction', ->
      testView.dispose()
      testView = Oraculum.get 'muTableColumnWidth.TableMixin.Test.View',
        container: document.body
        handleWidth: 100
        columns: Oraculum.get 'Disposable.muTableColumnWidth.TableMixin.Test.Collection'
        collection: Oraculum.get 'Disposable.muTableColumnWidth.TableMixin.Test.Collection'
      expect(testView.mixinOptions.muTableColumnWidth.handleWidth).toBe 100

    it 'should allow widthFunction to be set at construction', ->
      testView.dispose()
      testView = Oraculum.get 'muTableColumnWidth.TableMixin.Test.View',
        container: document.body
        widthFunction: 'innerWidth'
        columns: Oraculum.get 'Disposable.muTableColumnWidth.TableMixin.Test.Collection'
        collection: Oraculum.get 'Disposable.muTableColumnWidth.TableMixin.Test.Collection'
      expect(testView.mixinOptions.muTableColumnWidth.widthFunction).toBe 'innerWidth'

    it 'should render a muTableHandles subview', ->
      testView.render()
      muTableHandles = testView.subview 'muTableHandles'
      expect(muTableHandles.__type()).toBe '_MutableColumnWidthHandles.View'
      expect(muTableHandles.el.parentNode).toBe testView.el
      expect(muTableHandles.collection).toBe testView.columns

    describe 'reactionary behavior', ->
      row = null
      column = null
      _updateOffsets = null

      beforeEach ->
        row = testView.collection.add {'attribute'}, silent: true
        column = testView.columns.add {'attribute'}, silent: true
        _updateOffsets = sinon.spy testView, '_updateOffsets'

      afterEach ->
        _updateOffsets.restore()

      # We describe _updateOffsets underneath reactionary behavior because
      # it is the common implementation across all of our event hooks, and
      # would be redundant to repeat the tests for each callback.

      describe '_updateOffsets', ->

        Oraculum.onTag 'Disposable.muTableColumnWidth.TableMixin.Test.Model', (model) ->
          sinon.spy model, 'set'

        it 'should do nothing if there are no visible rows', ->
          column = testView.columns.add {'attribute'}
          expect(column.set).not.toHaveBeenCalled()

        it 'should update each columns width, handleLeft and handleWidth based on the first visible row', ->
          row = testView.collection.add {'attribute'}, silent: true
          column = testView.columns.add {'attribute'}, silent: true
          testView.render()
          testView._updateOffsets()
          expect(column.set).toHaveBeenCalledOnce()
          expect(column.set.firstCall.args[0]).toImplement {'handleLeft', 'handleWidth', 'width'}

        it 'should allow widthFunction to be a function', ->
          widthFunction = sinon.stub().returns 100
          thisView = Oraculum.get 'muTableColumnWidth.TableMixin.Test.View',
            container: document.body
            columns: Oraculum.get 'Disposable.muTableColumnWidth.TableMixin.Test.Collection'
            collection: Oraculum.get 'Disposable.muTableColumnWidth.TableMixin.Test.Collection'
            widthFunction: widthFunction
          row = thisView.collection.add {'attribute'}, silent: true
          column = thisView.columns.add {'attribute'}, silent: true
          thisView.render()
          thisView._updateOffsets()
          expect(widthFunction).toHaveBeenCalledOnce()
          expect(column.get 'width').toBe 100
          thisView.dispose()

      it 'should debounce invoke _updateOffsets on view visibilityChange', ->
        testView.trigger 'visibilityChange'
        waits(10) or runs ->
          expect(_updateOffsets).toHaveBeenCalledOnce()

      it 'should debounce invoke _updateOffsets on window/document resize', ->
        $(window, document).resize()
        waits(10) or runs ->
          expect(_updateOffsets).toHaveBeenCalledOnce()

      it 'should debounce invoke _updateOffsets on columns add/remove/reset', ->
        testView.columns.trigger 'add'
        waits(10) or runs ->
          expect(_updateOffsets).toHaveBeenCalledOnce()

          testView.columns.trigger 'remove'
          waits(10) or runs ->
            expect(_updateOffsets).toHaveBeenCalledTwice()

            testView.columns.trigger 'reset'
            waits(10) or runs ->
              expect(_updateOffsets).toHaveBeenCalledThrice()

      it 'should debounce invoke _updateOffsets on columns change:width/change:handleLeft', ->
        column.set width: 100
        waits(10) or runs ->
          expect(_updateOffsets).toHaveBeenCalledOnce()

          column.set handleLeft: 100
          waits(10) or runs ->
            expect(_updateOffsets).toHaveBeenCalledTwice()

    describe '_MutableColumnWidthHandle.View', ->
      column = column2 = null
      testHandle = testHandle2 = null

      beforeEach ->
        testView.render()
        column = testView.columns.add {'attribute'}
        column2 = testView.columns.add {'attribute'}
        testHandle = testView.subview('muTableHandles').getModelViews()[0]
        testHandle2 = testView.subview('muTableHandles').getModelViews()[1]

      describe 'interactjs configuration', ->
        _onmove = null

        beforeEach ->
          _onmove = sinon.stub testHandle, '_onmove'

        afterEach ->
          _onmove.restore()

        it 'should be draggable', ->
          interactable = interact testHandle.el
          expect(interactable.options.draggable).toBe true

        it 'should drag on the x axis', ->
          interactable = interact testHandle.el
          expect(interactable.options.dragAxis).toBe 'x'

        it 'should drag relative to itself', ->
          interactable = interact testHandle.el
          expect(interactable.options.origin).toBe testHandle.el

        it 'should invoke _onmove on drag', ->
          interactable = interact testHandle.el
          interactable.ondragmove()
          expect(_onmove).toHaveBeenCalledOnce()

      describe 'reactionary behavior', ->

        it 'should update its "width" style based on the columns handleWidth', ->
          handleWidth = 10
          column.set {handleWidth}
          expect(testHandle.$el.width()).toBe 10

        it 'should update its "left" style based on the columns handleLeft/handleWidth', ->
          handleLeft = 100
          handleWidth = 10
          column.set {handleLeft, handleWidth}
          expected = handleLeft - (handleWidth / 2)
          actual = parseInt testHandle.el.style.left, 10
          expect(actual).toBe expected

        it 'should update the width on the previous column on drag', ->
          interactable = interact testHandle2.el
          column.set width: 100
          column2.set width: 100, handleLeft: 100
          interactable.ondragmove({ pageX: 10 })
          expect(column.get 'width').toBe 110
          expect(column2.get 'width').toBe 90
          expect(column2.get 'handleLeft').toBe 110
