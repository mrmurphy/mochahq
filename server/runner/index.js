// @flow
import {spawn} from 'child_process'

let runningChild = null
let out = ''

export default function(socket: Socket, pattern: string, root: string): void {
  if (runningChild) {
    runningChild.kill("9")
  }

  runningChild = spawn(
    'mocha',
    ['-w', '-g', pattern],
    { cwd: root }
  )

  runningChild.stdout.on('data', data => {
    out += data.toString('utf-8')
    socket.emit('test results', out)
  })

  runningChild.stderr.on('data', data => {
    out += data.toString('utf-8')
    socket.emit('test results', out)
  })

  runningChild.on('close', () => {
    console.log('Test process ceased to run')
  })
}
