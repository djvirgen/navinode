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

  middleware: (req, res, next) ->
    @activateByUri req.url
    next()

module.exports = Navigation