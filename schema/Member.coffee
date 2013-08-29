###
Member
  People going to the conference.
  Child Of:
    * 1..1 Group
  Has:
    * 1..6 Workshops
###

###
Setup
###
# Third Party Dependencies
mongoose = require("mongoose")
# First Party Dependencies
Group    = require("./Group")
Workshop    = require("./Workshop")
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
      min: 1900
      max: 2000 # 14 years old. Della signed off.
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
  _workshops: 
    type: [ # Store both the session and the id itself.
      session:    # This lets us do validation really quickly and easily.
        type: Number
        required: true
      _id:
        type: ObjectId
        ref: "Workshop"
        required: true
    ]
    default: []
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
MemberSchema.methods.hasConflicts = (workshopId, session) ->
  if session % 3 is 1
    blocks = [session..session+2]
  else
    blocks = [session, Math.floor(session / 4) + 1] 
  conflicts = @_workshops.filter (val) ->
    return blocks.indexOf(val.session) != -1 # Don't return blocks
  if conflicts.length > 0
    return true
  else
    return false

MemberSchema.methods.addWorkshop = (workshopId, session, next) ->
  if not @hasConflicts(workshopId, session)
    # Check that the workshop isn't full, if not, add us there.
    Workshop.model.findById workshopId, (err, workshop) =>
      # Figure out the session we want, add the member.
      for aSession in workshop.sessions
        if aSession.session == session
          if aSession.capacity > aSession._registered.length
            aSession._registered.push @_id
          else
            next new Error("That workshop is at capacity"), null
            return # End early.
      workshop.save (err) =>
        unless err
          @_workshops.push {session: session, _id: workshop._id}
          @save (err) =>
            unless err
              next null, @
            else
              next err, null
        else
          next err, null
  else
    next new Error("Can't register for this workshop, there is a conflict."), null

###
Pre/Post Middleware
  Middleware can be pre/post `init`, `validate`, `save`, `remove`
  NOTE: Atomic updates **do not** invoke middleware.
  `MemberSchema.pre 'bar', (next) ->`
  `MemberSchema.post 'bar', (next) ->`
###
MemberSchema.pre "save", (next) ->
  # Make sure their group knows they're part of them.
  Group.model.findById @_group, (err, group) =>
    if err or !group?
      next err || new Error("Group doesn't exist")
    else if group._members.indexOf(@_id) is -1
      # Not in the group!
      group._members.push @_id
      group.save (err) ->
        unless err
          next()
        else
          next err
    else
      # In the group already.
      next()

MemberSchema.pre "remove", (next) ->
  # Remove the member from the group
  Group.model.findById @_group, (err, group) =>
    unless !group?
      index = group._members.indexOf @_id
      unless index is -1
        # Group exists, member is a part of it.
        group._members.splice index, 1
        group.save (err) =>
          unless err
            next()
          else
            next err
MemberSchema.pre "remove", (next) ->
  # Remove the member from their workshops.
  workshopIds = @_workshops.map (val) ->
    return val._id
  Workshop.model.find _id: {$in: workshopIds}, (err, workshops) =>
    errors = [] # If we have any.
    processor = (index) =>
      if index < workshopIds.length
        mapped = workshops[index].sessions.filter (val) =>
          # Should **only** return the one session we want.
          return val.session == @_workshops[index].session
        tosser = mapped[0]._registered.indexOf @_id
        mapped[0]._registered.splice tosser, 1
        workshops[index].save (err) ->
          errors.push err if err
          processor index+1
    processor 0
    unless errors.length > 0
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
Member = mongoose.model("Member", MemberSchema)
module.exports =
  schema: MemberSchema
  model: Member