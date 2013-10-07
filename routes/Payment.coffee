Group = require('../schema/Group')
Payment = require('../schema/Payment')

Payments = module.exports = {
  get:
    payments: (req, res) ->
      Group.model.findById(req.session.group._id).populate('_payments').exec (err, group) ->
        group.getCost (err, cost) ->
          group.getPaid (err, paid) ->
            res.render "templates/payments",
              group: group
              cost: cost
              paid: paid
              session: req.session
  post:
    payment: (req, res) ->
      Payment.model.create {
        amount:      req.body.amount
        type:        req.body.type
        date:
          day:         req.body.day
          month:       req.body.month
          year:        req.body.year
        description: req.body.description
        _group: req.session.group._id
      }, (err, payment) ->
        unless err
          res.redirect "/account"
        else
          res.redirect "/account?errors=#{err}"
  # TODO: PUT, POST, DELETE

}