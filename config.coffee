module.exports = {
  port:         process.env.PORT            || 8080 # What's your port?
  db:           process.env.MONGOLAB_URI    || "localhost/dev" # What's your database URL?
  redis:        process.env.REDISCLOUD_URL  # No need for fallback
  secret:       process.env.secret          || "test" # What's the cookie secret?
  admins:       process.env.admins          || ["andrew@hoverbear.org"] # Who are your admins?
  mandrill_key: process.env.mandrill_Key    || null # Set up a mandrill key to enable mailouts.
}