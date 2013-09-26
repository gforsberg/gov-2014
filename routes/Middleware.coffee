General = module.exports = {
  auth: (req, res, next) ->
    unless !req.session.group?
      # A session exists, it's ok!
      next()
    else
      # The user isn't logged in.
      errors = {
        error: "You're not authorized to visit there."
        fix: "Please log in."
      }
      res.redirect("/register?errors=#{JSON.stringify(errors)}")
  admin: (req, res, next) ->
    User.model.find req.session._id
    unless !req.session.isAdmin
      next()
    else
      errors = {
        error: "You're not authorized to do that."
        fix: "Please log in as an admin."
      }
      res.redirect("/register?errors=#{JSON.stringify(errors)}")
}