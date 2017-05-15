converter = new showdown.Converter()
markdown = (txt) -> converter.makeHtml(txt)

getTime = -> (new Date).getTime()

loadJson = (file) ->
  result = $.ajax
    dataType: 'json'
    url: file
    async: false
  return result.responseJSON

zip = (rows...) -> rows[0].map((_,c) -> rows.map((row) -> row[c]))

check = (name, val) ->
  if val is undefined
    throw new Error "#{name}is undefined"
  val

delay = (time, func) -> setTimeout func, time

checkObj = (obj, keys) ->
  if not keys?
    keys = Object.keys(obj)
  for k in keys
    if obj[k] is undefined
      console.log 'Bad Object: ', obj
      throw new Error "#{k} is undefined"
  obj

assert = (val) ->
  if not val
    throw new Error 'Assertion Error'
  val

checkWindowSize = (width, height, display) ->
  console.log 'Window too small!'
  win_width = $(window).width()
  maxHeight = $(window).height()
  if $(window).width() < width or $(window).height() < height
    display.hide()
    $('#window_error').show()
  else
    $('#window_error').hide()
    display.show()