###
Member
  People going to the conference. A member of a group.
###

###
Setup
###
# Third Party Dependencies
mongoose = require("mongoose")
# First Party Dependencies
Group   = require("./Group")
# Aliases
Schema   = mongoose.Schema
ObjectId = mongoose.Schema.ObjectId

###
Schema
###
MemberSchema = new Schema {
  # Member Details
  name:
    type: String
    trim: true
    required: true
  type:
    type: String
    required: true
    enum: [
      "Youth",
      "Young Adult",
      "Chaperone"
    ]
  gender:
    type: String
    required: true
    enum: [
      "Male",
      "Female",
      "Other"
    ]
  birthDate:
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
      min: 1900 # TODO: Restrict these?
      max: 2013
  # Contact Details, these are optional.
  phone:
    type: String
    trim: true
  email:
    type: String
    match: /.*@.*\..*/ # Should match most emails.
    trim: true
    lowercase: true
  # Emergency Contact Info, Unlikely to be used but important!
  emergencyContact:
    name:
      type: String
      trim: true
      required: true
    relation:
      type: String
      trim: true
      required: true
    phone:
      type: String
      trim: true
      required: true
  emergencyInfo:
    medicalNum:
      type: String
      trim: true
      required: true
    allergies:
      type: [String]
    conditions:
      type: [String]
  # State variables
  _state:
    # TODO: We may want to have a marker when people are done.
    information:
      type: Boolean
      default: false
  # Aggregations
  _workshops: [ # Store both the session and the id itself.
    session:    # This lets us do validation really quickly and easily.
      type: Number
      required: true
    _id:
      type: ObjectId
      ref: "Workshop"
      required: true
  ]
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
Member = mongoose.model("Member", MemberSchema)
module.exports =
  schema: MemberSchema
  model: Member