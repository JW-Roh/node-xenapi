debug = require('debug') 'XenAPI:VBDCollection'
Promise = require 'bluebird'
minimatch = require 'minimatch'
_ = require 'lodash'

class VBDCollection
  VBD = undefined
  session = undefined
  xenAPI = undefined

  createVBDInstance = (vbd, opaqueRef) =>
    return new VBD session, vbd, opaqueRef, xenAPI

  ###*
  * Construct VBDCollection
  * @class
  * @param      {Object}   session - An instance of Session
  * @param      {Object}   VBD - Dependency injection of the VBD class.
  * @param      {Object}   xenAPI - An instance of XenAPI
  ###
  constructor: (_session, _VBD, _xenAPI) ->
    debug "constructor()"
    unless _session
      throw Error "Must provide session"
    unless _VBD
      throw Error "Must provide VBD"
    unless _xenAPI
      throw Error "Must provide xenAPI"

    #These can safely go into shared class scope because this constructor is only called once.
    session = _session
    xenAPI = _xenAPI
    VBD = _VBD

  ###*
  * List all VBDs
  * @return     {Promise}
  ###
  list: =>
    debug "list()"
    new Promise (resolve, reject) =>
      session.request("VBD.get_all_records").then (value) =>
        unless value
          reject()

        debug "Received #{Object.keys(value).length} records"

        VBDs = _.map value, createVBDInstance
        resolve _.filter VBDs, (vbd) -> vbd
      .catch (e) ->
        debug e
        reject e

  create: (vm, mode, type, vdi, userdevice) =>
    debug "create()"

    new Promise (resolve, reject) =>
      unless vdi
        vdiRef = "OpaqueRef:NULL"
        empty = true
      else
        vdiRef = vdi.opaqueRef
        empty = false
      vbd =
        VM: vm.opaqueRef,
        VDI: vdiRef,
        userdevice: userdevice,
        mode: mode,
        type: type,
        empty: empty

      newVBD = new VBD session, vbd, "OpaqueRef:NULL", xenAPI

      resolve newVBD

  findOpaqueRef: (opaqueRef) =>
    debug "findOpaqueRef(#{opaqueRef})"
    new Promise (resolve, reject) =>
      session.request("VBD.get_record", [opaqueRef]).then (value) =>
        unless value
          reject()

        template = createVBDInstance value, opaqueRef
        resolve template
      .catch (e) ->
        debug e
        reject e

  findForVM: (vm) =>
    debug "findForVM()"
    new Promise (resolve, reject) =>
      query = 'field "VM"="' + vm.opaqueRef + '"'
      session.request("VBD.get_all_records_where", [query]).then (value) =>
        unless value
          reject()

        debug "Received #{Object.keys(value).length} records"

        VBDs = _.map value, createVBDInstance
        resolve _.filter VBDs, (vbd) -> vbd
      .catch (e) ->
        debug e
        reject e

module.exports = VBDCollection
