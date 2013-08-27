###
Payment
  Tests the Payment database found in `schema/Payment.coffee`
###
# Third Party Dependencies
should = require("should")
mongoose = require("mongoose")
# First Party Dependencies
Payment = require("../schema/Payment")

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
  before (done) ->
    Payment.model.remove {}, done
  
  describe "Payment.create", ->
    it "Should create a new payment with valid info", (done) ->
      Payment.model.create {
        date:
          day: 1
          month: "January"
          year: 2014
        amount: 50
        type: "Paypal"
        description: "A test payment."
        _group: new mongoose.Types.ObjectId
      }, (err, payment) =>
        should.not.exist err
        should.equal payment.date.day, 1
        should.equal payment.date.month, "January"
        should.equal payment.date.year, 2014
        should.equal payment.amount, 50
        should.equal payment.type, "Paypal"
        should.equal payment.description, "A test payment."
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