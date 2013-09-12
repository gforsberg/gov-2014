General = module.exports = {
  get:
    index: (req, res) ->
      res.render "index",
        session: req.session  
        head:
          title: "Gathering Our Voices 2014"
          caption: "Aboriginal youth exploring the past, present, and future."  

    privacy: (req, res) ->
      res.render "privacy",
        session: req.session

    faq: (req, res) ->
      res.render "faq",
        session: req.session
}