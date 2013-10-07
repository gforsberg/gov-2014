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
  number:
    type: String
    required: false
    default: ""
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
PaymentSchema.pre "save", (next) ->
  Group = require("./Group")
  # Make sure their group knows the payment exists
  Group.model.findById @_group, (err, group) =>
    if err or !group?
      next err || new Error("Group doesn't exist")
    else if group._payments.indexOf(@_id) is -1
      # Not in the group!
      group._payments.push @_id
      group.save (err) ->
        unless err
          next()
        else
          next err
    else
      # In the group already.
      next()
PaymentSchema.pre "remove", (next) ->
  Group = require("./Group")
  # Remove the payment from the group
  Group.model.findById @_group, (err, group) =>
    unless !group?
      index = group._payments.indexOf @_id
      unless index is -1
        # Group exists, member is a part of it.
        group._payments.splice index, 1
        group.save (err) =>
          unless err
            next()
          else
            next err

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