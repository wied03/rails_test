describe 'Blog', ->

  it 'should work with stuff 1', ->
    # arrange
    module = modulejs.require 'models/stuff'

    # act
    result = module.stuff 'bah'

    # assert
    expect(result).toEqual('hello bah')