modulejs.define 'models/stuff', ->
  my = {}

  my.stuff = (foo) ->
    s = $(".textField").val()
    "hello #{foo} and #{s}"

  my
