###
Group
  Tests the Group database found in `schema/Group.coffee`
###
# Third Party Dependencies
should = require("should")
mongoose = require("mongoose")
# First Party Dependencies
Group = require("../schema/Group")

###
Setup
  Necessary setup for tests.
###
# We use an temp database for testing this.
console.log mongoose.connections?.length
unless mongoose.connections?.length > 1
  mongoose.connect "localhost/test", (err) ->
    console.log err if err

###
Tests
###
describe "Group", ->
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