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

  describe "Member.canRegister", ->
    testWorkshop = 0
    before (done) ->
      Workshop.model.create {
        name: "Test Member Workshop"
        host: "Bob"
        description: "Make some beaver hats, with Bob. It'll be fantastical."
        sessions: [
          session: 1
          room: "Beaver"
          venue: "Bear"
          capacity: 1
        ,
          session: 2
          room: "Beaver"
          venue: "Bear"
          capacity: 1
        ,
          session: 3
          room: "Beaver"
          venue: "Bear"
          capacity: 1
        ,
          session: 4
          room: "Beaver"
          venue: "Bear"
          capacity: 1
        ,
          session: 5
          room: "Beaver"
          venue: "Bear"
          capacity: 1
        ,
          session: 6
          room: "Beaver"
          venue: "Bear"
          capacity: 1
        ]
      }, (err, workshop) ->
        testWorkshop = workshop._id
        done()

    it "Should properly block sessions", (done) ->
      Member.model.create {
        name: "Food"
        type: "Youth"
        gender: "Male"
        birthDate:
          day: 1
          month: "January"
          year: 1990
        phone: "(123) 123-1234"
        email: "food@bar.baz"
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
        member.hasConflicts(testWorkshop, 1).should.not.be.ok # False
        member.hasConflicts(testWorkshop, 2).should.not.be.ok 
        member.hasConflicts(testWorkshop, 3).should.not.be.ok 
        member._workshops.push
          _id: testWorkshop
          session: 1
        member.save (err) ->
          member.hasConflicts(testWorkshop, 1).should.be.ok # True
          member.hasConflicts(testWorkshop, 2).should.be.ok 
          member.hasConflicts(testWorkshop, 3).should.be.ok 
          member._workshops.push
            _id: testWorkshop
            session: 5
          member.save (err) ->
            member.hasConflicts(testWorkshop, 4).should.be.ok 
            member.hasConflicts(testWorkshop, 5).should.be.ok 
            member.hasConflicts(testWorkshop, 6).should.not.be.ok 
            done()


  describe "member.addWorkshop()", ->
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
      }, (err, workshop) =>
        vars.workshopId = workshop._id
        done()

    it "Should add members to workshops they join", (done) ->
      Member.model.findById vars.memberId, (err, member) ->
        member.addWorkshop vars.workshopId, 2, (err, member) ->
          should.not.exist err
          should.notEqual member._workshops.length, 0
          done()
    it "Should not add members to workshops they can't join", (done) ->
      Member.model.findById vars.memberId, (err, member) ->
        member.addWorkshop vars.workshopId, 1, (err, member) ->
          should.exist err
          done()

  describe "Member.find -> member.remove()", ->
    testMember = 0
    # We want to test for multiple removals. So just remove once, test many!
    before (done) ->
      Member.model.findById vars.memberId, (err, member) ->
        testMember = member._id
        member.remove (err) ->
          should.not.exist err
          done()
    it "Should remove a member from their group when they are deleted", (done) ->
      Group.model.findById vars.groupId, (err, group) ->
        should.not.exist err
        should.exist group
        should.equal group._members.indexOf(testMember), -1
        done()
    it "Should remove a member from their workshops when they are deleted", (done) ->
      Workshop.model.findById vars.workshopId, (err, workshop) ->
        should.not.exist err
        should.exist workshop
        should.equal workshop.sessions[1]._registered.indexOf(testMember), -1
        done()