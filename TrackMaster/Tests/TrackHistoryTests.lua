describe("TrackHistory", function()
	local TrackHistory, trackHistory, target

	local function CreateUnit()
		local unit = {
			__position = {
				x = 0,
				y = 0,
				z = 0
			}
		}

		function unit:GetPosition()
			return unit.__position
		end

		return unit
	end

	setup(function()
		TrackHistory = _G['TrackMasterLibs']['TrackHistory']
	end)

	before_each(function()
		trackHistory = TrackHistory.new()
		target = CreateUnit()
	end)

	describe("On Update", function()
		it("RegisterCallback value should be called", function()
			local registerCallbackCalled = false
			trackHistory:RegisterCallback(function()
				registerCallbackCalled = true
			end)

			trackHistory:Update()

			assert.is_true(registerCallbackCalled)
		end)

		it("Callback should pass a nil target", function()
			local targetReceived = nil
			trackHistory:RegisterCallback(function(target)
				targetReceived = target
			end)

			trackHistory:Update()

			assert.is_nil(targetReceived)
		end)

		it("AddTarget should add target to list", function()
			trackHistory:AddTarget(target)

			assert.are.same(1, #trackHistory.targets)
			assert.are.same(target, trackHistory.targets[1])
		end)

		it("AddTarget should not add target if already in list", function()
			trackHistory:AddTarget(target)
			trackHistory:AddTarget(target)

			assert.are.same(1, #trackHistory.targets)
		end)

		it("RemoveTarget should remove target from list", function()
			trackHistory:AddTarget(target)

			trackHistory:RemoveTarget(target)

			assert.are.same(0, #trackHistory.targets)
		end)
	end)

	describe("Callback", function()
		local targetReceived = {}
		local callbackReceived = false
		local player

		before_each(function()
			player = CreateUnit()
			trackHistory:RegisterCallback(function(target)
				callbackReceived = true
				targetReceived = target
			end)
			stub(GameLib, "GetPlayerUnit", function() return player end)
			stub(Unit, "is", function() return true end)
		end)

		after_each(function()
			GameLib.GetPlayerUnit:revert()
			Unit.is:revert()
		end)

		it("should return nil if no targets exist", function()
			trackHistory:Update()

			assert.is_true(callbackReceived)
			assert.is_nil(targetReceived)
		end)

		it("should return target if only one exists", function()
			trackHistory:AddTarget(target)
			trackHistory:Update()

			assert.are.same(target, targetReceived)

		end)

		it("should return closest target if multiple exist", function()
			local target1 = CreateUnit()
			target1.__position.x = 2
			trackHistory:AddTarget(target1)
			local target2 = CreateUnit()
			target2.__position.x = 1
			trackHistory:AddTarget(target2)

			trackHistory:Update()

			assert.are.same(target2, targetReceived)
		end)
	end)
end)