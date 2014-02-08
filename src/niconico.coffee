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

fetch = (uri, path, callback) ->
  request.head uri, (err, res, body) ->
    console.log('content-type:', res.headers['content-type'])
    console.log('content-length:', res.headers['content-length'])
    console.log "exporting: #{path}"

    req = request(uri).pipe(fs.createWriteStream(path))
    req.on('finish', callback)

sign_in = (email, password, callback) ->
  #console.log "sign_in"
  options =
    url: "https://secure.nicovideo.jp/secure/login?site=niconico"
    form: { mail: email, password: password }
    secureProtocol: 'SSLv3_method'

  request.post options, (error, response, body) ->
    console.log('status: '+ response.statusCode)
    callback(null)

get_video = (video_id, callback) ->
  #console.log "get_video"
  request.get {url: "http://www.nicovideo.jp/watch/#{video_id}"}, (error, response, body) ->
    console.log "get response"
    console.log('status: '+ response.statusCode)
    callback(null)

get_flv = (video_id, callback) ->
  #console.log "get_flv"
  request.get {url: "http://www.nicovideo.jp/api/getflv?v=#{video_id}"}, (error, response, body) ->
    console.log('status: '+ response.statusCode)
    flvinfo =
      thread_id: body.split("&")[0].split("=")[1]
      url: querystring.unescape(body.split("&")[2].split("=")[1])
    #console.log flvinfo
    callback(null, flvinfo)

get_thumbinfo = (video_id, callback) ->
  #console.log "get_thumbinfo"
  request.get {url: "http://ext.nicovideo.jp/api/getthumbinfo/#{video_id}"}, (error, response, body) ->
    console.log('status: '+ response.statusCode)
    parseString body, (err, result) ->
      thumbinfo =
        video_id: result.nicovideo_thumb_response.thumb[0].video_id[0]
        title: result.nicovideo_thumb_response.thumb[0].title[0]
        description: result.nicovideo_thumb_response.thumb[0].description[0]
        watch_url: result.nicovideo_thumb_response.thumb[0].watch_url[0]
        thumbnail_url: result.nicovideo_thumb_response.thumb[0].thumbnail_url[0]
        movie_type: result.nicovideo_thumb_response.thumb[0].movie_type[0]
      #console.log thumbinfo
      callback(null, thumbinfo)

download = (video_id, msg) ->
  flvinfo = null
  thumbinfo = null
  fileinfo = {}

  async.waterfall([
    (callback) ->
      sign_in(email, password, callback)

    (callback) ->
      get_video(video_id, callback)

    (callback) ->
      get_flv(video_id, callback)
    
    (_flvinfo, callback) ->
      flvinfo = _flvinfo
      get_thumbinfo(video_id, callback)
    
    (_thumbinfo, callback) ->
      thumbinfo = _thumbinfo
      msg.send(thumbinfo.title)
      msg.send(thumbinfo.description)

      escapedTitle = thumbinfo.title.replace(/\//g, "／")

      fileinfo.filename = "#{escapedTitle}.#{thumbinfo.movie_type}"
      fileinfo.filepath = path.resolve(path.join(export_directory, fileinfo.filename))
      fetch(flvinfo.url, fileinfo.filepath, callback)

    (callback) ->
      msg.send("Exported: #{fileinfo.filepath}")
  ])

module.exports =
  download: download

  