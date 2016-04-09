// @flow

import fs from 'fs-extra-promise'
import path from 'path'
import _ from 'lodash/fp'
import _n from 'lodash'
import _glob from 'glob'
import bb from 'bluebird'
import balanced from 'balanced-match'

const glob = bb.promisify(_glob.glob)

export type TestBlock = {
  name: string,
  children?: Array<TestBlock>
}

export async function findTestFiles(root: string): Promise<Array<string>> {
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

  let files: Array<Array<string>> = await bb.all(promises)


  let flatFiles: Array<string> = _.flatten(files)
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
  let nameMatch
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
