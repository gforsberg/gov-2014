Account = module.exports = {
  get:
    register: (req, res) ->
      res.render "register",
        session: req.session  
        head:
          title: "Registration"
          caption: "Get started with your group, or update your existing cohort."
          bg: "/img/bg/register.jpg"

}
