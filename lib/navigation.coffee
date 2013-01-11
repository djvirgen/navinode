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
    found = null

    for page in @pages
      found = page.findById id
      break if found

    found

  findByUri: (uri) ->
    found = null

    for page in @pages
      found = page.findByUri uri
      break if found

    found

  activateByUri: (uri) ->
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

  middleware: (req, res, next) ->
    @activateByUri req.url
    next()

module.exports = Navigation