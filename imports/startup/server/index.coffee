# This file configures the Accounts package to define the UI of the reset password email.
require './reset-password-email.js'

# Set up some rate limiting and other important security settings.
require './security.js'
require './register-api.coffee'
require './migrations.coffee'

Meteor.startup ->
  Migrations.migrateTo('latest')

  # 4:20 AM MST
  cronTime = 'at 11:20 am'
  if (Meteor.settings.public.cronTime)
    cronTime = Meteor.settings.public.cronTime

  SyncedCron.add
    name: 'Nightly dropbox export'
    schedule: (parser) ->
      parser.text cronTime
    job: ->
      Meteor.call('notes.dropboxNightly')
  SyncedCron.start()

  BrowserPolicy.framing.disallow()
  #BrowserPolicy.content.disallowInlineScripts()
  #BrowserPolicy.content.disallowEval()
  BrowserPolicy.content.allowInlineStyles()
  BrowserPolicy.content.allowFontDataUrl()
  BrowserPolicy.content.allowOriginForAll('*')
  BrowserPolicy.content.allowImageOrigin('*')
  trusted = [
    '*.cloudfront.net'
    'api.keen.io'
    '*.hotjar.com'
  ]
  _.each trusted, (origin) ->
    origin = 'https://' + origin
    BrowserPolicy.content.allowOriginForAll origin
