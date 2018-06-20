--[[=============================================================================
    Lua Action Code

    Copyright 2016 Control4 Corporation. All Rights Reserved.
===============================================================================]]

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.actions = "2016.01.08"
end

-- TODO: Create a function for each action defined in the driver

function LUA_ACTION.TemplateVersion()
	TemplateVersion()
end



function LUA_ACTION.Sync()
     print("sync device")
     local devid = C4:GetDeviceID()
	local dest_id = C4:GetBoundProviderDevice(devid,1) 
	print("Id is " .. dest_id)
	C4:SendToDevice(dest_id,"SYNCDEV",{DEVICE_ID = devid})
end

function LUA_ACTION.SetBoxID(tPramas)
	local boxid = tPramas["BOXID"]
	local cmd = string.pack("bbbb",gRelayProxy._SyncByte,gRelayProxy._DeviceCode,gRelayProxy._BoxID,0xe4)
	cmd = cmd .. gRelayProxy._Guid .. string.pack("bbbb",boxid,0x00,0x00,0x00)
	hexdump(cmd)
	gRelayProxy:SendCommandToDeivce(cmd)
end