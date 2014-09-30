$ ->
  app = modulejs.require('models/stuff')
  $('.injected-js').text(app.stuff('howdy2'))
