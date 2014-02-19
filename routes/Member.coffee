Member = require("../schema/Member")
WorkshopRoutes = require('./Workshop')

MemberRoutes = module.exports = {
  get:
    member: (req, res) ->
      unless !req.query.id
        id = req.query.id.replace /\"/g, ""
        Member.model.findById id, (err, member) ->
          unless err or !member?
            res.render "templates/member", {
              member: member
              session: req.session
            }
          else
            res.send err || "No member found."
      else
        res.render "templates/member", {
          session: req.session
        }
    addWorkshop: (req, res) ->
      if req.session.group._members.indexOf(req.params.member) != -1
        Member.model.findById req.params.member, (err, member) ->
          unless err or !member?
            member.addWorkshop req.params.workshop, Number(req.params.session), (err, member) ->
              unless err
                message = "#{member.name} has been registered in session #{req.params.session} of this workshop."
                res.redirect("/workshop/members/#{req.params.workshop}/#{req.params.session}?message=#{message}")
              else
                message = "Couldn't add that member to the workshop... Something went wrong. Try again?"
                res.redirect("/workshop/members/#{req.params.workshop}/#{req.params.session}?message=#{message}")
          else
            message = "Couldn't find that member... Try again?"
            res.redirect("/workshop/members/#{req.params.workshop}/#{req.params.session}?message=#{message}")
      else
        message = "That member is not a part of your group."
        res.redirect "/workshop/#{req.params.workshop}?message=#{message}"
    delWorkshop: (req, res) ->
      if req.session.group._members.indexOf(req.params.member) != -1
        Member.model.findById req.params.member, (err, member) ->
          unless err or !member?
            member.removeWorkshop req.params.workshop, Number(req.params.session), (err, member) ->
              unless err
                message = "#{member.name} has been removed from session #{req.params.session} of this workshop."
                res.redirect("/workshop/members/#{req.params.workshop}/#{req.params.session}?message=#{message}")
              else
                message = "Couldn't remove that member from the workshop... Something went wrong. Try again?"
                res.redirect("/workshop/members/#{req.params.workshop}/#{req.params.session}?message=#{message}")
          else
            message = "Couldn't find that member... Try again?"
            res.redirect("/workshop/members/#{req.params.workshop}/#{req.params.session}?message=#{message}")
      else
        message = "That member is not a part of your group."
        res.redirect "/workshop/#{req.params.workshop}?message=#{message}"
    memberWorkshops: (req, res) ->
      if !req.query.id || req.session.group._members.indexOf(req.query.id) != -1
        Member.model.findById(req.query.id).populate("_workshops._id").exec (err, member) ->
          unless err || !member?
            res.render "templates/memberWorkshops", {
              session: req.session
              member: member
            }
          else
            message = "There was an error getting the member's workshops."
            res.redirect "/account?message=#{message}"
      else
        message = "You need to specify a member."
        res.redirect "/account?message=#{message}"
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
        if err?
          message = "Couldn't properly create that member... Try again?"
          res.redirect "/account?message=#{message}"
        else
          # Created member.
          Group = require("../schema/Group")
          Group.model.findById member._group, (err, group) ->
            unless err? or !group?
              # Refreshed group.
              req.session.group = group
              res.redirect "/account"
            else
              # Couldn't refresh group.
              message = "Couldn't grab your new group information. Could you please log out and back in?"
              res.redirect "/account?message=#{message}"
          
  put:
    member: (req, res) ->
      unless !req.body.id?
        # Has an ID.
        Member.model.findById req.body.id, (err, member) ->
          unless err or !member?
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
              if req.session.isAdmin && req.body.ticketType
                member._state.ticketType =        req.body.ticketType
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
                      message = "Couldn't grab your new group information. Could you please log out and back in?"
                      res.redirect "/account?message=#{message}"
                else
                  # Couldn't save member
                  message = "Couldn't save that member's new information. Could you try again?"
                  res.redirect "/account?message=#{message}"
       
            else
              # Member is not in the group.
              message = "That member is not a part of your group."
              res.redirect "/account?message=#{message}"
      else
        # No ID.
        message = "You didn't specify a member."
        res.redirect "/account?message=#{message}"
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
                      message = "Couldn't grab your new group information. Could you please log out and back in?"
                      res.redirect "/account?message=#{message}"
                else
                  # Couldn't remove member.
                  message = "Couldn't remove that member... Try again?"
                  res.redirect "/account?message=#{message}"
            else
              # Not in the group
              message = "That member is not in your group."
              res.redirect "/account?message=#{message}"
          else
            # Couldn't find member.
            message = "That member doesn't exist."
            res.redirect "/account?message=#{message}"
      else
        # No ID
        message = "You didn't specify a member."
        res.redirect "/account?message=#{message}"
}