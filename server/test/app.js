import io from 'socket.io-client'
import assert from 'assert'

import mkServer from '../app'

const blockFixture = `[{"name":"a top level describe","children":[{"name":"with a nested it","children":[]},{"name":"with another it","children":[]},{"name":"a nested describe","children":[{"name":"with a mega-nested it","children":[]}]}]},{"name":"a second tld","children":[{"name":"should work well","children":[]}]}]`

describe('The app should run', function() {
  let server

  before(function() {
    server = mkServer(4043, 'server/test-fixture')
  })

  after(function() {
    server.close()
  })

  it('should let a socket.io client connect, and send back a list of tests',
  done => {
    const socket = io.connect('http://localhost:4043/')
    socket.on('test blocks', blocks => {
      assert.equal(blocks, blockFixture)
      done()
    })
  })

  it('should run a test when asked, and stream back results',
  done => {
    const socket = io.connect('http://localhost:4043/')

    socket.emit('update pattern', 'a second tld')

    let results = ''

    socket.on('test results', _results => {
      results = _results
    })

    setTimeout(() => {
      assert.notEqual(results.indexOf('should work well'), -1)
      done()
    }, 500)
  })
})
