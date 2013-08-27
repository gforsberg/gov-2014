###
Payment
  Payments for groups.
  Child Of:
    * 1..1 Group
###

###
Setup
###
# Third Party Dependencies
mongoose = require("mongoose")
# Aliases
Schema   = mongoose.Schema
ObjectId = mongoose.Schema.ObjectId

###
Schema
###
PaymentSchema = new Schema {
  # Payment details
  date:
    # Why not use a Date? Because Javascript dates are gross.
    # Besides, we only care about day, month, year.
    day:
      type: Number
      required: true
      min: 1
      max: 31
    month:
      type: String
      required: true
      enum: [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December"
      ]
    year:
      type: Number
      required: true
      min: 2013 # Payments are only 2013/2014 years
      max: 2014
  amount:
    type: Number
    min: 0
    required: true
  type:
    type: String
    required: true
    enum: [
      "Cheque",
      "Money Order",
      "Invoice",
      "Credit Card",
      "Paypal"
    ]
    required: true
  description:
    # Additional notes for the payment.
    type: String
    trim: true
  _group:
    type: ObjectId
    ref: "Group"
    required: true
}

###
Statics
  These are model based. So you'd call `User.model.foo()` if you had a static called `foo`
  `MemberSchema.statics.foo =`
###
# None yet!

###
Methods
  These are document based. So you'd call `fooMember.foo()` if you had a method called `foo`
  `MemberSchema.methods.foo =`
###
# None yet!

###
Pre/Post Middleware
  Middleware can be pre/post `init`, `validate`, `save`, `remove`
  NOTE: Atomic updates **do not** invoke middleware.
  `MemberSchema.pre 'bar', (next) ->`
  `MemberSchema.post 'bar', (next) ->`
###
# None yet!

###
Validators
  Validators can be mapped to paths. It lets you validate on change.
  `MemberSchema.path('foo').validate (value) ->`
###
# None yet!

###
Export
###
# We should export both, just in case.
Payment = mongoose.model("Payment", PaymentSchema)
module.exports =
  schema: PaymentSchema
  model: Payment