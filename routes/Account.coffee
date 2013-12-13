Group = require("../schema/Group")

## We need Mandrill for mailouts ##
# Get Redis working
redis = require('redis')
config = require('../config')
if config.redis
  url    = require("url")
  redisURL = url.parse(config.redis)
  redisClient = redis.createClient(redisURL.port, redisURL.hostname, {no_ready_check: true})
  redisClient.auth(redisURL.auth.split(":")[1])
else
  redisClient = redis.createClient()

mandrill = require("node-mandrill")(config.mandrill_key)

AccountRoutes = module.exports = {
  get:
    register: (req, res) ->
      res.render "register",
        session: req.session
        head:
          title: "Registration"
          caption: "Get started with your group, or access your existing cohort."
          bg: "/img/bg/register.jpg"
    logout: (req, res) ->
      req.session.regenerate ->
        res.redirect "/"
    account: (req, res) ->
      Group.model.findById(req.session.group._id).populate("_members").exec (err, group) ->
        res.render "account",
          session: req.session
          head:
            title: "Account"
            caption: "Manage, grow, or shrink your group as needed."
            bg: "/img/bg/account.jpg"
          members: group._members
    printout: (req, res) ->
      Group.model.findById(req.session.group._id).populate("_members").populate("_payments").exec (err, group) ->
        if !group?
          return
        # Populate some data
        group.getCost (err, cost) ->
          group.getPaid (err, paid) ->
            group.stats = {
              "": 0,
              "Youth": 0,
              "Young Adult": 0,
              "Chaperone": 0,
              "Young Chaperone": 0,
              "youthInCare": 0
            }
            group._members.map (val) ->
              group.stats[val.type]++
              if val._state.youthInCare
                group.stats['youthInCare']++
              return
            # Render
            res.render "printout",
              session: req.session
              group: group
              cost: cost
              paid: paid
    recover: (req, res) ->
      # Start recovery
      Group.model.findOne email: req.params.email, (err, group) ->
        unless err or !group?
          hash = Math.random().toString(36).slice(2)
          redisClient.set hash, group._id, (err, redisResponse) ->
            mandrill '/messages/send', {
              message: {
                to: [{email: group.email, name: group.name}]
                from_email: 'gatheringourvoices@bcaafc.com'
                subject: "GOV2014 Password Recovery"
                html: "<p>Someone (hopefully you) has requested a password reset on your account.</p>
                       <p>If this was you, please visit <a href='gatheringourvoices.bcaafc.com/recovery/#{hash}'>this link</a> to get to your account management screen. From there, please click the purple 'Group Details' button and change your password.</p>
                       <p>If it wasn't you, please disregard this email.</p>"
              }
            }, (err, response) ->
              unless err
                res.send "We've sent an email to the address you provided us. Please check your inbox"
              else
                res.send "We weren't able to send you a recovery email. Please contact dpreston@bcaaf.com"
        else
          res.redirect "/register"
    recovery: (req, res) ->
      redisClient.get req.params.hash, (err, response) ->
        redisClient.del req.params.hash
        unless err or !response?
          Group.model.findById response, (err, group) ->
            req.session.group = group
            res.redirect "/account"
        else
          res.redirect "/register"
  post:
    login: (req, res) ->
      if req.body.passwordConfirm? and req.body.passwordConfirm is req.body.password
        # Creating a new group.
        # Do some basic sanitization of input.
        Group.model.create {
          email:        req.body.email
          password:     req.body.password
          name:         req.body.name
          affiliation:  req.body.affiliation
          address:      req.body.address
          city:         req.body.city
          region:       req.body.region
          province:     req.body.province
          postalCode:   req.body.postalCode
          fax:          req.body.fax
          phone:        req.body.phone
          affiliationType: req.body.affiliationType
        }, (err, group) ->
          unless err?
            req.session.group = group
            mandrill '/messages/send', {
              message: {
                to: [{email: group.email, name: group.name}, {email: "dpreston@bcaafc.com", name: "Della Preston"}, {email: "klow@bcaafc.com", name: "Kerri Low"}]
                from_email: 'gatheringourvoices@bcaafc.com'
                subject: "GOV2014 Registration"
                html: "<h4>Thank you for submitting your online registration!</h4>
                  <p>The Gathering Our Voices Team will review your registration and contact you via email regarding the following:</p>
                    <ul>
                      <li>Member Information: You can add group members from the \"Account\" Page. When adding a new member, all that is required is a name, which you're free to make a placeholder. We ask that you try to populate your group with members (even placeholders!) as soon as you can for a number of reasons. First, so we can have more accurate estimations for catering and bookings, second, you won't have to get all of the information from your members right away. Members which are incomplete will be marked appropriately with a red label, you can just click on that label (or the complete label) at any time to edit their information.</li>
                      <li>Payment: You can view your current payment status from the \"Account\" Page, just hit the orange \"Manage Payments\" button.</li>
                      <li>Workshops: Starting in late January / early February, the team will have confirmed facilitators for workshops. At this point we will start to populate the listings on the \"Workshops\" page. Members with <b>complete</b> information will be permitted to register in workshops automatically. We will send out an email when this begins.</li>
                    </ul>
                  <p>If you have any questions take a look at our <a href=\"http://gatheringourvoices.bcaafc.com/faq\">FAQ</a>, or connect with me!</p>
                  <br>
                  <p>In friendship,</p>
                  <p>Kerri Low</p>
                  <p>Conference Registration Coordinator</p>
                  <p>Phone: (250) 388-5522 or toll-free: 1-800-990-2432</p>
                  <a href=\"mailto:klow@bcaafc.com\">klow@bcaafc.com</p>"
              }
            }, (err, response) ->
              console.log err if err
              res.redirect "/account"
          else
            if err.code == 11000
              # Duplicate key.
              message = "That email has already registered a group. Try logging in?"
            else if err.errors
              # Not all information filled in.
              message = "You didn't fill out the following fields: "
              for key, val of err.errors
                console.log val.path
                message += val.path + " "
            else
              message = "Something went wrong that normally doesn't... Try again?"
            res.redirect "/register?message=#{message}"
      else
        # Logging into an exiting group.
        Group.model.login req.body.email, req.body.password, (err, group) ->
          unless err? or !group?
            req.session.isAdmin = true if group.isAdmin()
            req.session.group = group
            res.redirect "/account"
          else
            message = "We were unable to log you in. Either your password, email, or both are incorrect."
            res.redirect "/register?message=#{message}"
  put:
    account: (req, res) ->
      Group.model.findById req.session.group._id, (err, group) ->
        unless err or !group?
          # Login Details
          group.email = req.body.email
          group.password = req.body.password if req.body.password == req.body.passwordConfirm
          # Group Details
          group.name = req.body.name
          group.affiliation = req.body.affiliation
          group.address = req.body.address
          group.city = req.body.city
          group.region = req.body.region
          group.province = req.body.province
          group.postalCode = req.body.postalCode
          group.phone = req.body.phone
          group.fax = req.body.fax
          group.affiliationType = req.body.affiliationType
          group.save (err, group) ->
            unless err
              req.session.group = group
              res.redirect "/account"
            else
              message = # TODO
              res.redirect "/account?message=#{message}"
        else
          # TODO
  delete:
    account: (req, res) ->
      Group.model.findById req.params.id, (err, group) ->
        group.remove (err) ->
          res.send err || "Wow, you really did it. :("
}
