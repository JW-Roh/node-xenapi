chai = require 'chai'
chaiAsPromised = require 'chai-as-promised'
expect = chai.expect
sinon = require 'sinon'
sinonChai = require 'sinon-chai'
Promise = require 'bluebird'

chai.use sinonChai
chai.use chaiAsPromised

describe "VIF", ->
  session = undefined
  VIF = undefined
  XenAPI = undefined

  beforeEach ->
    session =
      request: ->

    VIF = require '../../lib/Models/VIF'

    XenAPI =
      'session': session

  describe "constructor", ->
    key = undefined

    beforeEach ->
      key = 'OpaqueRef:abcd'

    afterEach ->

    it "should throw unless session is provided", ->
      expect(-> new VIF()).to.throw /Must provide `session`/

    it "should throw unless vif is provided", ->
      expect(-> new VIF session).to.throw /Must provide `vif`/

    it "should throw unless opaqueRef is provided", ->
      expect(-> new VIF session, {}).to.throw /Must provide `opaqueRef`/

    it "should throw unless xenAPI is provided", ->
      expect(-> new VIF session, {}, "OpaqueRef").to.throw /Must provide `xenAPI`/
