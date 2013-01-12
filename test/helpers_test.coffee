lib = require '../lib'
Navigation = lib.Navigation
Page = lib.Page
helpers = lib.helpers
cheerio = require 'cheerio'

describe 'Helpers', ->
  beforeEach ->
    this.navigation = new Navigation "#{__dirname}/configs/nav.js"
    this.helpers = helpers(this.navigation)

  describe 'render()', ->
    it 'renders links to all parent pages including current', ->
      this.navigation.activateByUri '/page1/page2'
      html = this.helpers.navigation.breadcrumbs().render()
      $ = cheerio.load html
      $('a[href="/page1/page2"]').should.have.length 1
      $('a[href="/page1"]').should.have.length 1

    it 'orders links from root to current', ->
      this.navigation.activateByUri '/page1/page2'
      html = this.helpers.navigation.breadcrumbs().render()
      html.should.match /href="\/page1".+href="\/page1\/page2"/

  describe 'setPrefix()', ->
    it 'renders prefix before links', ->
      this.navigation.activateByUri '/page1/page2'
      html = this.helpers.navigation.breadcrumbs().setPrefix('::PREFIX::').render()
      html.should.match /^::PREFIX::/

  describe 'setPostfix()', ->
    it 'renders postfix after links', ->
      this.navigation.activateByUri '/page1/page2'
      html = this.helpers.navigation.breadcrumbs().setPostfix('::POSTFIX::').render()
      html.should.match /::POSTFIX::$/

  describe 'setSeparator()', ->
    it 'renders separator between links', ->
      this.navigation.activateByUri '/page1/page2'
      html = this.helpers.navigation.breadcrumbs().setSeparator('::SEPARATOR::').render()
      html.should.match /::SEPARATOR::/

  describe 'setRenderLink()', ->
    it 'allows providing a custom function to render a page link', ->
      this.navigation.activateByUri '/page1/page2'
      html = this.helpers.navigation.breadcrumbs().setRenderLink((page) ->
        "::RENDERLINK::#{page.id}::RENDERLINK::"
      ).render()
      html.should.match /::RENDERLINK::page2::RENDERLINK::/