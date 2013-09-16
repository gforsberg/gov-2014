###
Group
  Tests the Group database found in `schema/Group.coffee`
###
# Third Party Dependencies
should = require("should")
mongoose = require("mongoose")
# First Party Dependencies
Group = require("../schema/Group")
Member = require("../schema/Member")
Payment = require("../schema/Payment")

###
Setup
  Necessary setup for tests.
###
# We use an temp database for testing this.
mongoose.connect "localhost/test", (err) ->

boilerplate = {
  member: (group, email) -> {
    name: "Foo"
    type: "Young Adult"
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
    _state:
      ticketType: "Regular"
  }
}

###
Tests
###
describe "Group", ->
  testGroup = null
  before (done) ->
    Group.model.remove {}, done

  describe "Group.create", ->
    it "Should register new groups with valid info", (done) ->
      Group.model.create {
        email:          "foo@bar.baz"
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
        should.equal group.email, "foo@bar.baz"
        should.exist group.hash
        should.not.exist group.password
        should.equal group.name, "foo bar"
        should.equal group.affiliation, "foo Native Friendship Centre"
        should.equal group.address, "123 Foo Ave"
        should.equal group.province, "British Columbia"
        should.equal group.postalCode, "A1B 2C3"
        should.exist group.fax
        should.equal group.phone, "(123) 123-1234"
        testGroup = group._id
        done()
    it "Should not register existing groups with valid info", (done) ->
      # This should exist from our first test.
      Group.model.create {
        email:          "foo@bar.baz"
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
        should.exist err
        should.not.exist group
        done()
    it "Should not register new groups with not valid info", (done) ->
      # This should exist from our first test.
      Group.model.create {
        email:          "foo@bar.baz"
        password:       "foo"
        name:           "foo bar"
        affiliation:    "foo Native Friendship Centre"
        #address:        "123 Foo Ave"
        #city:           "Victoria"
        province:       "British Columbia"
        postalCode:     "A1B 2C3"
        fax:            ""
        phone:          "(123) 123-1234"
      }, (err, group) =>
        should.exist err
        should.not.exist group
        done()

  describe "Group.login", ->
    it "Should log in existing users with valid info", (done) ->
      Group.model.login "foo@bar.baz", "foo", (err, group) ->
        should.exist group
        should.not.exist err
        should.equal group.email, "foo@bar.baz"
        done()
    it "Should not log in existing users with invalid info", (done) ->
      Group.model.login "foo@bar.baz", "wrong_password", (err, group) ->
        should.not.exist group
        done()
    it "Should not log in new users", (done) ->
      Group.model.login "new@user.ca", "", (err, group) ->
        should.not.exist group
        should.exist err
        done()

  describe "Group.find -> Edit -> Group.save()", ->
    it "Should allow the group to edit it's details, including password", (done) ->
      Group.model.findById testGroup, (err, group) ->
        should.not.exist err
        should.exist group
        group.password = "potato"
        group.save (err) ->
          should.not.exist err
          Group.model.login "foo@bar.baz", "potato", (err, group) ->
            should.not.exist err
            should.exist group
            group.password = "foo"
            group.save (err) ->
              should.not.exist err
              done()

  describe "Group.find -> group.getCost()", ->
    before (done) ->
      Group.model.create {
        email:          "costTest@bar.baz"
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
        should.not.exist err
        testGroup = group._id
        done()
    it "Should accurately price a single member", (done) ->
      theMember = boilerplate.member(testGroup, "single@bar.baz")
      theMember._state.ticketType = "Early"
      Member.model.create theMember, (err, member) ->
        should.not.exist err
        should.exist member
        Group.model.findById testGroup, (err, group) ->
          group.getCost (err, cost) ->
            should.equal cost, 125
            done()
    it "Should accurately price four members", (done) ->
      # Add three more.
      theMember = boilerplate.member(testGroup, "single@bar.baz")
      theMember._state.ticketType = "Early"
      Member.model.create theMember, (err, member) ->
        should.not.exist err
        should.exist member
        theMember = boilerplate.member(testGroup, "single@bar.baz")
        theMember._state.ticketType = "Early"
        Member.model.create theMember, (err, member) ->
          should.not.exist err
          should.exist member
          theMember = boilerplate.member(testGroup, "single@bar.baz")
          theMember._state.ticketType = "Early"
          Member.model.create theMember, (err, member) ->
            should.not.exist err
            should.exist member
            # Test
            Group.model.findById testGroup, (err, group) ->
              group.getCost (err, cost) ->
                should.equal cost, 125 * 4
                done()
    it "Should accurately price five members", (done) -> 
      # Add 2 more
      theMember = boilerplate.member(testGroup, "single@bar.baz")
      theMember._state.ticketType = "Early"
      Member.model.create theMember, (err, member) ->
        should.not.exist err
        should.exist member
        Group.model.findById testGroup, (err, group) ->
          group.getCost (err, cost) ->
            should.equal cost, 125 * 5
            done()
    it "Should accurately price six members", (done) -> 
      # Add 2 more
      theMember = boilerplate.member(testGroup, "single@bar.baz")
      theMember._state.ticketType = "Early"
      Member.model.create theMember, (err, member) ->
        should.not.exist err
        should.exist member
        Group.model.findById testGroup, (err, group) ->
          group.getCost (err, cost) ->
            should.equal cost, 125 * 5 # They should get one free!
            done()
    it "Should accurately price seven members", (done) -> 
      # Add 2 more
      theMember = boilerplate.member(testGroup, "single@bar.baz")
      theMember._state.ticketType = "Early"
      Member.model.create theMember, (err, member) ->
        should.not.exist err
        should.exist member
        Group.model.findById testGroup, (err, group) ->
          group.getCost (err, cost) ->
            should.equal cost, 125 * 6 # They should get one free!
            done()
    it "Should accurately price eight members", (done) -> 
      # Add 2 more
      theMember = boilerplate.member(testGroup, "single@bar.baz")
      theMember._state.ticketType = "Early"
      Member.model.create theMember, (err, member) ->
        should.not.exist err
        should.exist member
        Group.model.findById testGroup, (err, group) ->
          group.getCost (err, cost) ->
            should.equal cost, 125 * 7 # They should get one free!
            done()
    it "Should accurately price nine members", (done) -> 
      # Add 2 more
      theMember = boilerplate.member(testGroup, "single@bar.baz")
      theMember._state.ticketType = "Early"
      Member.model.create theMember, (err, member) ->
        should.not.exist err
        should.exist member
        Group.model.findById testGroup, (err, group) ->
          group.getCost (err, cost) ->
            should.equal cost, 125 * 8 # They should get one free!
            done()
    it "Should accurately price ten members", (done) -> 
      # Add 2 more
      theMember = boilerplate.member(testGroup, "single@bar.baz")
      theMember._state.ticketType = "Early"
      Member.model.create theMember, (err, member) ->
        should.not.exist err
        should.exist member
        Group.model.findById testGroup, (err, group) ->
          group.getCost (err, cost) ->
            should.equal cost, 125 * 9 # They should get one free!
            done()
    it "Should accurately price eleven members", (done) -> 
      # Add 2 more
      theMember = boilerplate.member(testGroup, "single@bar.baz")
      theMember._state.ticketType = "Early"
      Member.model.create theMember, (err, member) ->
        should.not.exist err
        should.exist member
        Group.model.findById testGroup, (err, group) ->
          group.getCost (err, cost) ->
            should.equal cost, 125 * 10 # They should get one free!
            done()
    it "Should accurately price twelve members", (done) -> 
      # Add 2 more
      theMember = boilerplate.member(testGroup, "single@bar.baz")
      theMember._state.ticketType = "Early"
      Member.model.create theMember, (err, member) ->
        should.not.exist err
        should.exist member
        Group.model.findById testGroup, (err, group) ->
          group.getCost (err, cost) ->
            should.equal cost, 125 * 10 # They should get one free!
            done()
    it "Should accurately price thirteen members", (done) -> 
      # Add 2 more
      theMember = boilerplate.member(testGroup, "single@bar.baz")
      theMember._state.ticketType = "Early"
      Member.model.create theMember, (err, member) ->
        should.not.exist err
        should.exist member
        Group.model.findById testGroup, (err, group) ->
          group.getCost (err, cost) ->
            should.equal cost, 125 * 11 # They should get one free!
            done()

  describe "Group.find -> group.getPaid()", ->
    before (done) ->
      Payment.model.create {
        date:
          day: 1
          month: "January"
          year: 2014
        amount: 50
        type: "Paypal"
        description: "A test payment."
        _group: testGroup
      }, (err, payment) =>
        should.not.exist err
        done()
    it "Should return the amount paid by a group (one payment)", (done) ->
      Group.model.findById testGroup, (err, group) ->
        should.not.exist err
        group.getPaid (err, paid) ->
          should.equal paid, 50
          done()
    it "Should return the amount paid by a group (two payments)", (done) ->
      Payment.model.create {
        date:
          day: 1
          month: "January"
          year: 2014
        amount: 50
        type: "Paypal"
        description: "A test payment."
        _group: testGroup
      }, (err, payment) ->
        Group.model.findById testGroup, (err, group) ->
          should.not.exist err
          should.exist group
          group.getPaid (err, paid) ->
            should.equal paid, 100
            done()

  describe "Group.find -> group.getBalance()", ->
    it "Should return the correct balance", (done) ->
      Group.model.findById testGroup, (err, group) ->
        should.not.exist err
        should.exist group
        group.getBalance (err, balance) ->
          should.equal balance, (125*11 - 100)
          done()

  describe "Group.find -> group.enoughChaperones", ->
    it "Should return false if not enough!", (done) ->
      Group.model.findById testGroup, (err, group) ->
        # Has 13 young adults right now, should be balanced.
        # First youth
        Member.model.create {
          name: "UNbalancing"
          type: "Youth"
          _group: group._id
        }, (err) ->
          Group.model.findById testGroup, (err, group) ->
            group.enoughChaperones (val) ->
              should.equal val, false
              done()
    it "Should return true if enough!", (done) ->
      Group.model.findById testGroup, (err, group) ->
        # Has 13 young adults right now, should be balanced.
        # Second youth
        Member.model.create {
          name: "Balancing"
          type: "Youth"
          _group: group._id
        }, (err) ->
          # Third youth
          Member.model.create {
            name: "Balancing"
            type: "Youth"
            _group: group._id
          }, (err) ->
            # Fourth youth
            Member.model.create {
              name: "Balancing"
              type: "Youth"
              _group: group._id
            }, (err) ->
              # Fifth youth
              Member.model.create {
                name: "Balancing"
                type: "Youth"
                _group: group._id
              }, (err) ->
                # First Chaperone
                Member.model.create {
                  name: "Balancing"
                  type: "Chaperone"
                  _group: group._id
                }, (err) ->
                  Group.model.findById testGroup, (err, group) ->
                    group.enoughChaperones (val) ->
                      should.equal val, false
                      done()
  
  describe "Group.find -> group.remove()", ->
    it "Should remove the group, it's members, and payments", (done) ->
      Group.model.findById testGroup, (err, group) ->
        should.not.exist err
        should.exist group
        group.remove (err) ->
          should.not.exist err
          Member.model.find _group: testGroup, (err, members) ->
            should.equal members.length, 0
            should.not.exist err
            Payment.model.find _group: testGroup, (err, payments) ->
              should.equal payments.length, 0
              should.not.exist err
              done()