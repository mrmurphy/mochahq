// This file doesn't actually do anything. It's just here as a fixture for the
// tests.
import assert from 'assert'

describe(`a top level describe`, function() {
  it('with a nested it', async () => {
    // Do stuff in here
  })

  it('with another it', async () => {
    // Do stuff in here
  })

  describe("a nested describe", () => {
    it(`with a mega-nested it`, () => {
      // Do more stuff
    })
  })
})

describe('a second tld', function() {
  it('should work well', function() {
    // Nothing
  })
})
