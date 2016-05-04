// @flow
import {spawn} from 'child_process'
import ansi from 'ansi-html'
import treeKill from 'tree-kill'

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

function checkForReset(str) {
  // This regex matches anything up to and including the characters:
  // [2J[1;3H
  // which Mocha sends to the terminal, telling it to clear itself.
  return str.replace(/((.|\n)*\[2J\[1;3H).*/, '')
}

export default function(socket: Socket, pattern: string, root: string): void {
  console.log('Running the test job')

  const onData = data => {
    out += data.toString('utf-8')
    out = checkForReset(out)
    socket.emit('test results', format(out))
  }

  const onErr = data => {
    out += data.toString('utf-8')
    out = checkForReset(out)
    socket.emit('test results', format(out))
  }

  if (runningChild) {
    console.log('Killing the old test job', runningChild.pid)
    runningChild.stdout.removeListener('data', onData)
    runningChild.stderr.removeListener('data', onErr)
    treeKill(runningChild.pid)
  }

  runningChild = spawn(
    'mocha',
    ['--colors', '-w', '-g', pattern],
    { cwd: root }
  )

  out = ''

  runningChild.stdout.on('data', onData)
  runningChild.stderr.on('data', onErr)
  runningChild.on('close', () => {
    console.log('Test process ceased to run')
  })
}
