debug = require('debug') 'XenAPI:TemplateCollection'
Promise = require 'bluebird'
minimatch = require 'minimatch'
_ = require 'lodash'

class TemplateCollection
  Template = undefined
  session = undefined
  xenAPI = undefined

  createTemplateInstance = (template, opaqueRef) =>
    if template && template.is_a_template && !template.is_control_domain
      return new Template session, template, opaqueRef, xenAPI

  ###*
  * Construct TemplateCollection
  * @class
  * @param      {Object}   session - An instance of Session
  * @param      {Object}   Template - Dependency injection of the Template class.
  * @param      {Object}   xenAPI - An instance of XenAPI
  ###
  constructor: (_session, _Template, _xenAPI) ->
    debug "constructor()"
    unless _session
      throw Error "Must provide session"
    unless _Template
      throw Error "Must provide Template"
    unless _xenAPI
      throw Error "Must provide xenAPI"

    #These can safely go into shared class scope because this constructor is only called once.
    session = _session
    xenAPI = _xenAPI
    Template = _Template

  ###*
  * List all Templates
  * @return     {Promise}
  ###
  list: =>
    debug "list()"
    new Promise (resolve, reject) =>
      query = 'field "is_a_template" = "true"'
      session.request("VM.get_all_records_where", [query]).then (value) =>
        unless value
          reject()
        debug "Received #{Object.keys(value).length} records"

        Templates = _.map value, createTemplateInstance
        resolve _.filter Templates, (template) -> template
      .catch (e) ->
        debug e
        reject e

  listCustom: =>
    debug "listCustom()"
    new Promise (resolve, reject) =>
      query = 'field "is_a_template" = "true"'
      session.request("VM.get_all_records_where", [query]).then (value) =>
        unless value
          reject()
        debug "Received #{Object.keys(value).length} records"

        filteredValues = _.mapValues value, (template) ->
          if !template.other_config.default_template
            return template

        Templates = _.map filteredValues, createTemplateInstance
        resolve _.filter Templates, (template) -> template
      .catch (e) ->
        debug e
        reject e

  findNamed: (name) =>
    debug "findNamed(#{name})"
    new Promise (resolve, reject) =>
      @list().then (templates) =>
        matchTemplateName = (template) ->
          if minimatch(template.name, name, {nocase: true})
            return template

        matches = _.map templates, matchTemplateName
        resolve _.filter matches, (template) -> template
      .catch (e) ->
        debug e
        reject e

  findUUID: (uuid) =>
    debug "findUUID(#{uuid})"
    new Promise (resolve, reject) =>
      query = 'field "uuid"="' + uuid + '"'
      session.request("VM.get_all_records_where", [query]).then (value) =>
        unless value
          reject()

        debug "Received #{Object.keys(value).length} records"

        Templates = _.map value, createTemplateInstance
        filtered = _.filter Templates, (template) -> template
        if filtered.length > 1
          reject("Multiple Templates for UUID #{uuid}")
        else
          resolve filtered[0]
      .catch (e) ->
        debug e
        reject e

  findOpaqueRef: (opaqueRef) =>
    debug "findOpaqueRef(#{opaqueRef})"
    new Promise (resolve, reject) =>
      session.request("VM.get_record", [opaqueRef]).then (value) =>
        unless value
          reject()

        template = createTemplateInstance value, opaqueRef
        resolve template
      .catch (e) ->
        debug e
        reject e

module.exports = TemplateCollection
