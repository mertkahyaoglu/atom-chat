{$, ScrollView, View, TextEditorView} = require 'atom-space-pen-views'
{CompositeDisposable, TextEditor, TextBuffer} = require 'atom'
MessageView = require './message-view'
_ = require 'underscore-plus'
socket = require('socket.io-client')('http://mert-kahyaoglu.com:49161');

module.exports =
  class AtomChatView extends ScrollView
    panel = null

    @content: ->
      chatEditor = new TextEditor
        mini: true
        tabLength: 2
        softTabs: true
        softWrapped: true
        buffer: new TextBuffer
        placeholderText: 'Type here'

      @div class: 'atom-chat', outlet: 'wrapper', =>
        @div class: 'chat', =>
          @div class: 'chat-header list-inline tab-bar inset-panel', =>
            @div "Atom Chat", class: 'chat-title', outlet: 'title'
          @div class: 'chat-input', =>
            @subview 'chatEditor', new TextEditorView(editor: chatEditor)
          @div class: 'chat-messages', outlet: 'messages', =>
            @ul tabindex: -1, outlet: 'list'
          @div class: 'chat-footer', =>
            @a "Room: Atom", class: 'chat-room', outlet: 'roomSelect'
            @a "+", class: 'add-room', outlet: 'addRoom'
        @div class: 'atom-chat-resize-handle', outlet: 'resizeHandle'

    initialize: () ->
      @subscriptions = new CompositeDisposable
      @username = atom.config.get('atom-chat.username')
      @handleSockets()
      @handleEvents()
      @room = 0

    handleSockets: ->
      socket.on 'connect', =>
        socket.emit 'atom:user', @username, (id) =>
          @uuid = id
          if @username is "User"
            @username = "User"+@uuid

      socket.on 'atom:message', (message) =>
        @addMessage(message)

      socket.on 'atom:online', (online) =>
        @showOnline(online)


    handleEvents: ->
      @on 'mousedown', '.atom-chat-resize-handle', (e) => @resizeStarted(e)
      @on 'keyup', '.chat-input .editor', (e) => @enterPressed(e)
      @on 'click', '.chat-room', => @roomsClicked()
      @on 'click', '.add-room', => @addRoomClicked()

      @subscriptions.add atom.config.onDidChange 'atom-chat.showOnRightSide', ({newValue}) =>
        @onSideToggled(newValue)

      @subscriptions.add atom.config.onDidChange 'atom-chat.username', ({newValue}) =>
        if newValue is "User"
          @username = newValue+@uuid
        else
          @username = newValue
        socket.emit 'atom:username', @username

    showOnline: (online)->
      @toolTipDisposable?.dispose()
      if online > 0
        @title.html('Atom Chat ('+online+')')
        title = "#{_.pluralize(online, 'user')} online"
      else
        title = "Nobody online"
        @title.html('Atom Chat')
      @toolTipDisposable = atom.tooltips.add @title, title: title

    onSideToggled: (newValue) ->
      @element.dataset.showOnRightSide = newValue
      if @isVisible()
        @detach()
        @attach()

    enterPressed: (e) ->
      key = e.keyCode || e.which
      if key == 13
        @sendMessage()

    addMessage: (message)->
      if message.roomId is @room
        @list.prepend new MessageView(message)
        if atom.config.get('atom-chat.openOnNewMessage')
          unless @isVisible()
            @detach()
            @attach()

    sendMessage: ->
      msg = @chatEditor.getText()
      @chatEditor.setText('')
      message =
        text: msg
        uuid: @uuid
        username: @username
        roomId: @room

      socket.emit 'atom:message', message

    createRoom: (roomName) ->
      socket.emit "atom:rooms:create", roomName, (id) =>
        @setCurrentRoom({id:id, name:roomName})
        @list.empty()

    joinRoom: (id) ->
      socket.emit "atom:rooms:join", id
      @list.empty()

    roomsClicked: ->
      atom.commands.dispatch(atom.views.getView(atom.workspace), 'room-selector:show')

    addRoomClicked: ->
      atom.commands.dispatch(atom.views.getView(atom.workspace), 'add-room:show')

    resizeStarted: =>
      $(document).on('mousemove', @resizeChatView)
      $(document).on('mouseup', @resizeStopped)

    resizeStopped: =>
      $(document).off('mousemove', @resizeChatView)
      $(document).off('mouseup', @resizeStopped)

    resizeChatView: ({pageX, which}) =>
      return @resizeStopped() unless which is 1
      if atom.config.get('atom-chat.showOnRightSide')
        width = @outerWidth() + @offset().left - pageX
      else
        width = pageX - @offset().left
      @width(width)

    getSocket: ->
      socket

    getCurrentRoom: ->
      @room

    setCurrentRoom: (roomData) ->
      @room = roomData.id
      @roomSelect.html("Room: "+ roomData.name);

    getUserId: ->
      @uuid

    serialize: ->

    destroy: ->
      @detach()
      @subscriptions?.dispose()
      @subscriptions = null
      @toolTipDisposable?.dispose()

    toggle: ->
      if @isVisible()
        @detach()
      else
        @show()

    show: ->
      @attach()
      @focus()

    attach: ->
      if atom.config.get('atom-chat.showOnRightSide')
        @removeClass('panel-left')
        @panel = atom.workspace.addRightPanel(item: this, className: 'panel-right')
      else
        @removeClass('panel-right')
        @panel = atom.workspace.addLeftPanel(item: this, className: 'panel-left')
      @chatEditor.focus()

    detach: ->
      @panel?.destroy()
      @panel = null
      @unfocus()

    unfocus: ->
      atom.workspace.getActivePane().activate()

    deactivate: ->
      @subscriptions.dispose()
      @detach() if @panel?

    detached: ->
      @resizeStopped()
