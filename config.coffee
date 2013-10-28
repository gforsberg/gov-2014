module.exports = {
  port:         process.env.PORT            || 8080
  db:           process.env.MONGOLAB_URI    || "localhost/dev"
  redis:        process.env.REDISCLOUD_URL  # No need for fallback
  secret:       process.env.secret          || "test"
  admins:       process.env.admins          || ["andrew@hoverbear.org"]
  mandrill_key: process.env.mandrill_Key     || null
  newrelic_key: process.env.newrelic_Key     || null
}