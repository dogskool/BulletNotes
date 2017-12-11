import { Meteor } from 'meteor/meteor'
import { _ } from 'meteor/underscore'
import { ValidatedMethod } from 'meteor/mdg:validated-method'
import SimpleSchema from 'simpl-schema'
import { DDPRateLimiter } from 'meteor/ddp-rate-limiter'

import { Notes } from '/imports/api/notes/notes.coffee'
import { Files } from '../files.coffee'

export remove = new ValidatedMethod
  name: 'files.remove'
  validate: new SimpleSchema
    id: Notes.simpleSchema().schema('_id')
  .validator
    clean: yes
    filter: no
  run: ({ id }) ->
    file = Files.findOne id
    if @userId != file.userId
      throw new (Meteor.Error)('not-authorized')

    Files.remove { _id: id }

export setNote = new ValidatedMethod
  name: 'files.setNote'
  validate: new SimpleSchema
    fileId: Notes.simpleSchema().schema('_id')
    noteId: Notes.simpleSchema().schema('_id')
  .validator
    clean: yes
    filter: no
  run: ({ fileId, noteId }) ->
    file = Files.findOne fileId
    if file.owner != Meteor.userId()
      throw new (Meteor.Error)('not-authorized')

    Files.update fileId, $set:
      noteId: noteId

export fileSize = new ValidatedMethod
  name: 'files.size'
  validate: null
  run: () ->
    console.log Meteor.userId()
    files = Files.find
      owner: Meteor.userId()
    console.log files.count()
    size = 0
    files.forEach (doc)->
      size += BSON.calculateObjectSize doc
    console.log "Got size: ",size


# Get note of all method names on Notes
NOTES_METHODS = _.pluck([
  remove
  setNote
], 'name')

if Meteor.isServer
  # Only allow 5 notes operations per connection per second
  DDPRateLimiter.addRule {
    name: (name) ->
      _.contains NOTES_METHODS, name

    # Rate limit per connection ID
    connectionId: ->
      yes

  }, 5, 1000
