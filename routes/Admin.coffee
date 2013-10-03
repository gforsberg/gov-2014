Group = require('../schema/Group')

Admin = module.exports = {
  get:
    index: (req, res) ->
      Group.model.find().sort("affiliation").exec (err, groups) ->
        unless err
          res.render "admin",
            session: req.session  
            head:
              title: "Admin"
              caption: "Sure, let me just reach into my magical hat and fix everything..."
              bg: "/img/bg/admin.jpg"
            groups: groups
        else
          res.send err
    manage: (req, res) ->
      Group.model.findById req.params.id, (err, group) ->
        unless err
          req.session.group = group
          res.redirect "/account"
        else
          res.send err
    notes: (req, res) ->
      Group.model.findById req.params.id, (err, group) ->
        unless err
          res.render "notes",
            session: req.session
            head:
              title: "Group Notes"
              caption: "You're SO on my naughty list!"
              bg: "/img/bg/notes.jpg"
            group: group
        else
          res.send err
  put:
    notes: (req, res) ->
      Group.model.findById req.params.id, (err, group) ->
        unless err
          group._notes = req.body.notes
          group._state.registration = req.body.registration
          group._state.workshops = req.body.workshops
          group._state.payment = req.body.payment
          group.save (err) ->
            unless err
              res.redirect "/notes/#{group._id}"
            else  
              res.send err
        else
          res.send err

}