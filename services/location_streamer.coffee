twitter = require 'ntwitter'
EventEmitter = require('events').EventEmitter

class LocationStreamer extends EventEmitter

  options = 
    consumer_key: 'c3NNk6syXwUqbgwKirtK1w'
    consumer_secret: 'PBR0IHNxp75W2LV2ThRqy1NeJCepJRMhlWJgQBEgk'
    access_token_key: '237468953-QaRypb0kOJ0wG3a9f1kHuyVvmIbbawU2axOPJW7S'
    access_token_secret: 'tAAYDfR7EWDD6FVE5mvVedcISThv5LB3t6RTkBwt0' 

  constructor: () ->
    @locations = []
    @listening = false
    @stream = undefined

  addLocation: (location) ->   
    lat = location.primary.boundingBox.southwest.lat
    lng = location.primary.boundingBox.southwest.lng

    lat2 = location.primary.boundingBox.northeast.lat
    lng2 = location.primary.boundingBox.northeast.lng

    key = "#{lng},#{lat},#{lng2},#{lat2}"
  
    if @locations.indexOf(key) == -1
      @locations.push key

    if !@listening
      @start()
    else
      @restart()

    return key
  
  removeLocation: (key) -> 
    index = @locations.indexOf key
    @locations.splice index, 1
    @stop() if @locations.length == 0
  
  stop: ->
    @stream.destroy() if @stream
    @stream = undefined
    @listening = false
    
  start: ->
    console.log 'starting streamer ' + @locations.join()
    
    @twitter = new twitter(options)

    @twitter.stream 'statuses/filter', locations: @locations.join(), (s) =>
      
      @stream = s     
      
      s.on 'data', (data) =>
        @emit 'streamdata', data

      s.on 'end', (r) =>
        console.log 'stream ended'
      
      s.on 'destroy', (r) =>
        console.log 'stream destroyed'

    @listening = true

  restart: () ->
    @stop()
    @start()

module.exports = LocationStreamer