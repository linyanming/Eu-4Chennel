--[[=============================================================================
    Copyright 2016 Control4 Corporation. All Rights Reserved.
===============================================================================]]

-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.device_specific_commands = "2016.01.08"
end

--[[=============================================================================
    ExecuteCommand Code

    Define any functions for device specific commands (EX_CMD.<command>)
    received from ExecuteCommand that need to be handled by the driver.
===============================================================================]]
--function EX_CMD.NEW_COMMAND(tParams)
--	LogTrace("EX_CMD.NEW_COMMAND")
--	LogTrace(tParams)
--end

function EX_CMD.REQLEVEL(tParams)
    LogTrace("EX_CMD.REQLEVEL")
    LogTrace(tParams)
    local channel = tParams["CHANNEL"]
    gRelayProxy:ReqChannelLevel(channel)
end

function EX_CMD.SETLEVEL(tParams)
    LogTrace("EX_CMD.SETLEVEL")
    LogTrace(tParams)
    local channel = tParams["CHANNEL"]
    local level = tParams["LEVEL"]
    gRelayProxy:SetChannelLevel(channel,level)
end

function EX_CMD.DEVFLASH(tParams)
    LogTrace("EX_CMD.DEVFLASH")
    LogTrace(tParams)
    local times = tParams["TIMES"]
    gRelayProxy:DeviceFlash(times)
end

function EX_CMD.RECVMSG(tParams)
    LogTrace("EX_CMD.RECVMSG")
	LogTrace(tParams)
	local msg = tParams["MESSAGE"]
	if(msg ~= nil and msg ~= "") then
	   local tmp_msg = tohex(msg)
	   gRelayProxy:HandleMessage(tmp_msg,#tmp_msg)
	end
end