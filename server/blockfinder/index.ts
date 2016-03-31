import * as fs from 'fs-extra-promise'
import * as path from 'path'
import * as _ from 'lodash/fp'
import * as _n from 'lodash'
import * as _glob from 'glob'
import * as bb from 'bluebird'
import * as balanced from 'balanced-match'

const glob = bb.promisify<string[], string>(_glob)

export interface TestBlock {
  name: string,
  children?: TestBlock[]
}

export async function findTestFiles(root: string): Promise<string[]> {
  const optsFile = path.join(root, 'test', 'mocha.opts')

  const optsContents = await fs.readFileAsync(
    optsFile, {encoding: 'utf-8'})

  const defaultTestDir = [path.join(root, 'test')]

  let otherRoots = _.flow(
    _.filter((i: string) => !_.startsWith('--', i)),
    _.reject((i: string) => i == ''),
    _.map((i: string) => path.join(root, i))
  )(optsContents.split('\n'))

  let roots = _n.uniq(defaultTestDir.concat(otherRoots))
  let promises = _n.map(
    roots,
    (i: string) => {
      let path = `${i}/**/*.{js,ts}`
      return glob(path)
    }
  )

  let files: string[][] = await bb.all(promises)


  let flatFiles: string[] = _.flatten(files)
  return flatFiles
}

async function readSource(path: string): Promise<string> {
  let src = await fs.readFileAsync(path, {encoding: 'utf-8'})
  return src.split('\n').join('')
}

function extractBlocks(src: string): TestBlock[] {
  let blocks: Array<TestBlock | null> = []
  let matchBlock: any
  while (matchBlock = balanced('{', '}', src)) {
    blocks.push(extractBlock(matchBlock.pre, matchBlock.body))
    src = matchBlock.post
  }
  let droppedNulls: TestBlock[] = _.compact(blocks)
  return droppedNulls
}


function extractBlock(titleLine: string, body: string): TestBlock | null {
  let matchDescribe = /.*describe\(['"`](.*)['"`]/
  let matchIt = /.*?it\(['"`](.*)['"`]/
  let maybeName = titleLine.match(matchDescribe) || titleLine.match(matchIt)
  let nameMatch: RegExpMatchArray
  if (maybeName == null) {
    return null
  } else {
    nameMatch = maybeName
    let children = extractBlocks(body)
    let name = nameMatch[1]
    return {
      name,
      children
    }
  }
}

export default async function(root: string): Promise<TestBlock[]> {
  const testFiles = await findTestFiles(root)
  const sources = await bb.all(
    _n.map(testFiles, readSource)
  )
  const blocks = _.flatten(_.map(extractBlocks, sources))
  return blocks
}
