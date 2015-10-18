# Description:
#   Hubot responds any thank message politely. Phrases from:
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot [terima]kasih - Hubot accepts your thanks
#   [terima]kasih hubot - Hubot accepts your thanks
#
# Author:
#   github.com/octa7th
#

response = [
  "sama-sama",
  "santai aja",
  "bukan masalah",
  "slow aja bos",
  "sip sip",
  "kembali kasih",
  "oke bos"
]

module.exports = (robot) ->
  robot.respond /((te?ri)?ma) ?kasih?.*/i, (msg) ->
    msg.send msg.random response

  robot.hear /((te?ri)?ma) ?kasih? (.*)/i, (msg) ->
    name = msg.match[3]
    if (name.toLowerCase().indexOf robot.name.toLowerCase()) > -1
      msg.send msg.random response
