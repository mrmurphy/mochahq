import * as assert from 'assert'
import * as path from 'path'

import findBlocks, {findTestFiles} from '../../blockfinder'
import {TestBlock} from '../../blockfinder'

const fixturePath = path.resolve('test-fixture')

describe('the block finder', function() {
  it('should identify correctly which source files to use', async function() {
    const testFiles = await findTestFiles(fixturePath)

    assert.deepEqual(
      testFiles,
      [path.resolve('test-fixture', 'foo', 'bar', 'test.js')]
    )
  })

  it('should properly extract test blocks', async function() {
    const blocks: TestBlock[] = await findBlocks(fixturePath)
    assert.deepEqual(blocks, [
      {
        name: 'a top level describe',
        children: [
          { name: 'with a nested it', children: [] },
          { name: 'with another it', children: [] },
          { name: 'a nested describe', children: [
            {name: 'with a mega-nested it', children: []}
          ]},
        ]
      },
      {
        name: 'a second tld',
        children: [
          {name: "should work well", children: []}
        ]
      }
    ])
  })
})
