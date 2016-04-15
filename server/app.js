// @flow

import express from 'express'
import http from 'http'
import _io from 'socket.io'
import path from 'path'
import cors from 'cors'

import findBlocks from './blockfinder'
import runner from './runner'

function server(port: number, dir?: string) {
  let app = express()
  let server = http.createServer(app)
  let io = _io(server)

  let args = process.argv
  let rootPath = dir || args[2] || '.'
  let root = path.resolve(rootPath)

  app.use(cors({
    origin: true,
    credentials: true
  }))

  app.get('/testBlocks', function(_: any, res: any) {
    findBlocks(root).then(blocks => {
      res.json(blocks)
    })
  })

  io.on('connection', function(socket: any) {
    console.log('a user connected')

    socket.on('update pattern', function(pattern: string) {
      runner(socket, pattern, root)
    })

    findBlocks(root).then(blocks => {
      socket.emit('test blocks', JSON.stringify(blocks))
    })
  })

  app.use(express.static(path.resolve('..', 'client', 'public')))

  server.listen(port, undefined, undefined, () => {
    console.log(`TestHQ serving on port ${port}, from ${root}`)
  })

  return server
}

if (!module.parent) {
  server(4042)
}

export default server
