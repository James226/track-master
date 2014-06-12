--local LuaUnit = require('luaunit')
local LuaMock = require('LuaMock')

test_APITests = {}

function test_APITests:setUp()
	self.mock = LuaMock.new()
	self:tearDown()  
	self.mock:Mock(Apollo, "LoadForm", function(strFile, strForm, wndParent, tLuaEventHandler)
		if strForm == "Subwindows.ConfigButton" then
			local form = setmetatable({}, Button)
			return form
		else
			local form = setmetatable({}, Window)
			return form
		end
	end)
	self.trackMaster = Apollo.GetAddon("TrackMaster"):new()
	self.trackMaster:Init()
end

function test_APITests:tearDown()
	self.mock:RestoreAll()
end

function test_APITests:testAddToConfigMenuShouldReturnTrueForValidParams()
	assertEquals(self.trackMaster:AddToConfigMenu(self.trackMaster.Type.Hook, "Test", {
    	CanFire = true,
    	OnFire = function() end
    	}), true)
end

function test_APITests:testAddToConfigMenuShouldReturnFalseIfNoMenuTypePassed()
    assertEquals(self.trackMaster:AddToConfigMenu(nil, "Test", {
    	CanFire = true,
    	OnFire = function() end
    	}), false)
end

function test_APITests:testAddToConfigMenuShouldReturnFalseIfNoNamePassed()
	assertEquals(self.trackMaster:AddToConfigMenu(self.trackMaster.Type.Hook, nil, {
    	CanFire = true,
    	OnFire = function() end
    	}), false)
end
 
function test_APITests:testAddToConfigMenuShouldReturnFalseIfEmptyNamePassed()
	assertEquals(self.trackMaster:AddToConfigMenu(self.trackMaster.Type.Hook, "", {
    	CanFire = true,
    	OnFire = function() end
    	}), false)
end

function test_APITests:testAddToConfigMenuShouldReturnFalseIfNoConfig()
	assertEquals(self.trackMaster:AddToConfigMenu(self.trackMaster.Type.Hook, "Test", {}), false)
end

function test_APITests:testAddConfigMenuShouldReturnFalseIfCanFireButNoCallback()
	assertEquals(self.trackMaster:AddToConfigMenu(self.trackMaster.Type.Hook, "Test", {
		CanFire = true,
    	CanEnable = false,
    	OnFire = nil
	}), false)
end

function test_APITests:testAddConfigMenuShouldReturnFalseIfCanEnableButNoCallback()
	assertEquals(self.trackMaster:AddToConfigMenu(self.trackMaster.Type.Hook, "Test", {
		CanFire = false,
    	CanEnable = true,
    	OnEnableChanged = nil
	}), false)
end

function test_APITests:testAddToConfigMenuShouldSetContentTypeToPushButtonForCanFireOnly()
	local contentType = nil
	self.mock:Mock(Button, "SetContentType", function(self, type)
		contentType = type
	end)

	self.trackMaster:AddToConfigMenu(self.trackMaster.Type.Hook, "Test", {
    	CanFire = true,
    	OnFire = function() end
	})

	assertEquals(contentType, "PushButton")
end

function test_APITests:testAddToConfigMenuShouldReturnTrueForCanEnableOnly()
	assertEquals(self.trackMaster:AddToConfigMenu(self.trackMaster.Type.Hook, "Test", {
		CanFire = false,
    	CanEnable = true,
    	OnEnableChanged = function() end
	}), true)
end


function test_APITests:testAddToConfigMenuShouldSetContentTypeToCheckForCanEnableOnly()
	local contentType = nil
	self.mock:Mock(Button, "SetContentType", function(self, type)
		contentType = type
	end)

	self.trackMaster:AddToConfigMenu(self.trackMaster.Type.Hook, "Test", {
		CanFire = false,
    	CanEnable = true,
    	OnEnableChanged = function() end
	})

	assertEquals(contentType, "Check")
end

function test_APITests:testShouldStoreConfigurationIfAddToConfigMenuIsSuccessful()
	assertEquals(self.trackMaster:AddToConfigMenu(self.trackMaster.Type.Hook, "Test", {
		CanFire = false,
    	CanEnable = true,
    	OnEnableChanged = function() end
	}), true)

	assert(self.trackMaster.Configurations["Test"] ~= nil)
end

Apollo.GetPackage("WildstarUT-1.0"):RegisterTestObject(test_APITests)