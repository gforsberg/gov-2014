Group = require("../schema/Group")

Account = module.exports = {
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
            res.redirect "/register?errors=#{JSON.stringify(err.errors)}"
      else
        # Logging into an exiting group.
        Group.model.login req.body.email, req.body.password, (err, group) ->
          console.log err
          console.log group
          unless err? or !group?
            req.session.group = group
            res.redirect "/account"
          else
            errors = JSON.stringify({errors: err.toString()})
            res.redirect "/register?errors=#{errors}"
}
