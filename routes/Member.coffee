Member = require("../schema/Member")

MemberRoutes = module.exports = {
  get:
    member: (req, res) ->
      unless !req.params.id
        id = req.params.id.replace /\"/g, ""
        console.log id
        Member.model.findById id, (err, member) ->
          unless err or !member?
            res.render "templates/member", {
              member: member
            }
          else
            res.send err || "No member found."
      else
        res.send "No ID specified."
  post:
    member: (req, res) ->
      # Is it a youth in care?
      inCare = (req.body.youthInCare == "Yes")
      Member.model.create {
        name:         req.body.name
        _group:       req.session.group._id
        type:         req.body.type
        gender:       req.body.gender
        birthDate:
          day:        req.body.birthDay
          month:      req.body.birthMonth
          year:       req.body.birthYear
        phone:        req.body.phone
        email:        req.body.email
        emergencyContact:
          name:       req.body.emergName
          relation:   req.body.emergRelation
          phone:      req.body.emergPhone
        emergencyInfo:
          medicalNum: req.body.emergMedicalNum
          allergies:  req.body.emergAllergies
          conditions: req.body.emergConditions
        _state:
          youthInCare: inCare
      }, (err, member) ->
        unless err?
          # We don't really need to refresh the entire group here.
          req.session.group._members.push(member._id)
          res.redirect "/account"
        else
          res.redirect "/account?errors=#{JSON.stringify(err.errors)}"

  delete:
    member: (req, res) ->
      unless !req.params.id? or (req.session.group._members.indexOf(req.params.id) == -1)
        # Has an ID, and is in the group.
        Member.model.findById req.params.id, (err, member) ->
          member.remove (err) ->
            unless err
              Group = require("../schema/Group")
              Group.model.findById member._group, (err, group) ->
                unless err? or !group?
                  req.session.group = group
                  res.redirect "/account"
                else
                  res.redirect "/account?errors=#{JSON.stringify(err)}"
            else
              res.redirect "/account?errors=#{JSON.stringify(err)}"
      else
        # Not in the group
        errors = {
          error: "You're not authorized to remove that member."
          reason: "They're not in your group."
        }
        res.redirect "/account?errors=#{JSON.stringify(errors)}"
}