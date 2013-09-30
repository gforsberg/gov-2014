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

boilerplate = {
  member: (group, email) -> {
    name: "Foo"
    type: "Youth"
    gender: "Male"
    birthDate:
      day: 1
      month: "January"
      year: 1990
    phone: "(123) 123-1234"
    email: email
    emergencyContact:
      name: "Bar"
      relation: "Also a random word."
      phone: "(123) 123-1234"
    emergencyInfo:
      medicalNum: "123 123 1234"
      allergies: ["Cake", "Potatoes"]
      conditions: ["Hacker"]
    _group: group
  }
}

###
Tests
###
describe "Member", ->
  testGroup = null
  before (done) ->
    Workshop.model.remove {}, (err) ->
      Member.model.remove {}, (err) ->
        Group.model.create {
          email:          "memberTest@bar.baz"
          password:       "foo"
          name:           "foo bar"
          affiliation:    "foo Native Friendship Centre"
          address:        "123 Foo Ave"
          city:           "Victoria"
          province:       "British Columbia"
          postalCode:     "A1B 2C3"
          fax:            ""
          phone:          "(123) 123-1234"
        }, (err, group) =>
          testGroup = group._id
          done()
  
  describe "Member.create", ->
    it "Should create a new member with valid info", (done) ->
      Member.model.create boilerplate.member(testGroup, "foo@bar.baz"), (err, member) =>
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
        done()
    it "Should not create a new member with not valid info", (done) ->
      Member.model.create {
        #name: "Foo"
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
        _group: testGroup
      }, (err, member) =>
        should.exist err
        should.not.exist member
        done()
    it "Should add the member to the group it is created with", (done) ->
      Member.model.findOne email: "foo@bar.baz", (err, members) ->
        should.not.exist err
        should.exist members._group
        Group.model.findById members._group, (err, group) ->
          should.notEqual group._members.indexOf(members._id), -1
          done()
    it "Should register EarlyBirds appropriately", (done) ->
      member = boilerplate.member(testGroup, "early@bar.baz")
      member._state = {}
      member._state.registrationDate = Date.UTC(2014,1,1,1) # Early Bird
      Member.model.create member, (err, member) ->
        should.not.exist err
        should.equal member._state.ticketType, "Early"
        done()
    it "Should register Regular Tickets appropriately", (done) ->
      member = boilerplate.member(testGroup, "early@bar.baz")
      member._state = {}
      member._state.registrationDate = Date.UTC(2014,3,1,1) # Early Bird
      Member.model.create member, (err, member) ->
        should.not.exist err
        should.equal member._state.ticketType, "Regular"
        done()
        
  describe "Member.hasConflicts", ->
    testWorkshop = null
    before (done) ->
      Workshop.model.create {
        name: "canRegister test"
        host: "Bob"
        description: "Make some beaver hats, with Bob. It'll be fantastical."
        allows: ["Youth", "Young Adult", "Young Chaperone", "Chaperone"]
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
      Member.model.create boilerplate.member(testGroup, "Food@bar.baz"), (err, member) =>
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

  describe "Member.find -> member.save()", ->
    it "Should verify completeness", (done) ->
      Member.model.create {
        name: "Foo"
        type: "Youth"
        # gender: "Male"
        birthDate:
          day: 1
          month: "January"
          year: 1990
        # phone: "(123) 123-1234"
        email: "completeness@bar.baz"
        emergencyContact:
          # name: "Bar"
          relation: "Also a random word."
          phone: "(123) 123-1234"
        emergencyInfo:
          # medicalNum: "123 123 1234"
          allergies: ["Cake", "Potatoes"]
          conditions: ["Hacker"]
        _group: testGroup
      }, (err, member) ->
        member._state.complete.should.be.false 
        member.gender = "Male"
        member.phone = "(123) 123-1234"
        member.emergencyContact.name = "Bar"
        member.emergencyInfo.medicalNum = "123 123 1234"
        member.save (err, member) ->
          should.not.exist err
          member._state.complete.should.be.true
          done()



  describe "Member.find -> member.addWorkshop()", ->
    testWorkshop = null
    testMember = null
    before (done) ->
      # Make a workshop, since we don't have one.
      Workshop.model.create {
        name: "addWorkshop test"
        host: "Bob"
        description: "Make some beaver hats, with Bob. It'll be fantastical."
        allows: ["Youth", "Young Adult", "Young Chaperone", "Chaperone"]
        sessions: [
          session: 1
          room: "Beaver"
          venue: "Bear"
          capacity: 1
        ,
          session: 6
          room: "Beaver"
          venue: "Horse"
          capacity: 50
        ]
      }, (err, workshop) =>
        testWorkshop = workshop._id
        Member.model.create boilerplate.member(testGroup, "addworkshop@bar.baz"), (err, member) ->
          should.not.exist err
          should.exist member
          testMember = member._id
          done()

    it "Should add members to workshops they join", (done) ->
      Member.model.findById testMember, (err, member) ->
        member.addWorkshop testWorkshop, 6, (err, member) ->
          should.not.exist err
          should.notEqual member._workshops.length, 0
          Workshop.model.findById testWorkshop, (err, workshop) ->
            should.notEqual workshop.session(6)._registered.indexOf(member._id), -1
            done()
    it "Should not add members to workshops they can't join", (done) ->
      Member.model.findById testMember, (err, member) ->
        member.addWorkshop testWorkshop, 4, (err, member) ->
          should.exist err
          done()
    it "Should not allow members to join if the workshop is full", (done) ->
      # Session 2 only can hold one person! Oh no!
      Member.model.findById testMember, (err, member) ->
        should.not.exist err
        should.exist member
        member.addWorkshop testWorkshop, 1, (err, member) ->
          should.not.exist err
          Member.model.create boilerplate.member(testGroup, "capTest@bar.baz"), (err, secondMember) ->
            secondMember.addWorkshop testWorkshop, 1, (err, thisFails) ->
              should.exist err
              should.equal secondMember._workshops.indexOf(testWorkshop), -1
              done()
      it "Should block members from workshops they're filtered from", (done) ->
        Workshop.model.create {
          name: "filter test"
          host: "Bob"
          description: "Make some beaver hats, with Bob. It'll be fantastical."
          allows: ["Chaperones"]
          sessions: [
            session: 1
            room: "Beaver"
            venue: "Bear"
            capacity: 1
          ,
            session: 6
            room: "Beaver"
            venue: "Horse"
            capacity: 50
          ]
        }, (err, workshop) ->
          member.addWorkshop workshop._id, 6, (err, member) ->
          should.exist err
          done()


  describe "Member.find -> member.removeWorkshop()", ->
    testMember = null
    testWorkshop = null
    before (done) ->
      Member.model.create boilerplate.member(testGroup, "removeWorkshop@bar.baz"), (err, member) ->
        should.not.exist err
        should.exist member
        testMember = member._id
        Workshop.model.create {
          name: "removeWorkshop test"
          host: "Bob"
          description: "Make some beaver hats, with Bob. It'll be fantastical."
          allows: ["Youth", "Young Adult", "Young Chaperone", "Chaperone"]
          sessions: [
            session: 1
            room: "Beaver"
            venue: "Bear"
            capacity: 1
          ,
            session: 6
            room: "Beaver"
            venue: "Horse"
            capacity: 50
          ]
        }, (err, workshop) ->
          testWorkshop = workshop._id
          should.not.exist err
          should.exist workshop
          done()
    it "Should remove members from workshops.", (done) ->
      Member.model.findById testMember, (err, member) ->
        member.addWorkshop testWorkshop, 6, (err, member) ->
          should.not.exist err
          should.exist member
          member.addWorkshop testWorkshop, 1, (err, member) ->
            should.not.exist err
            should.exist member
            member.removeWorkshop testWorkshop, 6, (err, member) ->
              should.not.exist err
              should.equal member._workshops.filter( (val) ->
                return not (val.session == 6 and val._id.equals(testWorkshop))
              ).length, 1
              Workshop.model.findById testWorkshop, (err, workshop) ->
                should.equal workshop.session(6)._registered.indexOf(member._id), -1
                done()


  describe "Member.find -> member.remove()", ->
    testMember = null
    testWorkshop = null
    testSession = null
    # We want to test for multiple removals. So just remove once, test many!
    before (done) ->
      Member.model.create boilerplate.member(testGroup, "remove@bar.baz") , (err, member) ->
        testMember = member._id
        # Make a workshop to model.
        Workshop.model.create {
          name: "remove member test"
          host: "Bob"
          description: "Make some beaver hats, with Bob. It'll be fantastical."
          allows: ["Youth", "Young Adult", "Young Chaperone", "Chaperone"]
          sessions: [
            session: 1
            room: "Beaver"
            venue: "Bear"
            capacity: 1
          ,
            session: 4
            room: "Beaver"
            venue: "Horse"
            capacity: 50
          ]
        }, (err, workshop) =>
          should.not.exist err
          should.exist workshop
          testWorkshop = workshop._id
          member.addWorkshop testWorkshop, 1, (err, member) ->
            member.addWorkshop testWorkshop, 4, (err, member) ->
              should.not.exist err
              member.remove (err) ->
                should.not.exist err
                done()
    it "Should remove a member from their group when they are deleted", (done) ->
      Group.model.findById testGroup, (err, group) ->
        should.not.exist err
        should.exist group
        should.equal group._members.indexOf(testMember), -1
        done()
    it "Should remove a member from their workshops when they are deleted", (done) ->
      Workshop.model.findById testWorkshop, (err, workshop) ->
        should.not.exist err
        should.exist workshop
        should.equal workshop.session(1)._registered.indexOf(testMember), -1
        should.equal workshop.session(4)._registered.indexOf(testMember), -1
        done()