--[[=============================================================================
    Initialization Functions

    Copyright 2017 Control4 Corporation. All Rights Reserved.
===============================================================================]]
require "relay.relay_proxy_class"
require "relay.relay_proxy_commands"
require "relay.relay_proxy_notifies"


DEVICE_ADDR = {}
-- This macro is utilized to identify the version string of the driver template version used.
if (TEMPLATE_VERSION ~= nil) then
	TEMPLATE_VERSION.proxy_init = "2018.06.05"
end

function ON_DRIVER_EARLY_INIT.proxy_init()
	-- declare and initialize global variables
end

function ON_DRIVER_INIT.proxy_init()

	gRelayProxy = RelayProxy:new(DEFAULT_PROXY_BINDINGID)
end

function ON_DRIVER_LATEINIT.proxy_init()
    --StartTimer(gRelayProxy._CmdTimer)
	
end


