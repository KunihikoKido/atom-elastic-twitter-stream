{ScrollView} = require 'atom-space-pen-views'

class LoadingView extends ScrollView
  @content: ->
    @div class: "padded", =>
      @div class: "inset-panel", =>
        @div class: "panel-heading", "Elastic Twitter Stream"
        @div class: "panel-body padded", =>
          @span class: "loading loading-spinner-small inline-block"
          @span class: "message", "..."

  initialize: ->
    super
    # @panel ?= atom.workspace.addBottomPanel(item: this)

  updateMessage: (message) ->
    @panel ?= atom.workspace.addBottomPanel(item: this)
    @find(".message").text(message)

  finish: ->
    setTimeout =>
      @destroy()
    , 1 * 1000

  destroy: ->
    @panel?.destroy()
    @panel = null

module.exports = LoadingView = new LoadingView()
