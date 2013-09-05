###
Payment
  Tests the Payment database found in `schema/Payment.coffee`
###
# Third Party Dependencies
should = require("should")
mongoose = require("mongoose")
# First Party Dependencies
Payment = require("../schema/Payment")
Group = require("../schema/Group")

###
Setup
  Necessary setup for tests.
###
# We use an temp database for testing this.
mongoose.connect "localhost/test", (err) ->
  
###
Tests
###
describe "Payment", ->
  testGroup = null
  testPayment = null
  before (done) ->
    Payment.model.remove {}, (err) ->
      should.not.exist err
      Group.model.create {
        email:          "paymentTest@bar.baz"
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
        should.exist group
        testGroup = group._id
        done()
  
  describe "Payment.create", ->
    it "Should create a new payment with valid info, and assign it to the group", (done) ->
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
        should.equal payment.date.day, 1
        should.equal payment.date.month, "January"
        should.equal payment.date.year, 2014
        should.equal payment.amount, 50
        should.equal payment.type, "Paypal"
        should.equal payment.description, "A test payment."
        testPayment = payment._id
        Group.model.findById testGroup, (err, group) ->
          should.equal group._payments.length, 1
          done()

    it "Should not create a new payment with not valid info", (done) ->
      Payment.model.create {
        date:
          #day: 1
          month: "January"
          year: 2014
          amount: 50
        type: "Paypal"
        description: "A test payment."
        _group: new mongoose.Types.ObjectId
      }, (err, payment) =>
        should.exist err
        should.not.exist payment
        done()
  describe "Payment.find -> payment.remove()", ->
    it "Should remove the payment from the group when deleted", (done) ->
      Payment.model.findById testPayment, (err, payment) ->
        should.not.exist err
        should.exist payment
        payment.remove (err) ->
          should.not.exist err
          Group.model.findById testGroup, (err, group) ->
            should.equal group._payments.length, 0
            done()