{SelectListView} = require 'atom-space-pen-views'

module.exports =
class RoomListView extends SelectListView
  initialize: (@atomChat)->
    super
    console.log "room list opened"
    @addClass('rooms-selector')
    @list.addClass('mark-active')

  destroy: ->
    @cancel()

  getFilterKey: ->
    'name'

  viewForItem: (room) ->
    element = document.createElement('li')
    element.classList.add('active') if room.id is @currentRoom
    element.textContent = room.name
    element.dataset.room = room.id
    element

  cancelled: ->
    @panel?.destroy()
    @panel = null
    @currentRoom = null

  confirmed: (room) ->
    @atomChat.joinRoom room
    @cancel()

  attach: ->
    @storeFocusedElement()
    @panel ?= atom.workspace.addModalPanel(item: this)
    @focusFilterEditor()

  toggle: ->
    if @panel?
      @cancel()
    else if @atomChat
      @currentRoom = @atomChat.getCurrentRoom()
      @atomChat.getSocket().emit 'atom:rooms', (rooms) =>
         @setItems(rooms)
      @attach()
