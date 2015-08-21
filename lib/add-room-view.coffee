{Point} = require 'atom'
{$, TextEditorView, View}  = require 'atom-space-pen-views'

module.exports =
class AddRoomView extends View
  @activate: -> new AddRoomView

  @content: ->
    @div class: 'add-room', =>
      @subview 'miniEditor', new TextEditorView(mini: true)
      @div class: 'message', outlet: 'message'

  initialize: (@atomChat) ->
      @panel = atom.workspace.addModalPanel(item: this, visible: false)

      @miniEditor.on 'blur', => @close()
      atom.commands.add @miniEditor.element, 'core:confirm', => @confirm()
      atom.commands.add @miniEditor.element, 'core:cancel', => @close()

  toggle: ->
    if @panel.isVisible()
      @close()
    else
      @open()

  close: ->
    return unless @panel.isVisible()

    miniEditorFocused = @miniEditor.hasFocus()
    @miniEditor.setText('')
    @panel.hide()
    @restoreFocus() if miniEditorFocused

  confirm: ->
    roomName = @miniEditor.getText()
    @close()
    return unless @atomChat? and roomName.length

    if roomName.length > 16
      roomName = roomName.substring(0,16);

    @atomChat.createRoom roomName

  storeFocusedElement: ->
    @previouslyFocusedElement = $(':focus')

  restoreFocus: ->
    if @previouslyFocusedElement?.isOnDom()
      @previouslyFocusedElement.focus()
    else
      atom.views.getView(atom.workspace).focus()

  open: ->
    return if @panel.isVisible()

    if @atomChat?
      @storeFocusedElement()
      @panel.show()
      @message.text("Enter a room name (0-16 characters).")
      @miniEditor.focus()
