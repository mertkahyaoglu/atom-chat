AtomChatView = require './atom-chat-view'
{CompositeDisposable} = require 'atom'

module.exports =
  config:
    username:
      type: 'string'
      default: 'me'
    room:
      type: 'string'
      default: 'Atom'
    showOnRightSide:
      type: 'boolean'
      default: true
    openOnNewMessage:
      type: 'boolean'
      default: false

  atomChatView: null

  activate: (state) ->
    @atomChatView = new AtomChatView()
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-workspace', "atom-chat:toggle", =>
      @atomChatView.toggle()

  deactivate: ->
    @atomChatView.destroy()
    @subscriptions?.dispose()
    @subscriptions = null

  serialize: ->
    atomChatViewState: @atomChatView.serialize()
