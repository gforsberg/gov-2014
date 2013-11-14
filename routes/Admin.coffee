Group = require('../schema/Group')
Member = require('../schema/Member')

Admin = module.exports = {
  get:
    index: (req, res) ->
      Group.model.find().sort("affiliation").exec (err, groups) ->
        unless err
          res.render "admin",
            session: req.session  
            head:
              title: "Admin"
              caption: "Sure, let me just reach into my magical hat and fix everything..."
              bg: "/img/bg/admin.jpg"
            groups: groups
        else
          res.send err
    manage: (req, res) ->
      Group.model.findById req.params.id, (err, group) ->
        unless err
          req.session.group = group
          res.redirect "/account"
        else
          res.send err
    notes: (req, res) ->
      Group.model.findById req.params.id, (err, group) ->
        unless err
          res.render "notes",
            session: req.session
            head:
              title: "Group Notes"
              caption: "You're SO on my naughty list!"
              bg: "/img/bg/notes.jpg"
            group: group
        else
          res.send err
    statistics: (req, res) ->
      types = {
        'Youth':
          'Male':   0
          'Female': 0
          'Other':  0
          '':       0
        'Young Adult':
          'Male':   0
          'Female': 0
          'Other':  0
          '':       0
        'Young Chaperone':
          'Male':   0
          'Female': 0
          'Other':  0
          '':       0
        'Chaperone':
          'Male':   0
          'Female': 0
          'Other':  0
          '':       0
        '':
          'Male':   0
          'Female': 0
          'Other':  0
          '':       0
      }
      ages = {
        14:
          'Male':   0
          'Female': 0
          'Other':  0
          '':       0
        15:
          'Male':   0
          'Female': 0
          'Other':  0
          '':       0
        16:
          'Male':   0
          'Female': 0
          'Other':  0
          '':       0
        17:
          'Male':   0
          'Female': 0
          'Other':  0
          '':       0
        18:
          'Male':   0
          'Female': 0
          'Other':  0
          '':       0
        19:
          'Male': 0
          'Female': 0
          'Other':  0
          '':       0
        20:
          'Male':   0
          'Female': 0
          'Other':  0
          '':       0
        21:
          'Male':   0
          'Female': 0
          'Other':  0
          '':       0
        22:
          'Male':   0
          'Female': 0
          'Other':  0
          '':       0
        23:
          'Male':   0
          'Female': 0
          'Other':  0
          '':       0
        24:
          'Male':   0
          'Female': 0
          'Other':  0
          '':       0
        'over':
          'Male':   0
          'Female': 0
          'Other':  0
          '':       0
        '':
          'Male':   0
          'Female': 0
          'Other':  0
          '':       0
      }
      regions = {
        'North':
          'Male':   0
          'Female': 0
          'Other':  0
          '':       0
        'Fraser':
          'Male':   0
          'Female': 0
          'Other':  0
          '':       0
        'Interior':
          'Male':   0
          'Female': 0
          'Other':  0
          '':       0
        'Vancouver Coastal':
          'Male':   0
          'Female': 0
          'Other':  0
          '':       0
        'Vancouver Island':
          'Male':   0
          'Female': 0
          'Other':  0
          '':       0
        'Out of Province':
          'Male':   0
          'Female': 0
          'Other':  0
          '':       0
      }
      totals = {
        'Male':   0
        'Female': 0
        'Other':  0
        '':       0
      }
      Member.model.find({}).populate("_group").exec (err, members) ->
        members.map (val) ->
          # Types
          types[val.type][val.gender] += 1
          # Ages
          if !val.birthDate.year
            ages[''][val.gender] += 1
          else if ((val.birthDate.year - 2014) * -1) <= 24
            ages[(val.birthDate.year - 2014) * -1][val.gender] += 1
          else
            ages['over'][val.gender] += 1
          # Regions
          regions[val._group.region][val.gender] += 1
          # Totals
          totals[val.gender] += 1
        res.render "statistics", {
          # Normal Stuff
          session: req.session
          head:
            title: "Statistics"
            caption: "Say it with me \"I am a data nerd\""
            bg: "/img/bg/statistics.jpg"
          # Stats
          types: types
          ages: ages
          regions: regions
          totals: totals
        }

  put:
    notes: (req, res) ->
      Group.model.findById req.params.id, (err, group) ->
        unless err
          group._notes = req.body.notes
          group._state.registration = req.body.registration
          group._state.workshops = req.body.workshops
          group._state.payment = req.body.payment
          group.save (err) ->
            unless err
              res.redirect "/notes/#{group._id}"
            else  
              res.send err
        else
          res.send err

}