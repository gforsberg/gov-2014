Workshop = require("../schema/Workshop")

WorkshopRoutes = module.exports = {
  get:
    index: (req, res) ->
      Workshop.model.find().sort("name").limit(25).exec (err, workshops) ->
        res.render "workshops",
          session: req.session  
          head:
            title: "Workshops"
            caption: "My will shall shape my future. Whether I fail or succeed shall be no man's doing but my own."  
            bg: "/img/bg/workshops.jpg"
          workshops: workshops
  post:
    workshop: (req, res) ->
      # Build a session array.
      # keys = Object.keys(req.body)
      # sessions = []
      # console.log keys.filter (key) ->
      #   new RegExp("1-")
}