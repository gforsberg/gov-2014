# Don't put static routes here! Just drop them in `static`

routes = module.exports = (app) ->
  # Middleware = require("./routes/Middleware")
  ###
  General Routes
  ###
  General = require("./routes/General")
  app.get   "/",          General.get.index     # Welcome page
  app.get   "/schedule",  General.get.schedule  # Schedule page
  app.get   "/privacy",   General.get.privacy   # Privacy Policy
  app.get   "/faq",       General.get.faq       # Frequently Asked Questions

  ###
  Account Routes
  ###
  Account = require("./routes/Account")
  app.get   "/register",  Account.get.register  # Gets a registration/login page.
  # # Register/Login/Logout
  app.post  "/login",     Account.post.login    #
  app.get  "/logout",     Account.get.logout   #
  # # Recovery
  # app.get   "/recovery",  Account.get.recovery  # Recover a password 
  # app.post  "/recovery",  Account.post.Recovery # 
  # # Edit/See details
  # app.get   "/account",   Middle.auth, Account.get.account   # Edit group details.
  # app.put   "/account",   Middle.auth, Account.put.account   # 
  # # Main information pages, actions can be accessed here.
  # app.get   "/members",   Middle.auth, Account.get.members   # Add/remove/edit members.
  # app.get   "/billing",   Middle.auth, Account.get.billing   # Add/remove/edit payments.
  
  ###
  Workshop Routes
  ###
  # Workshop = require("./routes/Workshop")
  # app.get      "/workshops",     Workshop.get.index                     # Lists workshops. (Query Sensitive)
  # app.get      "/workshop/:id",  Workshop.get.member                    # Displays :id details
  # app.post     "/workshop",      Middle.admin, Workshop.post.workshop   # Displays :id details
  # app.put      "/workshop/:id",  Middle.admin, Workshop.put.workshop    # Displays information about the :workshop.
  # app.delete   "/workshop/:id",  Middle.admin, Workshop.delete.workshop # Delete's :id
  
  ###
  Member Routes
  ###
  # Member = require("./routes/Member")
  # app.get     "/members",       Middle.auth, Member.get.index     # Lists members. (Query Sensitive)
  # app.get     "/member/:id",    Middle.auth, Member.get.member    # Displays :id details
  # app.post    "/member",        Middle.auth, Member.post.member   # Creates a member
  # app.put     "/member/:id",    Middle.auth, Member.put.member    # Edits :id details
  # app.delete  "/member/:id",    Middle.auth, Member.delete.member # Deletes :id
  # # Special routes:
  # app.post    "/member/:member/workshop/:workshop", Middle.auth, Member.post.workshop   # Adds :member to :workshop
  # app.delete  "/member/:member/workshop/:workshop", Middle.auth, Member.delete.workshop # Deletes :member from :workshop

  ###
  Payment Routes
  ###
  # Payment = require("./routes/Payment")
  # app.get    "/payments",       Middle.admin, Payment.get.index      # Lists payments. (Query Sensitive)
  # app.get    "/payment/:id",    Middle.admin, Payment.get.payment    # Displays :id details
  # app.post   "/payment",        Middle.admin, Payment.post.payment   # Adds a payment
  # app.put    "/payment/:id",    Middle.admin, Payment.put.payment    # Edits :id
  # app.delete "/payment/:id",    Middle.admin, Payment.delete.payment # Removes :id

  ###
  Admin Routes
  ###
  # Admin = require("./routes/Admin")
  # app.get   "/admin",       Middle.admin, Admin.index       # Welcome page for admins.
  # app.get   "/statistics",  Middle.admin, Admin.statistics  # Statistics that are asked for.