# Description:
#   Convert number from and to binary, decimal, octal, and hexadecimal.
#
# Dependencies:
#   None
#
# Commands:
#   hubot <number> <base from> to <base to> - Convert number from and to binary, decimal, octal, and hexadecimal
#
# Author:
#   Muhammad SOfyan

module.exports = (robot) ->

  robot.respond /([0-9a-f]+) +(bin|de[cs]|o[ck]t|hex)[a-z]* +(ke|to) +(bin|de[cs]|o[ck]t|hex)[a-z]*(.*)/i, (res) ->
    origin = res.match[1]
    from = res.match[2]
    to = res.match[4]

    if from.match /^bin/
      value = parseInt origin, 2
    else if from.match /^de[sc]/
      value = parseInt origin, 10
    else if from.match /^o[ck]t/
      value = parseInt origin, 8
    else
      value = parseInt origin, 16

    if to.match /^bin/
      result = value.toString 2
    else if to.match /^de[sc]/
      result = value.toString 10
    else if to.match /^o[ck]t/
      result = value.toString 8
    else
      result = value.toString 16

    result = result.toUpperCase()

    res.send "#{origin} #{from} = #{result} #{to}"
