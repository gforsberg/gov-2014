Member = require("../schema/Member")

MemberRoutes = module.exports = {
  post:
    member: (req, res) ->
      # Is it a youth in care?
      inCare = (req.body.youthInCare == "Yes")
      Member.model.create {
        name:         req.body.name
        _group:       req.session.group._id
        type:         req.body.type
        gender:       req.body.gender
        birthDate:
          day:        req.body.birthDay
          month:      req.body.birthMonth
          year:       req.body.birthYear
        phone:        req.body.phone
        email:        req.body.email
        emergencyContact:
          name:       req.body.emergName
          relation:   req.body.emergRelation
          phone:      req.body.emergPhone
        emergencyInfo:
          medicalNum: req.body.emergMedicalNum
          allergies:  req.body.emergAllergies
          conditions: req.body.emergConditions
        _state:
          youthInCare: inCare
      }, (err, member) ->
        unless err?
          # We don't really need to refresh the entire group here.
          req.session.group._members.push(member._id)
          res.redirect "/account"
        else
          res.redirect "/account?errors=#{JSON.stringify(err.errors)}"
}