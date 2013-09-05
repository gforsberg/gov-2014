###
Workshop
  The workshops to be held at the conference.
  Has:
    * 1..* Members attending
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
WorkshopSchema = new Schema {
  name:
    type: String
    required: true
    trim: true
  host:
    type: String
    required: true
    trim: true
  description:
    type: String
    required: true
    trim: true
  sessions: [ # Determines start/end time, as well as day.
    session:
      type: Number
      min: 0
      max: 12
      required: true
    room:
      type: String
      required: true
      trim: true
    venue:
      type: String
      required: true
      trim: true
    capacity: # Only allow this many to register.
      type: Number
      min: 0
      max: 2000
      required: true
    _registered: 
      type: [
        type: ObjectId
        ref: "Member"
      ]
      default: []
  ]
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
WorkshopSchema.methods.session = (session) ->
  for item in @sessions
    if item.session == session
      return item
  # Didn't find anything?
  return new Error("That session doesn't exist")

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

###
Export
###
# We should export both, just in case.
Workshop = mongoose.model("Workshop", WorkshopSchema)
module.exports =
  schema: WorkshopSchema
  model: Workshop