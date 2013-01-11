lib = require '../lib'
Page = lib.Page

describe 'Page', ->
  properties =
    id:       'test-id'
    uri:      '/test-uri'
    class:    'test-class'
    label:    'Test Label'
    rel:      'test-rel'
    hidden:   true

  describe 'properties', ->
    beforeEach ->
      this.page = new Page properties

    for key, value of properties
      do (key, value) ->
        it "has property #{key}", ->
          this.page.should.have.property key, value

    it 'accepts array of Page objects', ->
      data = pages: [new Page, new Page]
      page = new Page data
      page.pages.should.have.lengthOf 2
      page.pages[0].should.be.instanceOf Page
      page.pages[1].should.be.instanceOf Page

    it 'creates Page objects if passed in as plain objects', ->
      data = pages: [
        {id: 'test-id-1'},
        {id: 'test-id-2'}
      ]
      page = new Page data
      page.pages.should.have.lengthOf 2
      page.pages[0].should.be.instanceOf Page
      page.pages[1].should.be.instanceOf Page

  describe 'match()', ->
    beforeEach ->
      this.page = new Page properties

    it 'is true if uri matches', ->
      this.page.match('/test-uri').should.be.true

    it 'is false if uri does not match', ->
      this.page.match('/not-match').should.be.false

  describe 'addPage()', ->
    it 'can add page to contents', ->
      page = new Page
      page = new Page id: 'test-id'
      page.pages.should.be.lengthOf 0
      page.addPage page
      page.pages.should.be.lengthOf 1
      page.pages[0].should.be.instanceOf Page
      page.pages[0].should.have.property 'id', 'test-id'

    it 'creates Page object if plain object is passed in', ->
      page = new Page
      data = id: 'test-id'
      page.pages.should.be.lengthOf 0
      page.addPage data
      page.pages[0].should.be.instanceOf Page

  describe 'addPages()', ->
    it 'adds several pages to contents', ->
      page = new Page
      page1 = new Page
      page2 = new Page active: true
      page.addPages [page1, page2]
      page.pages.should.be.lengthOf 2

  describe 'isActive()', ->
    it 'is false by default', ->
      page = new Page
      page.isActive().should.be.false

    it 'is true if page is active', ->
      page = new Page active: true
      page.isActive().should.be.true

    it 'is false if page is not active', ->
      page = new Page active: false
      page.isActive().should.be.false

    it 'is true if at least one immediate descendent page is active', ->
      page = new Page
      page1 = new Page
      page2 = new Page active: true
      page.addPages [page1, page2]
      page.isActive().should.be.true

    it 'is true if at least one immediate descendent page contains an active page', ->
      page = new Page
      subPage = new Page
      subPage.addPage new Page
      subPage.addPage new Page active: true
      page.addPage subPage
      page.isActive().should.be.true

    it 'is true if at least one deep descendent page is active', ->
      page = new Page
      subPage = new Page
      subSubPage = new Page
      subSubPage.addPage new Page
      subSubPage.addPage new Page active: true
      subPage.addPage subSubPage
      page.addPage subPage
      page.isActive().should.be.true

    it 'is false if absolutely no descendent pages are active', ->
      page = new Page
      subPage = new Page
      subSubPage = new Page
      subSubPage.addPage new Page
      subSubPage.addPage new Page
      subPage.addPage subSubPage
      page.addPage subPage
      page.isActive().should.be.false

  describe 'removePage()', ->
    beforeEach ->
      data =
        id: 'top-level-page'
        pages: 
          '2nd-level-page':
            pages: 
              '3rd-level-page': {}
              'another-3rd-level-page': {}
          'another-2nd-level-page': {}
      
      this.page = new Page data

    it 'returns false if page is not found', ->
      page = new Page
      removed = this.page.remove page
      removed.should.be.false

    it 'removes page by reference', ->
      page = this.page.pages[1]
      this.page.pages.should.have.lengthOf 2
      removed = this.page.remove page
      removed.should.be.true
      this.page.pages.should.have.lengthOf 1

    it 'removes nested page by reference', ->
      page = this.page.findById '3rd-level-page'
      this.page.pages[0].pages.should.have.lengthOf 2
      removed = this.page.remove page
      removed.should.be.true
      this.page.pages[0].pages.should.have.lengthOf 1
