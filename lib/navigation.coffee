Page = require './page'

class Navigation
  constructor: (config = {}) ->
    @pages = []

    if typeof config == 'string'
      config = require config

    if config instanceof Object
      for key, value of config
        data = value
        data.id = key
        @pages.push new Page data

  findById: (id) ->
    @findBy 'id', id

  findByLabel: (label) ->
    @findBy 'label', label

  findByUri: (uri) ->
    @findBy 'uri', uri

  findBy: (key, value) ->
    found = null
    
    for page in @pages
      found = page.findBy key, value
      break if found

    found

  deactivateAll: ->
    for page in @pages
      page.deactivateAll()

  activateByUri: (uri) ->
    @deactivateAll()
    page = @findByUri uri
    return unless page?
    page.active = true

  remove: (page) ->
    removed = false

    for i, _page of @pages
      if _page == page
        # Found it!
        deleted = @pages.splice i, 1 # Deletes page from array
        removed = true
        break

      removed = _page.remove page
      break if removed

    removed

  middleware: ->
    (req, res, next) =>
      @activateByUri req.url
      next()

module.exports = Navigation