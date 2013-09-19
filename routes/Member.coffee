Member = require("../schema/Member")

MemberRoutes = module.exports = {
  get:
    member: (req, res) ->
      unless !req.params.id
        id = req.params.id.replace /\"/g, ""
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
          # Created member.
          Group = require("../schema/Group")
          Group.model.findById member._group, (err, group) ->
            unless err? or !group?
              # Refreshed group.
              req.session.group = group
              res.redirect "/account"
            else
              # Couldn't refresh group.
              res.redirect "/account?errors=#{JSON.stringify(err)}"
        else
          res.redirect "/account?errors=#{JSON.stringify(err.errors)}"
  put:
    member: (req, res) ->
      unless !req.body.id?
        # Has an ID.
        Member.model.findById req.body.id, (err, member) ->
          unless err
            # Found member.
            if String(member._group) == req.session.group._id
              # Member is in the group.
              member.name =                       req.body.name
              member._group =                     req.session.group._id
              member.type =                       req.body.type
              member.gender =                     req.body.gender
              member.birthDate.day =              req.body.birthDay
              member.birthDate.month =            req.body.birthMonth
              member.birthDate.year =             req.body.birthYear
              member.phone =                      req.body.phone
              member.email =                      req.body.email
              member.emergencyContact.name =      req.body.emergName
              member.emergencyContact.relation =  req.body.emergRelation
              member.emergencyContact.phone =     req.body.emergPhone
              member.emergencyInfo.medicalNum =   req.body.emergMedicalNum
              member.emergencyInfo.allergies =    req.body.emergAllergies
              member.emergencyInfo.conditions =   req.body.emergConditions
              member._state.youthInCare =         (req.body.youthInCare == "Yes")
              member.save (err) ->
                unless err?
                  # Removed member.
                  Group = require("../schema/Group")
                  Group.model.findById member._group, (err, group) ->
                    unless err? or !group?
                      # Refreshed group.
                      req.session.group = group
                      res.redirect "/account"
                    else
                      # Couldn't refresh group.
                      res.redirect "/account?errors=#{JSON.stringify(err)}"
                else
                  # Couldn't save member
                  res.redirect "/account?errors=#{JSON.stringify(err)}"
       
            else
              # Member is not in the group.
              errors = {
                error: "You're not authorized to remove that member."
                reason: "They're not in your group."
              }
              res.redirect "/account?errors=#{JSON.stringify(errors)}"
      else
        # No ID.
        error = {
          error: "You didn't specifiy a member."
        }
        res.redirect "/account?errors=#{JSON.stringify(errors)}"
  delete:
    member: (req, res) ->
      unless !req.params.id?
        # Has an ID.
        Member.model.findById req.params.id, (err, member) ->
          unless err
            # Found member.
            if String(member._group) == req.session.group._id
              # Member s in the group.
              member.remove (err) ->
                unless err
                  # Removed member.
                  Group = require("../schema/Group")
                  Group.model.findById member._group, (err, group) ->
                    unless err? or !group?
                      # Refreshed group.
                      req.session.group = group
                      res.redirect "/account"
                    else
                      # Couldn't refresh group.
                      res.redirect "/account?errors=#{JSON.stringify(err)}"
                else
                  # Couldn't remove member.
                  res.redirect "/account?errors=#{JSON.stringify(err)}"
            else
              # Not in the group
              errors = {
                error: "You're not authorized to remove that member."
                reason: "They're not in your group."
              }
              res.redirect "/account?errors=#{JSON.stringify(errors)}"
          else
            # Couldn't find member.
            errors = {
              error: "That member doesn't exist."
            }
            res.redirect "/account?errors=#{JSON.stringify(errors)}"
      else
        # No ID
        error = {
          error: "You didn't specifiy a member."
        }
        res.redirect "/account?errors=#{JSON.stringify(errors)}"
}