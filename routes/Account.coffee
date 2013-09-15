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
        error: JSON.parse(req.query.error) if req.query.error
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
            res.redirect "/register?error=#{JSON.stringify(err)}"
      else
        # Logging into an exiting group.
        Group.model.login req.body.email, req.body.password, (err, group) ->
          console.log err
          console.log group
          unless err? or !group?
            req.session.group = group
            res.redirect "/account"
          else
            error = JSON.stringify({error: err.toString()})
            res.redirect "/register?error=#{error}"
}
