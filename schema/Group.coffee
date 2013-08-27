###
Group
  The main group object.
  Has:
    * 1..* Members
    * 1..* Payments
###

###
Setup
###
# Third Party Dependencies
mongoose = require("mongoose")
bcrypt   = require("bcrypt")
# First Party Dependencies
Member   = require("./Member")
# Aliases
Schema   = mongoose.Schema
ObjectId = mongoose.Schema.ObjectId

###
Schema
###
GroupSchema = new Schema {
  # Group Details
  email:
    type: String
    match: /.*@.*\..*/ # Should match most emails.
    trim: true
    required: true
    lowercase: true
    index:
      unique: true # No duplicates allowed.
  hash:
    type: String
  password: # NOTE: This isn't stored, it exists for our validation hook.
    type: String
    trim: true
  name:
    type: String
    trim: true
    required: true
  affiliation:
    type: String
    trim: true
    required: true
  address:
    type: String
    trim: true
    required: true
  city:
    type: String
    trim: true
    required: true
  province:
    type: String
    trim: true
    required: true
    enum: [
      "British Columbia",
      "Alberta",
      "Saskatchewan",
      "Manitoba",
      "Ontario",
      "Quebec",
      "New Brunswick",
      "Nova Scotia",
      "Prince Edward Island",
      "Newfoundland and Labrador",
      "Nunavut",
      "Northwest Territories",
      "Yukon",
      "Other (Outside Canada)"
    ]
  postalCode:
    type: String
    trim: true
    required: true
  fax:
    type: String
    trim: true
  phone:
    type: String
    trim: true
    required: true
  registrationDate: 
    type: Date
    default: Date.now
    required: true
  # Private things we shouldn't accept values for during creation.
  _notes:
    type: String
    trim: true
  # State variables
  _state:
    registration:
      type: String
      default: "New group - Unchecked"
      # TODO: Change these to be meaningful.
      enum: [
        "New group - Unchecked",
        "Edited - Unchecked",
        "New group - Reviewed",
        "Group waiting for info",
        "Group - Complete"
      ]
    workshops:
      type: String
      default: "Not sent"
      # TODO: Change these to be meaningful
      enum: [
        "Not sent",
        "Sent",
        "Complete"
      ]
    payment:
      type: String
      default: "Need to contact"
      # TODO: Change these to be meaningful
      enum: [
        "Need to contact",
        "Waiting",
        "Payment in mail",
        "Invoice sent",
        "Payment recieved"
      ]
  # Aggregations
  _members: 
    type: [
      type: ObjectId
      ref: "Member"
    ]
    default: []
  _payments: 
    type: [
      type: ObjectId
      ref: "Payment"
    ]
    default: []
}

###
Statics
  These are model based. So you'd call `User.model.foo()` if you had a static called `foo`
  `MemberSchema.statics.foo =`
###
# None yet!

GroupSchema.statics.login = (email, password, next) ->
  @.findOne email: email, (err, group) ->
    unless err or !group? or Object.keys(group).length is 0
      bcrypt.compare password, group.hash, (err, valid) ->
        unless not valid
          next null, group
        else
          next err or new Error("Wrong Password"), null
    else
      next err or new Error("Doesn't exist!"), null

###
Methods
  These are document based. So you'd call `fooMember.foo()` if you had a method called `foo`
  `MemberSchema.methods.foo =`
###
# None yet!

###
Validators
  Validators can be mapped to paths. It lets you validate on change.
  `MemberSchema.path('foo').validate (value) ->`
###
# None yet!

###
Pre/Post Middleware
  Middleware can be pre/post `init`, `validate`, `save`, `remove`
  NOTE: Atomic updates **do not** invoke middleware.
  `MemberSchema.pre 'bar', (next) ->`
  `MemberSchema.post 'bar', (next) ->`
###
GroupSchema.pre 'validate', (next) ->
  # If the `password` attribute is set, hash it and clear it.
  if @password
    bcrypt.hash @password, 10, (err, @hash) =>
      unless err
        @password = undefined # Get rid of the password.
        next()
      else
        next(err)
  else
    next()

###
Export
###
# We should export both, just in case.
Group = mongoose.model("Group", GroupSchema)
module.exports =
  schema: GroupSchema
  model: Group