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

	describe("RegisterTracker", function()
		local Tracker = _G['TrackMasterLibs']['Tracker']

		it("should return a new tracker", function()
			local tracker = trackMaster:RegisterTracker()
			assert.is.not_nil(tracker)
			assert.are.same(Tracker, getmetatable(tracker).__index)
		end)
	end)

	-- describe("SetTarget", function()
	-- 	it("should add tracker if one does not exist", function()
	-- 		local target = {}
	-- 		function target:GetName() return "Name" end

	-- 		trackMaster:SetTarget(target, -1, 1)

	-- 		assert.is.same(1, # trackMaster.lines[1].trackers)
	-- 	end)
	-- end)

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

		describe("Quest Arrow", function()
			before_each(function()
				trackMaster:AddHookQuestArrow()
			end)

			after_each(function()
				trackMaster:RemoveHookQuestArrow()
			end)

			it("should add position of first quest area", function()
				--local quest = 
				local w = {
					GetData = function(self)
						return {
							GetData = function(self) end

							
						}
					end
				}
				--trackMaster:QuestHintArrow
			end)
		end)
	end)

	describe("OnSave", function()
		it("should add savedata from trackerList", function()
			trackMaster.trackerList = {
				Target = { Save = function() return "TargetData" end },
				Focus = { Save = function() return "FocusData" end }
			}
			local saveData = trackMaster:OnSave(GameLib.CodeEnumAddonSaveLevel.Character)

			assert.is.same("TargetData", saveData.trackerList.Target)
			assert.is.same("FocusData", saveData.trackerList.Focus)
		end)
	end)

	describe("OnRestoreTrackerList", function()
		it("should call load with correct savedata", function()
			local data = {
				Target = "TargetData",
				Focus = "FocusData"
			}

			trackMaster.trackerList = {
				Target = _G['TrackMasterLibs']['Tracker'].new(),
				Focus = _G['TrackMasterLibs']['Tracker'].new()
			}
			stub(trackMaster.trackerList.Target, "Load")
			stub(trackMaster.trackerList.Focus, "Load")

			trackMaster:OnRestoreTrackerList(data)

			assert.stub(trackMaster.trackerList.Target.Load).was.called_with(trackMaster.trackerList.Target, "TargetData")
			assert.stub(trackMaster.trackerList.Focus.Load).was.called_with(trackMaster.trackerList.Focus, "FocusData")
		end)
	end)
end)