{CompositeDisposable} = require 'atom'

atomChatView = null

module.exports =
  config:
    username:
      type: 'string'
      default: 'User'
      description: 'Username that will be displayed on the chat.'
    showOnRightSide:
      type: 'boolean'
      default: true
      description: 'Show panel on the right side of the workspace.'
    openOnNewMessage:
      type: 'boolean'
      default: false
      description: 'Open chat when a new message received.'

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
