#= require jquery-2.0.0.min.js
#= require imagesloaded.pkgd.min.js
#= require raf.js
class FlickrAPI
  constructor: (@options) ->

  url: -> "http://api.flickr.com/services/rest/?#{$.param(@options)}&format=json&jsoncallback=?"

  getPhotos: (callback) ->
    $.getJSON @url(), (data) =>
      callback new flickrPhoto(photo) for photo in data.photos.photo

class flickrPhoto
  constructor: (@data) ->
    @el = @build_el()
    @width  = parseInt(@data.width_n)
    @height = parseInt(@data.height_n)
    @ratio  = @width / @height

  resize: (height)->
     @el.attr('height', height)
     @el.attr('width', Math.floor(@ratio * height))

  build_el: ->
    $("<img class='is-loading' src='#{@data.url_n}'>").data('flickrPhoto', @)

jQuery ->
  photos           = []
  $wallpaper       = $('.wallpaper')
  $window          = $(window)
  widthCache       = 0
  calculationCache = {}

  bustCache = ->
    widthCache       = 0
    calculationCache = {}

  flickrAPI = new FlickrAPI
    api_key:  "4b9ddf8c36f08fb39da637eb72a839bb"
    user_id:  "74505510@N00"
    method:   "flickr.people.getPublicPhotos"
    extras:   "url_n"
    per_page: "500"

  flickrAPI.getPhotos (photo) ->
    index = photos.length
    photos.push(photo)
    photo.el.appendTo $wallpaper
    imagesLoaded(photo.el).on 'progress', (instance, image) ->
      if image.isLoaded
        photo.el.toggleClass('is-loading is-loaded')
      else
        photo.el.remove()
        photos.splice(index, 1)
      bustCache()

  guttter = 5
  targetHeight = 450
  heightVarance = 125
  heightRange = [(targetHeight - heightVarance)..(targetHeight + heightVarance)]
  widthOverflow = 10
  startingOffset = 0
  startingCalculationResult = []

  calculate = (targetWidth, offset, result) ->
    targetWidthOverflow = (targetWidth - widthOverflow)

    for height in heightRange
      group_width = 0
      count       = 0
      for photo in photos[offset..photos.length]
        if (group_width > targetWidthOverflow) and (group_width < targetWidth)
          length = offset + count

          result.push({
            height: height
            offset: offset
            length: length
            count: count
            group_width: group_width
          })

          if length < photos.length
            newOffset = length
            calculate(targetWidth, newOffset, result)
          return result

        else
          count += 1
          group_width += (height * photo.ratio) + (guttter * 2)

    result

  render = ->
    window.requestAnimationFrame(render)
    width = $window.width()
    unless width == widthCache
      widthCache = width

      calculationCache[width] ?= calculate(width, startingOffset, startingCalculationResult)

      if calculationCache[width].length > 0
        for calc in calculationCache[width]
          for photo in photos[calc.offset...calc.length]
            photo.resize(calc.height)
        calc = calculationCache[width][calculationCache[width].length-1]
        for photo in photos[calc.length...photos.length]
          photo.resize(0)
  render()
