describe("TrackMaster", function()
	local TrackMaster, trackMaster
	local loadedForms = {}
	local target = {}

	setup(function()
		TrackMaster = Apollo.GetAddon("TrackMaster")

		local loadForm = Apollo.LoadForm
		Apollo.LoadForm = mock(Apollo.LoadForm, true, function(strFile, strForm, wndParent, tLuaEventHandler)
			local form = loadForm(strFile, strForm, wndParent, tLuaEventHandler)
			table.insert(loadedForms, form)
			return form
		end)

		Apollo.RegisterAddon = mock(Apollo.RegisterAddon, true, function (addon, bool, string, dependencies)
			addon:OnLoad()
		end)
	end)

	teardown(function()
		Apollo.RegisterAddon:revert()
		Apollo.LoadForm:revert()

		for _, form in pairs(loadedForms) do
			form:Destroy()
		end
	end)

	before_each(function()
		_G['TrackMasterLibs']['TrackLine'] = mock(_G['TrackMasterLibs']['TrackLine'])
		_G['TrackMasterLibs']['Tracker'] = mock(_G['TrackMasterLibs']['Tracker'])
		trackMaster = TrackMaster.new()
		trackMaster:Init()
	end)

	after_each(function()
		unmock(_G['TrackMasterLibs']['Tracker'])
		unmock(_G['TrackMasterLibs']['TrackLine'])
	end)

	describe("AddTarget", function()
		it("should add target to line", function()
			trackMaster:AddTarget(target, 1)
			assert.spy(trackMaster.lines[1].AddTarget).was.called_with(trackMaster.lines[1], target)
		end)

		it("should throw an error if no line is specified", function()
			assert.error(function() trackMaster:AddTarget(target, nil) end, "No line specified for TrackMaster:AddTarget")
		end)

		it("should not remove target from line if target is nil", function()
			trackMaster:AddTarget(nil, 1)
			assert.spy(trackMaster.lines[1].AddTarget).was.called(0)
		end)
	end)

	describe("RemoveTarget", function()
		it("should remove target from the line", function()
			trackMaster:RemoveTarget(target, 1)
			assert.spy(trackMaster.lines[1].RemoveTarget).was.called_with(trackMaster.lines[1], target)
		end)

		it("should throw an error if no line is specified", function()
			assert.error(function() trackMaster:RemoveTarget(target, nil) end, "No line specified for TrackMaster:RemoveTarget")
		end)

		it("should not remove target from line if target is nil", function()
			trackMaster:RemoveTarget(nil, 1)
			assert.spy(trackMaster.lines[1].RemoveTarget).was.called(0)
		end)
	end)

	describe("RegisterTracker", function()
		local Tracker = _G['TrackMasterLibs']['Tracker']

		it("should return a new tracker", function()
			local tracker = trackMaster:RegisterTracker()
			assert.is.not_nil(tracker)
			assert.are.same(Tracker, getmetatable(tracker).__index)
		end)
	end)

	describe("Tracker:", function()
		describe("Target", function()
			it("should add target to tracker when target changes", function()
				trackMaster:OnTargetUnitChanged(target)
				assert.spy(trackMaster.trackerList.Target.AddTarget).was.called_with(trackMaster.trackerList.Target, target)
			end)

			it("should remove old target when target changes", function()
				trackMaster:OnTargetUnitChanged(target)

				local newTarget = {}
				trackMaster:OnTargetUnitChanged(newTarget)

				assert.spy(trackMaster.trackerList.Target.RemoveTarget).was.called_with(trackMaster.trackerList.Target, target)
			end)

			it("should not add or remove target if target has not changed", function()
				trackMaster:OnTargetUnitChanged(target)
				trackMaster:OnTargetUnitChanged(target)
				assert.spy(trackMaster.trackerList.Target.AddTarget).was.called(1)
				assert.spy(trackMaster.trackerList.Target.RemoveTarget).was.called(1)
			end)
		end)

		describe("Focus", function()
			it("should add target to line when focus changes", function()
				trackMaster:UpdateFocusTarget(target)
				assert.spy(trackMaster.trackerList.Focus.AddTarget).was.called_with(trackMaster.trackerList.Focus, target)
			end)

			it("should remove old target when focus changes", function()
				trackMaster:UpdateFocusTarget(target)
				local newTarget = {}
				trackMaster:UpdateFocusTarget(newTarget)

				assert.spy(trackMaster.trackerList.Focus.RemoveTarget).was.called_with(trackMaster.trackerList.Focus, target)
			end)

			it("should not add or remove target if focus has not changed", function()
				trackMaster:UpdateFocusTarget(target)
				trackMaster:UpdateFocusTarget(target)
				assert.spy(trackMaster.trackerList.Focus.AddTarget).was.called(1)
				assert.spy(trackMaster.trackerList.Focus.RemoveTarget).was.called(1)
			end)
		end)
	end)

	--[[describe("SetTarget", function()
		it("should add target to line", function()
			local target = {}
			trackMaster:SetTarget(target)

			assert.spy(trackMaster.lines[1].AddTarget).was.called_with(trackMaster.lines[1], target)
		end)
	end)]]
end)