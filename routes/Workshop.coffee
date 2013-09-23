Workshop = require("../schema/Workshop")

WorkshopRoutes = module.exports = {
  get:
    index: (req, res) ->
      query = {}
      if req.query.sessions
        query["sessions.session"] = $in: req.query.sessions.split(",").map (val) -> Number(val)
      if req.query.query
        searcher = new RegExp(req.query.query, "i")
        query["description"] = searcher
      # Query
      Workshop.model.find(query).sort("name").limit(25).exec (err, workshops) ->
        res.render "workshops",
          session: req.session  
          head:
            title: "Workshops"
            caption: "My will shall shape my future. Whether I fail or succeed shall be no man's doing but my own."  
            bg: "/img/bg/workshops.jpg"
          workshops: workshops
          errors: req.query.errors
  post:
    workshop: (req, res) ->
      workshop = {
        name: req.body.name
        host: req.body.host
        description: req.body.description
        allows: []
        sessions: []
      }
      # Handle the "allows"
      console.log req.body.allows
      switch req.body.allows
        when "default"    
          workshop.allows = ["Youth", "Young Adult", "Young Chaperone"]
        when "all"
          workshop.allows = ["Youth", "Young Adult", "Young Chaperone", "Chaperone"]
        when "chaperones"
          workshop.allows = ["Young Chaperone", "Chaperone"]
        when "youth"
          workshop.allows = ["Younth", "Young Adult"]
      # Populate Sessions.
      for x in [1..12]
        # x-1 for array indexing.
        if req.body.enabled[x-1] == 'on'
          workshop.sessions.push {
            session: x
            room: req.body.room[x-1]
            venue: req.body.venue[x-1]
            capacity: req.body.capacity[x-1]
          }
      Workshop.model.create workshop, (err, workshop) ->
        if err
          res.redirect "/workshops?errors=#{JSON.stringify(err)}"
        else
          res.redirect "/workshops"
}