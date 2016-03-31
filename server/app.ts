import * as express from 'express'
import * as http from 'http'
import * as _io from 'socket.io'
import * as path from 'path'
import findBlocks from './blockfinder'
import * as cors from 'cors'

let app = express()
let server = http.createServer(app)
let io = _io(server)

let args = process.argv
let rootPath = args[2] || '.'
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

  socket.on('run test', function(testName: string) {
    console.log('should run test ', testName)
  })


  findBlocks(root).then(blocks => {
    socket.emit('test blocks', JSON.stringify(blocks))
  })
})

app.use(express.static(path.resolve('..', 'client', 'public')))

server.listen(4042, () => {
  console.log('TestHQ serving on port 4042, from ' + root)
})
