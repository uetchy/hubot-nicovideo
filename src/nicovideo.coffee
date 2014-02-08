nicovideo = require('./niconico')

module.exports = (robot) ->
  robot.respond /nicovideo (.*)/i, (msg) ->
    query = msg.match[1]
    nicovideo.download(query, msg)