General = module.exports = {
  get:
    index: (req, res) ->
      res.render "index",
        session: req.session  
        head:
          title: "Gathering Our Voices 2014"
          caption: "The 12th annual gathering of Aboriginal Youth to make their voices heard and learn valuable skills"  
          bg: "/img/bg/index.jpg"

    schedule: (req, res) ->
      res.render "schedule",
        session: req.session  
        head:
          title: "Schedule"
          caption: "Get the low down on what's happening, wherever you are"
          bg: "/img/bg/schedule.jpg"

    venues: (req, res) ->
      res.render "venues",
        session: req.session  
        head:
          title: "Venues"
          caption: "Organizing a discussion is one thing, creating a space for the free exchange of ideas is what is truly powerful"
          bg: "/img/bg/venues.jpg"

    privacy: (req, res) ->
      res.render "privacy",
        session: req.session

    faq: (req, res) ->
      res.render "faq",
        session: req.session
}