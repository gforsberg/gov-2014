Group = require("../schema/Group")

AccountRoutes = module.exports = {
  get:
    register: (req, res) ->
      res.render "register",
        session: req.session
        head:
          title: "Registration"
          caption: "Get started with your group, or access your existing cohort."
          bg: "/img/bg/register.jpg"
        errors: req.query.errors
    logout: (req, res) ->
      req.session.group = null
      res.redirect "/"
    account: (req, res) ->
      Group.model.findById(req.session.group._id).populate("_members").exec (err, group) ->
        group.enoughChaperones (enough) ->
          res.render "account",
            session: req.session
            head:
              title: "Account"
              caption: "Manage, grow, or shrink your group as needed."
              bg: "/img/bg/account.jpg"
            members: group._members
            errors: req.query.errors
            enoughChaperones: enough
  post:
    login: (req, res) ->
      if req.body.passwordConfirm? and req.body.passwordConfirm is req.body.password
        # Creating a new group.
        # Do some basic sanitization of input.
        Group.model.create {
          email:        req.body.email
          password:     req.body.password
          name:         req.body.name
          affiliation:  req.body.affiliation
          address:      req.body.address
          city:         req.body.city
          province:     req.body.province
          postalCode:   req.body.postalCode
          fax:          req.body.fax
          phone:        req.body.phone
        }, (err, group) ->
          unless err?
            req.session.group = group
            res.redirect "/account"
          else
            res.redirect "/register?errors=#{JSON.stringify(err)}"
      else
        # Logging into an exiting group.
        Group.model.login req.body.email, req.body.password, (err, group) ->
          unless err? or !group?
            req.session.group = group
            res.redirect "/account"
          else
            errors = JSON.stringify({errors: err.toString()})
            res.redirect "/register?errors=#{errors}"
  put:
    account: (req, res) ->
      console.log "I got a request"
      Group.model.findById req.session.group._id, (err, group) ->
        # Login Details
        group.email = req.body.email
        group.password = req.body.password if req.body.password == req.body.passwordConfirm
        # Group Details
        group.name = req.body.name
        group.affiliation = req.body.affiliation
        group.address = req.body.address
        group.city = req.body.city
        group.province = req.body.province
        group.postalCode = req.body.postalCode
        group.phone = req.body.phone
        group.fax = req.body.fax
        group.save (err, group) ->
          unless err
            req.session.group = group
            res.redirect "/account"
          else
            errors = JSON.stringify({err})
            res.redirect "/account?errors=#{err}"
}
