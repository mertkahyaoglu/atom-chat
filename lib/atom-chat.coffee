{CompositeDisposable} = require 'atom'

module.exports =
  config:
    username:
      type: 'string'
      default: 'me'
    showOnRightSide:
      type: 'boolean'
      default: true
    openOnNewMessage:
      type: 'boolean'
      default: false

  atomChatView: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable

    @createView()

    @subscriptions.add atom.commands.add 'atom-workspace', "atom-chat:toggle", =>
      @atomChatView.toggle()

  createView: ->
    unless @atomChatView?
      AtomChatView = require './atom-chat-view'
      @atomChatView = new AtomChatView()
    @atomChatView

  deactivate: ->
    @atomChatView.deactivate()
    @subscriptions?.dispose()
    @subscriptions = null

  serialize: ->
    atomChatViewState: @atomChatView.serialize()
