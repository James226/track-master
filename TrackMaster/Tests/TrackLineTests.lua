describe("TrackLine", function()
	local TrackMaster, trackMaster, TrackLine, Tracker, trackLine

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
		TrackMaster = Apollo.GetAddon("TrackMaster")
		TrackLine = _G['TrackMasterLibs']['TrackLine']
		Tracker = _G['TrackMasterLibs']['Tracker']
	end)

	before_each(function()
		trackMaster = TrackMaster.new()
		trackLine = TrackLine.new({})
		table.insert(trackMaster.lines, trackLine)
	end)

	describe("AddTracker", function()
		it("should add tracker to list", function()
			trackLine:AddTracker(Tracker.new(trackMaster))

			assert.is.same(1, #trackLine.trackers)
		end)

		it("should not add the same tracker to the list multiple times", function()
			local tracker = Tracker.new()
			trackLine:AddTracker(tracker)
			trackLine:AddTracker(tracker)

			assert.is.same(1, #trackLine.trackers)
		end)
	end)


	describe("RemoveTracker", function()
		it("should remove tracker to list", function()
			local tracker = Tracker.new()

			trackLine:AddTracker(tracker)
			trackLine:RemoveTracker(tracker)

			assert.is.same(0, #trackLine.trackers)
		end)

		it("should not throw if tracker does not exist", function()
			local tracker = Tracker.new()
			assert.no_error(function() trackLine:RemoveTracker(tracker) end)
		end)
	end)

	describe("Update", function()
		before_each(function()
			local player = CreateUnit()
			function player:GetHeading() return 0 end
			stub(GameLib, "GetPlayerUnit", function() return player end)

			Unit.is = mock(Unit.is, true, function() return true end)
		end)

		after_each(function()
			GameLib.GetPlayerUnit:revert()
			Unit.is:revert()
		end)

		it("should set no target if no trackers exist", function()
			trackLine:Update()

			assert.is_nil(trackLine.target)
		end)

		it("should set target for single tracker", function()
			local target = CreateUnit()
			target.__position.x = 21
			local tracker = mock(Tracker.new(), true)
			tracker.GetTarget = function(self)
				return target
			end

			trackLine:AddTracker(tracker)
			trackLine:Update()
			assert.is.same(target, trackLine.target)
		end)

		it("should set target to nearest for multiple trackers", function()
			local target = CreateUnit()
			target.__position.x = 22
			local tracker = mock(Tracker.new(), true)
			tracker.GetTarget = function(self)
				return target
			end
			trackLine:AddTracker(tracker)

			local target2 = CreateUnit()
			target2.__position.x = 21
			local tracker2 = mock(Tracker.new(), true)
			tracker2.GetTarget = function(self)
				return target2
			end
			trackLine:AddTracker(tracker2)

			trackLine:Update()
			assert.is.same(target2, trackLine.target)
		end)

		it("should not throw if tracker returns nil target", function()
			local tracker = mock(Tracker.new(), true)
			tracker.GetTarget = function(self)
				return nil
			end
			trackLine:AddTracker(tracker)
			assert.no_error(function() trackLine:Update() end)
		end)
	end)
end)