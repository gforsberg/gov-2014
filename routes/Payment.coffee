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
  # TODO: PUT, POST, DELETE

}