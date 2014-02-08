fs = require('fs')
request = require('request')
async = require('async')
querystring = require('querystring')
mime = require('mime')
path = require('path')
parseString = require('xml2js').parseString

email = process.env.NICOVIDEO_EMAIL
password = process.env.NICOVIDEO_PASSWORD
export_directory = process.env.NICOVIDEO_FOLDER

request = request.defaults({jar: true})

download = (uri, name, callback) ->
  request.head uri, (err, res, body) ->
    console.log('content-type:', res.headers['content-type'])
    console.log('content-length:', res.headers['content-length'])

    filename = "#{name}.#{mime.extension(res.headers['content-type'])}"
    filepath = path.resolve(path.join(export_directory, filename))
    console.log "exporting: #{filepath}"

    req = request(uri).pipe(fs.createWriteStream(filepath))
    req.on('finish', callback(filepath))

sign_in = (email, password, callback) ->
  console.log "sign_in"
  options =
    url: "https://secure.nicovideo.jp/secure/login?site=niconico"
    form: { mail: email, password: password }
    secureProtocol: 'SSLv3_method'

  request.post options, (error, response, body) ->
    console.log('status: '+ response.statusCode)
    callback(null)

get_video = (video_id, callback) ->
  console.log "get_video"
  request.get {url: "http://www.nicovideo.jp/watch/#{video_id}"}, (error, response, body) ->
    console.log "get response"
    console.log('status: '+ response.statusCode)
    callback(null)

get_flv = (video_id, callback) ->
  console.log "get_flv"
  request.get {url: "http://www.nicovideo.jp/api/getflv?v=#{video_id}"}, (error, response, body) ->
    console.log('status: '+ response.statusCode)
    console.log(body)
    url = querystring.unescape(body.split("&")[2].split("=")[1])
    callback(null, url)

get_thumbinfo = (video_id, callback) ->
  console.log "get_thumbinfo"
  request.get {url: "http://ext.nicovideo.jp/api/getthumbinfo/#{video_id}"}, (error, response, body) ->
    console.log('status: '+ response.statusCode)
    parseString body, (err, result) ->
      console.log(result)
      # nicovideo_thumb_response/thumb/movie_type
      # callback(null, )

module.exports = (robot) ->
  robot.respond /nicovideo (.*)/i, (msg) ->
    query = msg.match[1]
    msg.send("Video ID: #{query}")
    async.waterfall([
      (callback) ->
        sign_in(email, password, callback)

      (callback) ->
        get_video(query, callback)

      (callback) ->
        get_flv(query, callback)
      
      (url, callback) ->
        msg.send("Downloading: #{url}")
        download(url, "video", callback)

      (filepath, callback) ->
        msg.send("Exported: #{filepath}")
    ])