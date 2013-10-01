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
}