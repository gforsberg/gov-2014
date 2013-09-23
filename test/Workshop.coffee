###
Workshop
  Tests the Member database found in `schema/Member.coffee`
###
# Third Party Dependencies
should = require("should")
mongoose = require("mongoose")
# First Party Dependencies
Workshop = require("../schema/Workshop")
Group = require("../schema/Group")
Member = require("../schema/Member")

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
        allows: ["Youth", "Young Adult", "Young Chaperone", "Chaperone"]
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

  describe "Workshop.find -> workshop.session()", ->
    testWorkshop = null
    before (done) ->
      Workshop.model.create {
        name: "Session test"
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
        ,
          session: 11
          room: "Potato"
          venue: "Lick"
          capacity: 55
        ]
        room: "Beaver"
        venue: "The Beaverton Hotel"
        capacity: 55
      }, (err, workshop) =>
        testWorkshop = workshop._id
        done()
    it "Should return the session of the workshop", (done) ->
      Workshop.model.findById testWorkshop, (err, workshop) ->
        should.equal workshop.session(1), workshop.sessions[0]
        should.equal workshop.session(2), workshop.sessions[1]
        should.equal workshop.session(11), workshop.sessions[2]
        done()

  describe "Workshop.find -> workshop.remove()", ->
    testWorkshop = null
    testMember = null
    testMemberTwo = null
    testGroup = null
    before (done) ->
      Workshop.model.create {
        name: "Remove test"
        host: "Bob"
        description: "Make some beaver hats, with Bob. It'll be fantastical."
        sessions: [
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
        testWorkshop = workshop._id
        Group.model.create {
          email:          "removal_of_workshop_test@bar.baz"
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
          should.not.exist err
          Member.model.create {
            name: "Foo"
            type: "Youth"
            gender: "Male"
            birthDate:
              day: 1
              month: "January"
              year: 1990
            phone: "(123) 123-1234"
            email: "Something@otherthing.com"
            emergencyContact:
              name: "Bar"
              relation: "Also a random word."
              phone: "(123) 123-1234"
            emergencyInfo:
              medicalNum: "123 123 1234"
              allergies: ["Cake", "Potatoes"]
              conditions: ["Hacker"]
            _group: group._id
          }, (err, member) =>
            testMember = member._id
            should.not.exist err
            member.addWorkshop workshop._id, 2, (err, member) =>
              should.not.exist err
              Member.model.create {
                name: "Foobie"
                type: "Youth"
                gender: "Male"
                birthDate:
                  day: 1
                  month: "January"
                  year: 1990
                phone: "(123) 123-1234"
                email: "Something@otherthing.com"
                emergencyContact:
                  name: "Bar"
                  relation: "Also a random word."
                  phone: "(123) 123-1234"
                emergencyInfo:
                  medicalNum: "123 123 1234"
                  allergies: ["Cake", "Potatoes"]
                  conditions: ["Hacker"]
                _group: group._id
              }, (err, member) =>
                testMemberTwo = member._id
                should.not.exist err
                # Second member
                member.addWorkshop workshop._id, 2, (err, member) =>
                  should.not.exist err
                  done()

    it "Should remove all the members of a workshop", (done) ->
      Workshop.model.findById testWorkshop, (err, workshop) ->
        workshop.remove (err) ->
          should.not.exist err
          Member.model.findById testMember, (err, member) ->
            should.not.exist err
            should.exist member
            should.equal member._workshops.length, 0
            Member.model.findById testMemberTwo, (err, memberTwo) ->
              should.not.exist err
              should.exist memberTwo
              should.equal memberTwo._workshops.length, 0
              done()