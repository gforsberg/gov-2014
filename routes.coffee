# Don't put static routes here! Just drop them in `static`

routes = module.exports = (app) ->
  Middle = require("./routes/Middleware")
  ###
  General Routes
  ###
  General = require("./routes/General")
  app.get   "/",          General.get.index     # Welcome page
  app.get   "/news",      General.get.news      # News page
  app.get   "/about",     General.get.about     # About page
  app.get   "/schedule",  General.get.schedule  # Schedule page
  app.get   "/privacy",   General.get.privacy   # Privacy Policy
  app.get   "/faq",       General.get.faq       # Frequently Asked Questions
  app.get   "/venues",    General.get.venues    # Venues

  ###
  Account Routes
  ###
  Account = require("./routes/Account")
  app.get   "/register",  Account.get.register  # Gets a registration/login page.
  # # Register/Login/Logout
  app.post  "/login",     Account.post.login    #
  app.get  "/logout",     Account.get.logout   #
  # Printout
  app.get   "/printout",  Middle.auth, Account.get.printout
  # # Recovery
  app.get   "/recover/:email",  Account.get.recover   # Start recovery 
  app.get   "/recovery/:hash",  Account.get.recovery # Finish recovery
  # # Edit/See details
  app.get   "/account",   Middle.auth, Account.get.account   # Edit group details.
  app.put   "/account",   Middle.auth, Account.put.account   #
  app.get   "/checkin/:id",   Middle.admin, Account.get.checkin  # Checkin for groups
  # # Main information pages, actions can be accessed here.
  # app.get   "/members",   Middle.auth, Account.get.members   # Add/remove/edit members.
  # app.get   "/billing",   Middle.auth, Account.get.billing   # Add/remove/edit payments.
  app.delete "/account/:id",  Middle.auth, Account.delete.account # Delete an account.

  ###
  Workshop Routes
  ###
  Workshop = require("./routes/Workshop")
  app.get      "/workshops",     Workshop.get.index                     # Lists workshops. (Query Sensitive)
  app.get      "/workshop",      Middle.admin, Workshop.get.edit        # Gets details of a workshop to edit.
  app.get      "/workshop/:id",  Workshop.get.id                        # Displays :id details
  app.get     "/workshop/members/:id/:session", Middle.auth, Workshop.get.members   # Displays state of members in the group and allows for toggling of workshops.
  app.post     "/workshop",      Middle.admin, Workshop.post.workshop   # Displays :id details
  app.put      "/workshop",      Middle.admin, Workshop.put.workshop    # Displays information about the :workshop.
  app.get      "/workshop/delete/:id",  Middle.admin, Workshop.delete.workshop # Delete's :id
  
  ###
  Member Routes
  ###
  Member = require("./routes/Member")
  # app.get     "/members",       Middle.auth, Member.get.index     # Lists members. (Query Sensitive)
  app.get     "/member",        Middle.auth, Member.get.member    # Displays ?id details (Query Sensitive)
  app.post    "/member",        Middle.auth, Member.post.member   # Creates a member
  app.put     "/member",        Middle.auth, Member.put.member    # Edits :id details
  app.delete  "/member/:id",    Middle.auth, Member.delete.member # Deletes :id
  # # Special routes:
  app.get     "/member/workshops", Middle.auth, Member.get.memberWorkshops
  app.get     "/member/:member/add/:workshop/:session", Middle.auth, Member.get.addWorkshop   # Adds :member to :workshop
  app.get     "/member/:member/del/:workshop/:session", Middle.auth, Member.get.delWorkshop   # Deletes :member from :workshop

  ###
  Payment Routes
  ###
  Payment = require("./routes/Payment")
  app.get    "/payments",         Middle.auth, Payment.get.payments      # Lists payments. (Query Sensitive)
  # app.get    "/payment/:id",    Middle.admin, Payment.get.payment    # Displays :id details
  app.post   "/payment",          Middle.admin, Payment.post.payment   # Adds a payment
  app.get    "/payment/delete/:id", Middle.admin, Payment.delete.payment # Deletes a payment
  # app.put    "/payment/:id",    Middle.admin, Payment.put.payment    # Edits :id
  # app.delete "/payment/:id",    Middle.admin, Payment.delete.payment # Removes :id

  ###
  Admin Routes
  ###
  Admin = require("./routes/Admin")
  app.get   "/admin",       Middle.admin, Admin.get.index       # Welcome page for admins.
  app.get   "/manage/:id",  Middle.admin, Admin.get.manage      # Logs in the admin as :id
  app.get   "/notes/:id",   Middle.admin, Admin.get.notes       # Gets the notes for the group :id
  app.put   "/notes/:id",   Middle.admin, Admin.put.notes       # Saves the notes for the gorup :id
  app.get   "/statistics",  Middle.admin, Admin.get.statistics  # Statistics that are asked for.
  app.get   "/emails",      Middle.admin, Admin.get.emails      # Email addresses that are used.
