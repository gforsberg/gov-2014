###
Member
  Tests the Member database found in `schema/Member.coffee`
###
# Third Party Dependencies
should = require("should")
mongoose = require("mongoose")
# First Party Dependencies
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
describe "Member", ->
  before (done) ->
    Member.model.remove {}, done
  
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
        _group: new mongoose.Types.ObjectId
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
        _group: new mongoose.Types.ObjectId
      }, (err, member) =>
        should.exist err
        should.not.exist member
        done()