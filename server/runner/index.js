// @flow
import {spawn} from 'child_process'
import ansi from 'ansi-html'

ansi.setColors({
  reset: '4d4d4c',
  red: 'c82829',
  green: '718c00 ',
  yellow: 'eab700',
  blue: '4271ae',
  magenta: '8959a8',
  cyan: '718c00',
  lightgrey: '545452',
  darkgrey: '3b3b3a'
})

let runningChild = null
let out = ''

function format(str) {
  const transformed =
    str.trim()
    .replace(/\n/g, '<br>')
    .replace(/\[\?25l/g, '')
  const stripped =
    ansi(transformed)
    // Clean up some cruft at the beginning.
    .replace('<br><span style="color:#545452;"></span><br>', '')
  return stripped
}
export default function(socket: Socket, pattern: string, root: string): void {
  if (runningChild) {
    runningChild.kill()
  }

  runningChild = spawn(
    'mocha',
    ['--color', '-w', '-g', pattern],
    { cwd: root }
  )

  out = ''

  runningChild.stdout.on('data', data => {
    out += data.toString('utf-8')
    socket.emit('test results', format(out))
  })

  runningChild.stderr.on('data', data => {
    out += data.toString('utf-8')
    socket.emit('test results', format(out))
  })

  runningChild.on('close', () => {
    console.log('Test process ceased to run')
  })
}
