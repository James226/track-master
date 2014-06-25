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

describe("API Tests", function()
	setup(function()
		self.mock = LuaMock.new()
		local loadForm = Apollo.LoadForm
		self.loadedForms = {}
		self.mock:Mock(Apollo, "LoadForm", function(strFile, strForm, wndParent, tLuaEventHandler)
			local form = loadForm(strFile, strForm, wndParent, tLuaEventHandler)
			table.insert(self.loadedForms, form)
			return form
		end)
		self.mock:Mock(Apollo, "RegisterAddon", function (addon, bool, string, dependencies)
			addon:OnLoad()
		end)
		self.trackMaster = Apollo.GetAddon("TrackMaster").new()
		self.trackMaster:Init()
	end)

	teardown(function()
		self.mock:RestoreAll()

		for _, form in pairs(self.loadedForms) do
			form:Destroy()
		end
	end)

	it("AddToConfigMenu should not return nil for valid params", function()
		local result = self.trackMaster:AddToConfigMenu(self.trackMaster.Type.Hook, "Test", {
	    	CanFire = true,
	    	OnFire = function() end
	    	})
		assert.are_not_same(result, nil)
	end)

	it("AddToConfigMenu should return false if no menu type passed", function()
	    assert.same(false, self.trackMaster:AddToConfigMenu(nil, "Test", {
	    	CanFire = true,
	    	OnFire = function() end
	    	}))
	end)

	it("AddToConfigMenu Should Return False If No Name Passed", function()
	    assert.same(false, self.trackMaster:AddToConfigMenu(self.trackMaster.Type.Hook, "", {
	    	CanFire = true,
	    	OnFire = function() end
	    	}))
	end)

	it("testAddToConfigMenuShouldReturnFalseIfNoConfig", function()
		assert.same(false, self.trackMaster:AddToConfigMenu(self.trackMaster.Type.Hook, "Test", {}))
	end)

	it("testAddConfigMenuShouldReturnFalseIfCanFireButNoCallback", function()
		assert.same(false, self.trackMaster:AddToConfigMenu(self.trackMaster.Type.Hook, "Test", {
			CanFire = true,
	    	CanEnable = false,
	    	OnFire = nil
		}))
	end)

	it("testAddToConfigMenuShouldReturnTrueForCanEnableOnly", function()
		assert.are_not_same(nil, self.trackMaster:AddToConfigMenu(self.trackMaster.Type.Hook, "Test", {
			CanFire = false,
	    	CanEnable = true,
	    	OnEnableChanged = function() end
		}))
	end)
end)