email = process.env.NICOVIDEO_EMAIL
password = process.env.NICOVIDEO_PASSWORD
folder = process.env.NICOVIDEO_FOLDER

niconico = require('niconico')

nicovideo = new niconico.Nicovideo(
  email: email,
  password: password,
  folder: folder
)

module.exports = (robot) ->
  robot.respond /nicovideo (.*)/i, (msg) ->
    video_id = msg.match[1]
    console.log "Start nicovideo #{video_id}"
    req = nicovideo.download(video_id)
    req.on 'fetched', (status, meta) ->
      msg.send(meta.title)
      msg.send(meta.description)
    
    req.on 'exported', (path)->
      msg.send("Exported: #{path}")