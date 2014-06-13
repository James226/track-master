--local LuaUnit = require('luaunit')
local LuaMock = {}
LuaMock.__index = LuaMock

local MockObject = {}
MockObject.__index = MockObject

local MockedFunction = {}
MockedFunction.__index = MockedFunction

function LuaMock.new()
	local self = setmetatable({}, LuaMock)
	self.mocked = {}
	return self
end

function LuaMock:Mock(obj, func, mockFunc)
	self:MockObject(obj):MockFunction(func)

	obj[func] = mockFunc
end

function LuaMock:MockObject(obj)
	if self.mocked[obj] == nil then
		self.mocked[obj] = MockObject.new(obj)
	end
	return self.mocked[obj]
end

function LuaMock:RestoreAll()
	for _, obj in pairs(self.mocked) do
		obj:RestoreAll()
	end
end

function MockObject.new(obj)
	local self = setmetatable({}, MockObject)
	self.obj = obj
	self.functions = {}
	return self
end

function MockObject:MockFunction(func)
	if self.functions[func] == nil then
		self.functions[func] = MockedFunction.new(self.obj, func)
	end
	return self.functions[func]
end

function MockObject:RestoreAll()
	for name, func in pairs(self.functions) do
		func:Restore()
	end
end

function MockedFunction.new(obj, func)
	local self = setmetatable({}, MockedFunction)
	self.obj = obj
	self.func = func
	self.mockedFunction = obj[func]
	return self
end

function MockedFunction:Restore()
	self.obj[self.func] = self.mockedFunction
end


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

Apollo.GetPackage("WildstarUT-1.0").tPackage:RegisterTestObject("test_APITests", test_APITests)