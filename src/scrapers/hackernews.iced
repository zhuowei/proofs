{BaseScraper} = require './base'
{constants} = require '../constants'
{v_codes} = constants
{proof_text_check_to_med_id} = require '../base'

#================================================================================

exports.HackerNewsScraper = class HackerNewsScraper extends BaseScraper

  constructor: (opts) ->
    super opts

  # ---------------------------------------------------------------------------

  _check_args : (args) ->
    if not(args.username?)
      new Error "Bad args to HackerNews proof: no username given"
    else if not (args.name?) or (args.name isnt 'hackernews')
      new Error "Bad args to HackerNews proof: type is #{args.name}"
    else
      null

  # ---------------------------------------------------------------------------

  profile_url : (username) -> "https://news.ycombinator.com/user?id=#{username.toLowerCase()}"

  # ---------------------------------------------------------------------------

  hunt2 : ({username, name, proof_text_check}, cb) ->
    # calls back with err, out

    out      = {}
    rc       = v_codes.OK

    unless (err = @_check_args { username, name })?
      url = @profile_url username
      out =
        rc : rc
        api_url : url
        human_url : url
        remote_id : username
    cb err, out

  # ---------------------------------------------------------------------------

  _check_api_url : ({api_url,username}) -> api_url is @profile_url(username)

  # ---------------------------------------------------------------------------

  check_status: ({username, api_url, proof_text_check, remote_id}, cb) ->

    # calls back with a v_code or null if it was ok
    await @_get_url_body {url : api_url }, defer err, rc, html

    if rc is v_codes.OK
      search_for = proof_text_check
      if html.indexOf(search_for) < 0 then rc = v_codes.NOT_FOUND

    cb err, rc

#================================================================================