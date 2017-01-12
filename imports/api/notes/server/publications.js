// All links-related publications

import { Meteor } from 'meteor/meteor';
import { check } from 'meteor/check'
import { Match } from 'meteor/check'
import { Notes } from '../notes.js';

Meteor.publish('notes.all', function () {
  return Notes.find({ owner: this.userId });
});

Meteor.publish('notes.search', function(search) {
  check(search, Match.Maybe(String));

  let query = {};
  let projection = { limit: 100 };

  if (search.indexOf('last-changed:') == 0) {
    query = {
      "updatedAt": { $gte : new Date(new Date()-60*60*1000) }
    };
  } else {
    let regex = new RegExp( search, 'i' );
    query = {
       title: regex 
    };
  }

  return Notes.find( query, projection );
});