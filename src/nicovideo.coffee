email = process.env.NICOVIDEO_EMAIL
password = process.env.NICOVIDEO_PASSWORD
export_directory = process.env.NICOVIDEO_FOLDER

nicovideo = require('./niconico')(email: email, password: password, folder: export_directory)

module.exports = (robot) ->
  robot.respond /nicovideo (.*)/i, (msg) ->
    video_id = msg.match[1]
    nicovideo.download(video_id)
    nicovideo.on 'exported', (path)->
      msg.send("Exported: #{path}")