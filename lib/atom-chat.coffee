{CompositeDisposable} = require 'atom'

module.exports =
  activate: (state) ->
    @subscriptions = new CompositeDisposable

    @createView()
    @subscriptions.add atom.commands.add 'atom-workspace', "atom-chat:toggle", =>
      @atomChatView.toggle()

    @subscriptions.add atom.commands.add 'atom-workspace', 'room-selector:show', =>
      @createRoomListView()

    @subscriptions.add atom.commands.add 'atom-workspace', 'add-room:show', =>
      @createAddRoomView()

  createView: ->
    unless @atomChatView?
      AtomChatView = require './atom-chat-view'
      @atomChatView = new AtomChatView()
    @atomChatView

  createRoomListView: ->
    unless @roomListView?
      RoomListView = require './room-list-view'
      @roomListView = new RoomListView(@atomChatView)
    @roomListView.toggle()

  createAddRoomView: ->
    unless @addRoomView?
      AddRoomView = require './add-room-view'
      @addRoomView = new AddRoomView(@atomChatView)
    @addRoomView.toggle()

  deactivate: ->
    @atomChatView.deactivate()
    @roomListView?.destroy()
    @subscriptions?.dispose()
    @subscriptions = null

  serialize: ->
    atomChatViewState: @atomChatView.serialize()
