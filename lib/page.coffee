class Page
  constructor: (data = {}) ->
    @id = data.id
    @class = data.class
    @uri = data.uri
    @label = data.label
    @active = !!data.active
    @rel = data.rel
    @hidden = !!data.hidden
    @pages = []

    if Array.isArray data.pages
      for page in data.pages
        @addPage page
    else if data.pages instanceof Object
      for id, page of data.pages
        page.id = id
        @addPage page

  match: (uri) ->
    @uri == uri

  addPage: (page) ->
    page = new Page page unless page instanceof Page
    @pages.push page

  addPages: (pages) ->
    for page in pages
      @addPage page

  findById: (id) ->
    found = null
    return this if @id == id

    for page in @pages
      found = page.findById id
      break if found

    found

  findByUri: (uri) ->
    found = null
    return this if @uri == uri

    for page in @pages
      found = page.findByUri uri
      break if found

    found

  isActive: ->
    active = false
    return true if @active

    for page in @pages
      active = page.isActive()
      break if active

    active

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
  
module.exports = Page