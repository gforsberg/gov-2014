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
  # State variables
  internal:
    memberRegistration:
      type: String
      # TODO: Change these to be meaningful.
      enum: [
        "New group - Unchecked",
        "Edited - Unchecked",
        "New group - Reviewed",
        "Group waiting for info",
        "Group - Complete"
      ]
      default: "New group - Unchecked"
    workshopRegistration:
      type: String
      # TODO: Change these to be meaningful
      enum: [
        "Not sent",
        "Sent",
        "Complete"
      ]
      default: "Not sent"
    paymentStatus:
      type: String
      # TODO: Change these to be meaningful
      enum: [
        "Need to contact",
        "Waiting",
        "Payment in mail",
        "Invoice sent",
        "Payment recieved"
      ]
      default: "Need to contact"
    notes:
      type: String
      trim: true
  # Aggregations
  _members: [
    type: ObjectId
    ref: "Member"
  ]
  _payments: [
    type: ObjectId
    ref: "Payment"
  ]
}

###
Statics
  These are model based. So you'd call `User.model.foo()` if you had a static called `foo`
###
GroupSchema.statics.register = (group, next) ->
  newGroup = new module.exports.model {
    email:        group.email
    password:     group.password
    name:         group.name
    affiliation:  group.affiliation
    address:      group.address
    city:         group.city
    province:     group.province
    postalCode:   group.postalCode
    fax:          group.fax
    phone:        group.phone
  }
  newGroup.save (err, newGroup) =>
    unless err
      next null, newGroup
    else
      next err, null

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
Pre/Post Middleware
  Middleware can be pre/post `init`, `validate`, `save`, `remove`
  NOTE: Atomic updates **do not** invoke middleware.

  Make sure to properly call next()!
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