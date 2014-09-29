describe 'Blog', ->

  it 'should work with stuff 1', ->
    # arrange
    module = modulejs.require 'models/stuff'
    setFixtures('<input type="text" class="textField"/>')
    $(".textField").val('the text')

    # act
    result = module.stuff 'bah'

    # assert
    expect(result).toEqual('hello bah and the text')