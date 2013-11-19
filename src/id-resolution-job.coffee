# This module supplies the **IDResolutionJob** class for the **im.js**
# web-service client.
#
# These objects represent jobs submitted to the service. They supply mechanisms for
# checking the status of the job and retrieving the results, or cancelling
# the job if that is required.
#
# This library is designed to be compatible with both node.js
# and browsers.
#

{Deferred} = require('underscore.deferred')
funcutils = require './util'
intermine = exports

{get, fold} = funcutils

class CategoryResults

  constructor: (results) ->
    @[k] = v for own k, v of results

  goodMatchIds: -> @MATCH.map get 'id'

  allMatchIds: ->
    combineIds = fold (res, issueSet) => res.concat @[issueSet]?.matches?.map(get 'id') ? []
    combineIds @goodMatchIds(), ['DUPLICATE', 'WILDCARD', 'TYPE_CONVERTED', 'OTHER']

class IdResults

  constructor: (results) ->
    @[k] = v for own k, v of results

  goodMatchIds: -> (id for id in @allMatchIds when @[id].foo)

  allMatchIds: -> (k for own k of @)

class IDResolutionJob

  constructor: (@uid, @service) ->

  fetchStatus:       (cb) => @service.get("ids/#{ @uid }/status").pipe(get 'status').done(cb)

  fetchErrorMessage: (cb) => @service.get("ids/#{ @uid }/status").pipe(get 'message').done(cb)

  fetchResults:      (cb) =>
    gettingRes = @service.get("ids/#{ @uid }/result").pipe(get 'results')
    gettingVer = @service.fetchVersion()
    gettingVer.then (v) -> gettingRes.then (results) ->
      if v >= 16 then new CategoryResults(results) else new IdResults(results)

  del: (cb) => @service.makeRequest 'DELETE', "ids/#{ @uid }", {}, cb
 
  # Poll the service until the results are available.
  #
  # @example Poll a job
  #   job.poll().then (results) -> handle results
  #
  # @param [Function] onSuccess The success handler (optional)
  # @param [Function] onError The error handler for if the job fails (optional).
  # @param [Function] onProgress The progress handler to receive status updates.
  #
  # @return [Promise<Object>] A promise to yield the results.
  # @see Service#resolveIds
  poll: (onSuccess, onError, onProgress) ->
    ret = Deferred().done(onSuccess).fail(onError).progress(onProgress)
    resp = @fetchStatus()
    resp.fail ret.reject
    resp.done (status) =>
      ret.notify(status)
      switch status
        when 'SUCCESS' then @fetchResults().then(ret.resolve, ret.reject)
        when 'ERROR' then @fetchErrorMessage().then(ret.reject, ret.reject)
        else @poll ret.resolve, ret.reject, ret.notify
    return ret.promise()

IDResolutionJob::wait = IDResolutionJob::poll

IDResolutionJob.create = (service) -> (uid) -> new IDResolutionJob(uid, service)

intermine.IDResolutionJob = IDResolutionJob
