// Generated by CoffeeScript 1.8.0
(function() {
  var chai, chaiAsPromised, expect, sinon, sinonChai;

  chai = require('chai');

  chaiAsPromised = require('chai-as-promised');

  expect = chai.expect;

  sinon = require('sinon');

  sinonChai = require('sinon-chai');

  chai.use(sinonChai);

  chai.use(chaiAsPromised);

  describe("APIClient", function() {
    var APIClient;
    APIClient = require('../lib/APIClient');
    return describe("constructor", function() {
      it("should throw unless xmlrpc is provided", function() {
        return expect(function() {
          return new APIClient();
        }).to["throw"](/Must provide xmlrpc/);
      });
      return it("should throw unless options are provided", function() {
        return expect(function() {
          return new APIClient({});
        }).to["throw"](/Must provide options/);
      });
    });
  });

}).call(this);
