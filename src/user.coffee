# @source: /src/user.coffee
#
# The User class represents the authenticated user's profile
# information. It provides access to methods to read an manipulate
# a user's preferences.
#
# @author: Alex Kalderimis

{withCB, error}    = require './util'
intermine  = exports

# Simple utility to take the returned value from manageUserPreferences and
# update the preferences property on this object.
do_pref_req = (user, data, method) ->
  user.service.manageUserPreferences(method, data).then (prefs) -> user.preferences = prefs

# A representation of the user we are logged in as.
class User

  # Save references to the service, as well as
  # extracting the user's preferences from the options.
  #
  # @param [intermine.Service] service the connection to the webservice
  # @param [Object] options The data used to instantiate this object
  # @option options [String] username The user's log-in name
  # @option options [Object] preferences A key-value mapping of the preferences this user has set.
  #
  constructor: (@service, {@username, @preferences}) ->
    @hasPreferences = @preferences?
    @preferences ?= {}

  # Set a given preference.
  #
  # @param [String] key The key to set.
  # @param [String] value The value to set.
  # @return [Deferred] a promise to set a preference.
  setPreference: (key, value) =>
    if typeof key is 'string'
      data = {}
      data[key] = value
    else if not value?
      data = key
    else
      return error "Incorrect arguments to setPreference"
    @setPreferences(data)

  # Set one or more preferences, provided as an object.
  setPreferences: (prefs) =>
    do_pref_req @, prefs, 'POST'

  # Clear a preference.
  clearPreference: (key) => do_pref_req @, {key: key}, 'DELETE'

  # Clear all preferences.
  clearPreferences: () => do_pref_req @, {}, 'DELETE'

  refresh: () => do_pref_req @, {}, 'GET'

intermine.User = User

