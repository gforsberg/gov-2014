Workshop = require("../schema/Workshop")
Group    = require("../schema/Group")

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
      Workshop.model.find(query).sort("name").exec (err, workshops) ->
        res.render "workshops",
          session: req.session  
          head:
            title: "Workshops"
            caption: "There it stood before me, my passion, my future."
            bg: "/img/bg/workshops.jpg"
          workshops: workshops || {}
    id: (req, res) ->
      Workshop.model.findById req.params.id, (err, workshop) ->
        res.render "workshop",
          session: req.session
          head:
            title: workshop.name
            caption: "Details and signup."
            bg: "/img/bg/workshop.jpg"
          workshop: workshop
    members: (req, res) ->
      Workshop.model.findById req.params.id, (err, workshop) ->
        Group.model.findById(req.session.group._id).populate("_members").exec (err, group) ->
          unless err or !group?
            res.render "templates/workshopMembers",
              session: { group: group }
              workshop: workshop
              workshopSession: Number(req.params.session)
              message: req.query.message || null
          else
            res.send "Error. :("
    edit: (req, res) ->
      unless !req.query.id
        Workshop.model.findById req.query.id, (err, workshop) ->
          res.render "templates/workshopForm.jade",
            session: req.session
            workshop: workshop
      else
        res.send "Y u no ask for workshop ID? :("

  put:
    workshop: (req, res) ->
      Workshop.model.findById req.body.id, (err, workshop) ->
        unless err
          workshop.name = req.body.name
          workshop.host = req.body.host
          workshop.description = req.body.description
          workshop.label = req.body.label
          # Handle the "allows"
          switch req.body.allows
            when "default"    
              workshop.allows = ["Youth", "Young Adult", "Young Chaperone"]
            when "all"
              workshop.allows = ["Youth", "Young Adult", "Young Chaperone", "Chaperone"]
            when "chaperones"
              workshop.allows = ["Young Chaperone", "Chaperone"]
            when "young"
              workshop.allows = ["Youth", "Young Adult"]
            when "youngAdult"
              workshop.allows = ["Young Adult"]
            when "youth"
              workshop.allows = ["Youth"]
          # Populate Sessions.
          for x in [1..12]
            # x-1 for array indexing.
            session = workshop.session(x)
            if req.body.enabled[x-1] == 'on'
              # The workshop is enabled.
              if session
                # The session exists already, edit it.
                session.room = req.body.room[x-1]
                session.venue = req.body.venue[x-1]
                session.capacity = req.body.capacity[x-1]
              else
                # The session doesn't exist, create it.
                workshop.sessions.push {
                  session: x
                  room: req.body.room[x-1]
                  venue: req.body.venue[x-1]
                  capacity: req.body.capacity[x-1]
                }
            else
              # The session is disabled.
              if session
                # The session exists, remove it.
                # Make sure to remove all the members?
                console.log "Hey this #{session} needs to be removed."
              # We don't care if it doesn't exist.

          workshop.save (err) ->
            if err
              res.send err
            else
              res.redirect "/workshops"
        else
          res.send err

  post:
    workshop: (req, res) ->
      workshop = {
        name: req.body.name
        host: req.body.host
        description: req.body.description
        label: req.body.label
        allows: []
        sessions: []
      }
      # Handle the "allows"
      switch req.body.allows
        when "default"    
          workshop.allows = ["Youth", "Young Adult", "Young Chaperone"]
        when "all"
          workshop.allows = ["Youth", "Young Adult", "Young Chaperone", "Chaperone"]
        when "chaperones"
          workshop.allows = ["Young Chaperone", "Chaperone"]
        when "young"
          workshop.allows = ["Youth", "Young Adult"]
        when "youngAdult"
          workshop.allows = ["Young Adult"]
        when "youth"
          workshop.allows = ["Youth"]
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
          res.redirect "/workshops?message=#{JSON.stringify(err)}"
        else
          res.redirect "/workshops"
  delete:
    workshop: (req, res) ->
      Workshop.model.findById req.params.id, (err, workshop) ->
        unless err?
          workshop.remove (err) ->
            unless err?
              res.redirect "/workshops?message=Workshop deleted!"
            else
              res.redirect "/workshops?message=Couldn't delete workshop."
        else
          res.redirect "/workshops?message=Couldn't find workshop."
}