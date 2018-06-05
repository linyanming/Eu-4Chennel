--[[=============================================================================
    relay Proxy Class

    Copyright 2018 Hiwise Corporation. All Rights Reserved.
===============================================================================]]

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.relay_proxy_class = "2018.06.05"
end

RelayProxy = inheritsFrom(nil)

function RelayProxy:construct(bindingID)
     LogTrace("RelayProxy:construct")
	-- member variables
	self._BindingID = bindingID

	self:Initialize()

end

function RelayProxy:Initialize()
     LogTrace("RelayProxy:Initialize")
	-- create and initialize member variables
	self._PackLen = 8
     self._DeviceCode = 0x23
	self._BoxID = 0xff
	self._SyncByte = 0xfb
end

function RelayProxy:SendCommandToDeivce(command)
    LogTrace("RelayProxy:SendCommandToDeivce")

	local cmd = command
	hexdump(cmd)
	local crccode = CRCCalc(cmd,#cmd)
	cmd = cmd .. string.pack("b",crccode)
	hexdump(cmd)
	local message = ""
	for i = 1,#cmd do
	    message = message .. string.format("%02x",string.byte(cmd,i))
	    print("message:" .. message)
	end
	local devid = C4:GetDeviceID()
	local id = C4:GetBoundProviderDevice(devid,BUS_BINDING_ID)
	print("Id is " .. id)
	C4:SendToDevice(id,"SENDCMD",{COMMAND = message})
end

function RelayProxy:ReqChannelLevel(channel)
     LogTrace("RelayProxy:ReqChannelLevel")
	local cmd = string.pack("bbbbbbb",self._SyncByte,self._DeviceCode,self._BoxID,0xfe,channel - 1,0x00,0x00)
	self:SendCommandToDeivce(cmd)
end

function RelayProxy:SetChannelLevel(channel,level)
     LogTrace("RelayProxy:ReqChannelLevel")
	local cmd = string.pack("bbbbbbb",self._SyncByte,self._DeviceCode,self._BoxID,0xf0,channel - 1,level,0x00)
	self:SendCommandToDeivce(cmd)
end

function RelayProxy:DeviceFlash(times)
     LogTrace("RelayProxy:ReqChannelLevel")
	local cmd = string.pack("bbbbbbb",self._SyncByte,self._DeviceCode,self._BoxID,0xe2,times,0x00,0x00)
	self:SendCommandToDeivce(cmd)
end

function RelayProxy:HandleMessage(message,msglen)
    LogTrace("RelayProxy:HandleMessage")
    hexdump(message)
    if(#message ~= self._PackLen) then
        return nil
    else
        local msg_data = {}
	   local crccode = CRCCalc(message,msglen-1)
        for i = 1,#message do
		  msg_data[i] = string.byte(message,i)
		  print(i .. ":" .. msg_data[i])
        end
        if(msg_data[1] == 0xfb and crccode == msg_data[msglen]) then
		  LogTrace("data success")
		  local channel = msg_data[5] + 1
		  local level = msg_data[6]
		  local devid = C4:GetDeviceID()     
		  local devs = C4:GetBoundConsumerDevices(devid , channel+1)   
		  if (devs ~= nil) then
			 for id,name in pairs(devs) do
				C4:SendToDevice(id,"LIGHTREPORT",{LEVEL = level})
			 end
		  end
	   else
		  LogTrace("DATA ERROR")
        end
    end
end





