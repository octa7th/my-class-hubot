# Description:
#   Remind everyone when pray time comes up
#
# Dependencies:
#   chrono-node
#
# Configuration:
#   MUSLIM_SALAT_API_KEY - Get it from muslimsalat.com
#   SALAT_REMINDER_AREA - default jakarta
#   SALAT_REMINDER_CHANNEL - default general
#
# Commands:
#
# Author:
#   github.com/octa7th
#
#
chrono = require 'chrono-node'

enableAnnounce = [
  'dhuhr',
  'asr',
  'maghrib',
  'isha'
]

class Schedule
  constructor: (@robot, data) ->
    @name = data.name
    @date = chrono.parseDate data.time
    @channel = process.env.SALAT_REMINDER_CHANNEL or 'general'
    @unixtime = 0

    if @date is null
      return

    @unixtime = @date.getTime()

  create_response: () ->
    localization =
      fajr: 'Subuh'
      dhuhr: 'Dzuhur'
      asr: 'Ashar'
      maghrib: 'Maghrib'
      isha: 'Isya'

    name = localization[@name]

    responses = [
      "Udah masuk waktu #{name} nih. Kita ke masjid yuk."
      "Udah azan #{name} nih. Ke masjid yuk."
      "Waktunya sholat #{name}. Ayo kita berjamaah :smile:"
      "Sekarang waktunya sholat #{name}. Kawan-kawan jangan lupa shalat ya."
      "Alhamdulillah udah masuk waktu #{name}. Ayo kita sholat :smile:"
      "Udah waktunya sholat #{name}. Ada yang mau bareng ke masjid?"
    ]

    random_index = Math.floor(Math.random() * responses.length)
    responses[random_index]

  announce: ->
    @robot.send room: @channel, @create_response()
    true

module.exports = (robot) ->

  get_schedule = ->
    if process.env.MUSLIM_SALAT_API_KEY == undefined
      throw new Error("Missing MUSLIM_SALAT_API_KEY env variable.")
      return

    apiKey = process.env.MUSLIM_SALAT_API_KEY
    location = process.env.SALAT_REMINDER_AREA or 'jakarta'

    url = "http://muslimsalat.com/#{location}.json"

    robot
      .http(url)
      .query(key: apiKey)
      .get() (err, res, body) ->
        resp = JSON.parse body
        if resp.status_code is 0
          throw new Error("Cannot fetch pray time for #{location}.")
        else
          create_schedule resp

  create_schedule = (resp) ->
    data = resp.items[0]
    schedules = []
    for own name, time of data
      if name not in enableAnnounce then continue
      dt =
        name: name
        time: time
      schedules.push new Schedule(robot, dt)

    process_schedule schedules

  process_timeout = 0
  process_schedule = (schedules) ->
    now = (new Date).getTime()
    closest = null
    for schedule in schedules
      time_diff = schedule.unixtime - now
      if time_diff > 0
        if closest is null
          closest = schedule
        else
          if schedule.unixtime < closest.unixtime
            closest = schedule

    # console.log 'closest', closest
    if closest is null
      # TODO repeat process
      return

    time_diff = closest.unixtime - now
    clearTimeout process_timeout
    # console.log "announce to sholat #{closest.name} in #{time_diff}"
    process_timeout = setTimeout( ->
      closest.announce()
      setTimeout(->
        process_schedule schedules
      , 5e3)
    , time_diff)

  robot.brain.on 'loaded', ->
    ready = true
    get_schedule()
