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
	self._BoxID = Properties["BoxID"]
	self._Guid = tohex(Properties["GUID"])
	self._SyncByte = 0xfb
	
     self._CmdTable = {}
	self._CmdPos = 1
	self._CmdSendPos = 1
	self._CmdTableMax = 100
	
     self._CmdTimer = CreateTimer("CMD_PROCESS", 50, "MILLISECONDS", CmdTimerCallback, true, nil)

end

function CmdTimerCallback()
    if(gRelayProxy._CmdTable[gRelayProxy._CmdSendPos] ~= nil and gRelayProxy._CmdTable[gRelayProxy._CmdSendPos] ~= "") then
        gRelayProxy:SendCommandToDeivce(gRelayProxy._CmdTable[gRelayProxy._CmdSendPos])
        gRelayProxy._CmdTable[gRelayProxy._CmdSendPos] = ""
        if(gRelayProxy._CmdSendPos == gRelayProxy._CmdTableMax) then
           gRelayProxy._CmdSendPos = 1
        else
           gRelayProxy._CmdSendPos = gRelayProxy._CmdSendPos + 1
        end
    else
        KillTimer(gRelayProxy._CmdTimer)
    end

end

function RelayProxy:AddToQueue(command)
    LogTrace("RelayProxy:AddToQueue")
    if(TimerStarted(self._CmdTimer)) then
	   self._CmdTable[self._CmdPos] = command
	   if(self._CmdPos == self._CmdTableMax) then
		  self._CmdPos = 1
	   else
		  self._CmdPos = self._CmdPos + 1
	   end
    else
	   self:SendCommandToDeivce(command)
	   StartTimer(self._CmdTimer)
    end
end

function RelayProxy:SendChannelId(bindid,channelid)
    LogTrace("RelayProxy:SendChannelId")
    local devid = C4:GetDeviceID()     
    local devs = C4:GetBoundConsumerDevices(devid , bindid)   
    if (devs ~= nil) then
	   for id,name in pairs(devs) do
		  C4:SendToDevice(id,"CHANNELID",{CHID = channelid})
		  print ("id " .. id .. " name " .. name)
	   end
    end
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
	end
	local devid = C4:GetDeviceID()
	local id = C4:GetBoundProviderDevice(devid,BUS_BINDING_ID)
	print("Id is " .. id)
	C4:SendToDevice(id,"SENDCMD",{COMMAND = message})
end

function RelayProxy:ReqChannelLevel(channel)
     LogTrace("RelayProxy:ReqChannelLevel")
	local cmd = string.pack("bbbbbbb",self._SyncByte,self._DeviceCode,self._BoxID,0xfe,channel - 1,0x00,0x00)
	self:AddToQueue(cmd)
end

function RelayProxy:SetChannelLevel(channel,level)
     LogTrace("RelayProxy:ReqChannelLevel")
	local cmd = string.pack("bbbbbbb",self._SyncByte,self._DeviceCode,self._BoxID,0xf0,channel - 1,level,0x00)
	self:AddToQueue(cmd)
end

function RelayProxy:DeviceFlash(times)
     LogTrace("RelayProxy:ReqChannelLevel")
	local cmd = string.pack("bbbbbbb",self._SyncByte,self._DeviceCode,self._BoxID,0xe2,times,0x00,0x00)
	self:AddToQueue(cmd)
end

function RelayProxy:HandleMessage(message,msglen)
    LogTrace("RelayProxy:HandleMessage")
    hexdump(message)
    if(#message ~= self._PackLen and #message ~= 13) then
        return nil
    else
        local msg_data = {}
	   local crccode = CRCCalc(message,msglen-1)
        for i = 1,#message do
		  msg_data[i] = string.byte(message,i)
        end
        if(msg_data[1] == self._SyncByte and msg_data[2] == self._DeviceCode and msg_data[3] == self._BoxID and crccode == msg_data[msglen]) then
		  LogTrace("data success")
		  local channel = msg_data[5] + 1
		  local level = msg_data[6]
		  if(msg_data[4] == 0xfd) then
			 local devid = C4:GetDeviceID()     
			 local devs = C4:GetBoundConsumerDevices(devid , channel+1)   
			 if (devs ~= nil) then
				for id,name in pairs(devs) do
				    C4:SendToDevice(id,"LIGHTREPORT",{LEVEL = level})
				end
			 end
		  end
	   elseif(msg_data[1] == self._SyncByte and msg_data[2] == self._DeviceCode and msg_data[4] == 0xe5 and crccode == msg_data[msglen]) then
		  local guid = string.pack("bbbb",msg_data[5],msg_data[6],msg_data[7],msg_data[8])
		  if(guid == self._Guid) then
			 local boxid = msg_data[3] 
			 UpdateProperty("BoxID",boxid)
			 self._BoxID = boxid
		  end			 
	   else
		  LogTrace("DATA ERROR")
        end
    end
end





