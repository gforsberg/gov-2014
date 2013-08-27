###
Workshop
  Tests the Member database found in `schema/Member.coffee`
###
# Third Party Dependencies
should = require("should")
mongoose = require("mongoose")
# First Party Dependencies
Workshop = require("../schema/Workshop")

###
Setup
  Necessary setup for tests.
###
# We use an temp database for testing this.
mongoose.connect "localhost/test", (err) ->
  
###
Tests
###
describe "Workshop", ->
  before (done) ->
    Workshop.model.remove {}, done
  
  describe "Workshop.create", ->
    it "Should create a new workshop with valid info", (done) ->
      Workshop.model.create {
        name: "Making Beaver Hats with Bob"
        host: "Bob"
        description: "Make some beaver hats, with Bob. It'll be fantastical."
        website: "http://beaverhatswithbob.com"
        sessions: [
          session: 1
          room: "Beaver"
          venue: "Bear"
          capacity: 50
        ,
          session: 2
          room: "Beaver"
          venue: "Horse"
          capacity: 1900
        ]
        room: "Beaver"
        venue: "The Beaverton Hotel"
        capacity: 55
      }, (err, workshop) =>
        should.not.exist err
        should.equal workshop.name, "Making Beaver Hats with Bob"
        should.equal workshop.host, "Bob"
        should.equal workshop.description, "Make some beaver hats, with Bob. It'll be fantastical."
        should.equal workshop.website, "http://beaverhatswithbob.com"
        should.exist workshop.sessions[0]
        should.equal workshop.sessions[0].session, 1
        should.equal workshop.sessions[0].room, "Beaver"
        should.equal workshop.sessions[0].venue, "Bear"
        should.equal workshop.sessions[0].capacity, 50
        should.exist workshop.sessions[1]
        done()
    it "Should not create a new workshop with not valid info", (done) ->
      Workshop.model.create {
        #name: "Making Beaver Hats with Bob"
        #host: "Bob"
        description: "Make some beaver hats, with Bob. It'll be fantastical."
        website: "http://beaverhatswithbob.com"
        sessions: [
          session:1
          room: "Beaver"
          venue: "Bear"
          capacity: 50
          ,
          session: 2
          room: "Beaver"
          venue: "Horse"
          capacity: 1900
        ]
        room: "Beaver"
        venue: "The Beaverton Hotel"
        capacity: 55
      }, (err, workshop) =>
        should.exist err
        should.not.exist workshop
        done()