ent = require 'ent'

class Helpers
  constructor: (@navigation) ->

  breadcrumbs: () ->
    new BreadCrumbs(this, @navigation)

  htmlTag: (tag, attribs = [], content = null, selfClose = false) ->
    html = "<#{tag}"
    
    for key, value of attribs
      html += " #{key}=\"#{ent.encode value}\""

    if content?
      selfClose = false # cannot self-close if there is content
      html += ">#{content}"

    html += if selfClose then " />" else "</#{tag}>"

    html

  renderLink: (page) ->
    attribs = href: page.uri

    classes = []
    classes.push page.class if page.class?
    classes.push 'active' if page.active
    attribs.class = classes.join ' ' if classes.length > 0

    for key in ['id', 'rel']
      if page[key]?
        attribs[key] = page[key]

    @htmlTag 'a', attribs, page.label


class BreadCrumbs
  constructor: (@helpers, @navigation) ->
    @prefix = ''
    @postfix = ''
    @separator = ' &gt; '
    @renderLinkFunc = (page) ->
      @helpers.renderLink page

  setPrefix: (@prefix) ->
    this

  setPostfix: (@postfix) ->
    this

  setSeparator: (@separator) ->
    this

  setRenderLink: (@renderLinkFunc) ->
    this

  renderLink: (page) ->
    @renderLinkFunc(page)

  render: ->
    page = @navigation.findBy 'active', true
    return '' unless page?
    
    links = [@renderLink page]
    
    while page = page.parent
      links.unshift @renderLink page
    
    "#{@prefix}#{links.join @separator}#{@postfix}"

module.exports = (navigation, namespace = 'navigation') ->
  obj = {}
  obj[namespace] = new Helpers(navigation)
  obj