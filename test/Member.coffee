###
Member
  Tests the Member database found in `schema/Member.coffee`
###
# Third Party Dependencies
should = require("should")
mongoose = require("mongoose")
# First Party Dependencies
Member = require("../schema/Member")
Group = require("../schema/Group")
Workshop = require("../schema/Workshop")

###
Setup
  Necessary setup for tests.
###
# We use an temp database for testing this.
mongoose.connect "localhost/test", (err) ->


# Test Variables
vars = {}

###
Tests
###
describe "Member", ->
  before (done) ->
    Member.model.remove {}, (err) ->
      Group.model.findOne {}, (err, group) ->
        vars.groupId = group._id
        done()
  
  describe "Member.create", ->
    it "Should create a new member with valid info", (done) ->
      Member.model.create {
        name: "Foo"
        type: "Youth"
        gender: "Male"
        birthDate:
          day: 1
          month: "January"
          year: 1990
        phone: "(123) 123-1234"
        email: "foo@bar.baz"
        emergencyContact:
          name: "Bar"
          relation: "Also a random word."
          phone: "(123) 123-1234"
        emergencyInfo:
          medicalNum: "123 123 1234"
          allergies: ["Cake", "Potatoes"]
          conditions: ["Hacker"]
        _group: vars.groupId
      }, (err, member) =>
        should.not.exist err
        should.equal member.name, "Foo"
        should.equal member.type, "Youth"
        should.equal member.gender, "Male"
        should.equal member.birthDate.day, 1
        should.equal member.birthDate.month, "January"
        should.equal member.birthDate.year, 1990
        should.equal member.phone, "(123) 123-1234"
        should.equal member.email, "foo@bar.baz"
        should.exist member.emergencyContact
        should.exist member.emergencyInfo
        vars.memberId = member._id
        done()
    it "Should not create a new member with not valid info", (done) ->
      Member.model.create {
        name: "Foo"
        #type: "Youth"
        #gender: "Male"
        birthDate:
          day: 1
          month: "January"
          year: 1990
        phone: "(123) 123-1234"
        email: "foo@bar.baz"
        emergencyContact:
          name: "Bar"
          relation: "Also a random word."
          phone: "(123) 123-1234"
        emergencyInfo:
          medicalNum: "123 123 1234"
          allergies: ["Cake", "Potatoes"]
          conditions: ["Hacker"]
        _group: vars.groupId
      }, (err, member) =>
        should.exist err
        should.not.exist member
        done()
    it "Should add the new member to a group", (done) ->
      Group.model.findById vars.groupId, (err, group) ->
        should.not.exist err
        should.notEqual group._members.indexOf(vars.memberId), -1
        done()

  describe "Member.find -> edit -> member.save()", ->
    before (done) ->
      # Make a workshop, since we don't have one.
      Workshop.model.create {
        name: "Test Member Workshop"
        host: "Bob"
        description: "Make some beaver hats, with Bob. It'll be fantastical."
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
        vars.workshopId = workshop._id
        done()

    it "Should add members to workshops they join", (done) ->
      Member.model.findById vars.memberId, (err, member) ->
        member._workshops.push 
          _id: vars.workshopId
          session: 2
        member.save (err, member) ->
          Workshop.model.findById vars.workshopId, (err, workshop) ->
            should.not.exist err
            should.equal member._workshops.length, 1
            should.equal workshop.sessions[1]._registered.length, 1
            done()

  describe "Member.find -> member.remove()", ->
    # We want to test for multiple removals. So just remove once, test many!
    before (done) ->
      Member.model.findById vars.memberId, (err, member) ->
        vars.member = member
        member.remove (err) ->
          should.not.exist err
          done()
    it "Should remove a member from their group when they are deleted", (done) ->
      Group.model.findById vars.groupId, (err, group) ->
        should.not.exist err
        should.exist group
        should.equal group._members.indexOf(vars.member._id), -1
        done()
    it "Should remove a member from their workshops when they are deleted", (done) ->
      Workshop.model.findById vars.workshopId, (err, workshop) ->
        should.not.exist err
        should.exist workshop
        should.equal workshop.sessions[1]._registered.indexOf(vars.member._id), -1
        done()