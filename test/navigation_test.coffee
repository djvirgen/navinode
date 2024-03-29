require 'js-yaml'

lib = require '../lib'
Navigation = lib.Navigation
Page = lib.Page

describe 'Navigation', ->
  config =
    home:
      label: 'home'
      uri: '/'
    page1:
      label: 'page1'
      uri: '/page1'
      pages:
        page2:
          label: 'page2'
          uri: '/page1/page2'

  it 'has pages property', ->
    navigation = new Navigation
    navigation.should.have.property 'pages'
    navigation.pages.should.have.lengthOf 0

  it 'creates top level pages from config', ->
    navigation = new Navigation config
    navigation.should.have.property 'pages'
    navigation.pages[0].should.have.property 'label', 'home'

  it 'creates top level pages from config 2', ->
    navigation = new Navigation config
    navigation.should.have.property 'pages'
    navigation.pages[0].should.have.property 'label', 'home'
    navigation.pages[1].should.have.property 'label', 'page1'

  it 'creates sub-top level pages from config', ->
    navigation = new Navigation config
    navigation.should.have.property 'pages'
    navigation.pages[0].should.have.property 'label', 'home'
    navigation.pages[1].should.have.property 'label', 'page1'
    navigation.pages[1].pages[0].should.have.property 'label', 'page2'

  it 'auto-imports yaml config file', ->
    navigation = new Navigation "#{__dirname}/configs/nav.yaml"
    navigation.should.have.property 'pages'
    navigation.pages[0].should.have.property 'label', 'home'
    navigation.pages[1].should.have.property 'label', 'page1'
    navigation.pages[1].pages[0].should.have.property 'label', 'page2'

  it 'auto-imports js config file', ->
    navigation = new Navigation "#{__dirname}/configs/nav.js"
    navigation.should.have.property 'pages'
    navigation.pages[0].should.have.property 'label', 'home'
    navigation.pages[1].should.have.property 'label', 'page1'
    navigation.pages[1].pages[0].should.have.property 'label', 'page2'

  it 'auto-imports coffee config file', ->
    navigation = new Navigation "#{__dirname}/configs/nav.coffee"
    navigation.should.have.property 'pages'
    navigation.pages[0].should.have.property 'label', 'home'
    navigation.pages[1].should.have.property 'label', 'page1'
    navigation.pages[1].pages[0].should.have.property 'label', 'page2'

  describe 'findById()', ->
    beforeEach ->
      this.nav = new Navigation "#{__dirname}/configs/nav.yaml"

    it 'finds page by id', ->
      page = this.nav.findById 'home'
      page.should.be.ok
      page.should.have.property 'id', 'home'

    it 'finds sub-page by id', ->
      page = this.nav.findById 'page2'
      page.should.be.ok
      page.should.have.property 'id', 'page2'

  describe 'findByUri()', ->
    beforeEach ->
      this.nav = new Navigation "#{__dirname}/configs/nav.yaml"

    it 'finds page by uri', ->
      page = this.nav.findByUri '/'
      page.should.be.ok
      page.should.have.property 'id', 'home'

    it 'finds sub-page by uri', ->
      page = this.nav.findByUri '/page1/page2'
      page.should.be.ok
      page.should.have.property 'id', 'page2'

  describe 'activateByUri()', ->
    beforeEach ->
      this.nav = new Navigation "#{__dirname}/configs/nav.yaml"

    it 'activates page by uri', ->
      this.nav.activateByUri '/'
      page = this.nav.findByUri '/'
      page.isActive().should.be.true

    it 'activates sub-page by uri', ->
      this.nav.activateByUri '/page1/page2'
      page = this.nav.findByUri '/page1/page2'
      page.isActive().should.be.true

  describe 'remove()', ->
    beforeEach ->
      this.nav = new Navigation "#{__dirname}/configs/nav.yaml"

    it 'removes page by reference', ->
      page = this.nav.pages[1]
      this.nav.pages.should.have.lengthOf 2
      removed = this.nav.remove page
      removed.should.be.true
      this.nav.pages.should.have.lengthOf 1

    it 'removes nested page by reference', ->
      page = this.nav.findById 'page3'
      this.nav.pages[1].pages.should.have.lengthOf 2
      removed = this.nav.remove page
      removed.should.be.true
      this.nav.pages[1].pages.should.have.lengthOf 1

  describe 'middleware()', ->
    beforeEach ->
      this.nav = new Navigation "#{__dirname}/configs/nav.yaml"

    it 'activates page based on current path', (done) ->
      req = {url: '/page1/page2'}
      res = {}
      this.nav.middleware req, {}, =>
        page = this.nav.findByUri '/page1/page2'
        page.isActive().should.be.true
        done()