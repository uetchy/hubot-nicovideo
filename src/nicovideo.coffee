email = process.env.NICOVIDEO_EMAIL
password = process.env.NICOVIDEO_PASSWORD
export_directory = process.env.NICOVIDEO_FOLDER

niconico = require('./../src/niconico')

nicovideo = new niconico.Nicovideo(
  email: email,
  password: password,
  folder: export_directory
)

module.exports = (robot) ->
  robot.respond /nicovideo (.*)/i, (msg) ->
    video_id = msg.match[1]
    nicovideo.download(video_id)
    nicovideo.on 'fetched', (status, meta) ->
      msg.send(meta.title)
      msg.send(meta.description)
    
    nicovideo.on 'exported', (path)->
      msg.send("Exported: #{path}")