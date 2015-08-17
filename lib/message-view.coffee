{$, View} = require 'atom-space-pen-views'

module.exports =
class MessageView extends View
  @content: (message) ->
    @li class: 'file entry list-item', =>
      @div class: 'message', =>
        @span class: 'user', "#{message.username}#{message.uuid}: "
        @span class: 'text', "#{message.text}"

  initialize: () ->
