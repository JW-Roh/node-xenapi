debug = require('debug') 'XenAPI:SRCollection'
Promise = require 'bluebird'
_ = require 'lodash'

class SRCollection
  session = undefined
  SR = undefined

  ###*
  * Construct SRCollection
  * @class
  * @param      {Object}   session - An instance of Session
  * @param      {Object}   SR - Dependency injection of the SR class.
  ###
  constructor: (_session, _SR) ->
    debug "constructor()"
    unless _session
      throw Error "Must provide session"
    else
      session = _session

    unless _SR
      throw Error "Must provide SR"
    else
      SR = _SR

  ###*
  * List all SRs
  * @return     {Promise}
  ###
  list: =>
    debug "list()"
    new Promise (resolve, reject) =>
      session.request("SR.get_all_records").then (value) =>
        unless value
          reject()

        debug "Received #{Object.keys(value).length} records"
        createSRInstance = (sr, key) =>
          return new SR session, sr, key

        SRs = _.map value, createSRInstance
        resolve _.filter SRs, (sr) -> sr
      .catch (e) ->
        debug e
        reject e

module.exports = SRCollection
