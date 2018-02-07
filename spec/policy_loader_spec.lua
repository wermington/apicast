local _M = require 'apicast.policy_loader'

describe('APIcast Policy Loader', function()

  describe(':call', function()
    it('finds apicast builtin policy', function()
      local root = require('apicast.policy.apicast')
      local sandbox = _M:call('apicast')

      assert.is_table(sandbox)
      assert.are_not.same(root, sandbox)
      assert.equal(root._NAME, sandbox._NAME)
      assert.equal(root._VERSION, sandbox._VERSION)
    end)

    it('uses sandboxed load paths', function()
      local ok, ret = pcall(_M.call, _M, 'unknown', '0.1')

      assert.falsy(ok)
      assert.match([[module 'policy' not found:
%s+no file '%g+/gateway/policies/unknown/0.1/policy.lua']], ret)
    end)

    it('loads two instances of the same policy', function()
      local test = _M:call('test', '1.0.0-0', 'spec/fixtures')
      local test2 = _M:call('test', '1.0.0-0', 'spec/fixtures')

      test.one = 1
      assert.falsy(test2.one)
      assert.are_not.same(test, test2)

      assert.are.same(test.dependency, test2.dependency)
      assert.are_not.equal(test.dependency, test2.dependency)
    end)

    it('loads two versions of the same policy', function()
      local test = _M:call('test', '1.0.0-0', 'spec/fixtures')
      local test2 = _M:call('test', '2.0.0-0', 'spec/fixtures')

      assert.are.same({ '1.0 dependency' }, test.dependency)
      assert.are.same({ '2.0 dependency' }, test2.dependency)
    end)
  end)
end)