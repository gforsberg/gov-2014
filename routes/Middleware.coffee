General = module.exports = {
  auth: (req, res, next) ->
    unless !req.session.group?
      # A session exists, it's ok!
      next()
    else
      # The user isn't logged in.
      message = "You're not authorized to visit this area. Please log in."
      res.redirect("/register?message=#{message}")
  admin: (req, res, next) ->
    unless !req.session.isAdmin
      next()
    else
      message = "You're not an administrator, and thus cannot do this action."
      res.redirect("/register?message=#{message}")
}