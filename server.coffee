###
Gathering Our Voices 2014
###
# Dependencies
express  = require("express")
fs       = require("fs")
mongoose = require("mongoose")
redis    = require("redis")
RedisStore = require("connect-redis")(express)
url      = require("url")
newrelic = require('newrelic');

# Config Vars
config = require("./config")

# Our App
app = module.exports = express()

# Mongoose
mongoose.connect config.db, (err) ->
  unless err
    console.log "Connected to #{config.db} database"
  else
    console.log err

# Redis
if config.redis
  redisURL = url.parse(config.redis)
  redisClient = redis.createClient(redisURL.port, redisURL.hostname, {no_ready_check: true})
  redisClient.auth(redisURL.auth.split(":")[1])
else
  redisClient = redis.createClient()


# Middleware for the app
app.use (req, res, next) ->
  # If running development, don't forward!
  # Otherwise, forward to https!
  if config.ssl && req.headers['x-forwarded-proto'] != "https" && req.host != "localhost"
    res.redirect('https://' + req.host + req.url)
  else
    next()
app.use express.logger("dev")
app.use express.bodyParser()
app.use express.methodOverride() # Allows PUT/DELETE in forms.
app.use express.cookieParser(config.secret)
app.use express.session(
  secret: config.secret
  store: new RedisStore {client: redisClient}
)
app.use (req, res, next) ->
  if req.query.message
    req.session.message = req.query.message
  else
    req.session.message = null
  next()
app.use express.compress()
app.use app.router    # Normal Routes
app.use express.static "#{__dirname}/static", { maxAge: 86400000 * 4 } # 4 days.
app.use (req, res) -> # 404 Error
  res.status 404
  console.log new Error("This page doesn't exist")
  res.send "This page doesn't exist!"

# Settings
app.set "views", "#{__dirname}/views"
app.set "view engine", "jade"

# Load Routes
require("./routes")(app)

# Listen on the configured port.
app.listen config.port, () ->
  console.log "Listening on port #{config.port}."
  
Group = require("./schema/Group")
Group.model.find {}, (err, groups) ->
  for group in groups
    group.checkFlags () ->
      group.save()