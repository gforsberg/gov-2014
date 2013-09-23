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
      workshop = {
        name: req.body.name
        host: req.body.host
        description: req.body.description
      }
      sessions = []
      for x in [1..12]
        # x-1 for array indexing.
        if req.body.enabled[x-1] == 'on'
          sessions.push {
            session: x
            room: req.body.room[x-1]
            venue: req.body.venue[x-1]
            capacity: req.body.capacity[x-1]
          }
      workshop.sessions = sessions
      Workshop.model.create workshop, (err, workshop) ->
        console.log err
        console.log workshop
        if err
          res.redirect "/workshops?errors=#{JSON.stringify(err)}"
        else
          res.redirect "/workshops"
}