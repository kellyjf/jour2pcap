-- skew.lua
-- A post-dissector to compute the difference between system and RTP time
-- for RTP streams separately by SSRC
--
-- Author: John Kelly
-- Date:   2/26/2014
--

-- Helper function for debugging
function print_table(x)
	for k,v in pairs(x) do
		print(k,v)
	end
end

do
	-- Create the 'new protocol' dissector
        local sysng = Proto("sysng", "SysLog Data");
	local deja;

	--print_table(sysng)

	-- Create the new fields, and associate to the protocol
        local F_service = ProtoField.string("sysng.service", "Service")
        local F_sid = ProtoField.string("sysng.ident", "Ident")
        local F_len = ProtoField.string("sysng.len", "Length")
        local F_body = ProtoField.string("sysng.line", "Log Message")
        sysng.fields = {F_service, F_sid, F_len, F_body}

	-- Create acccessors for the fields we need to reference
        local f_ethtype = Field.new("eth.type")
	--print_table(f_ethtype);

	-- Define the dissector function
        function sysng.dissector(tvbuffer, pinfo, treeitem)

		-- Store the top of the analysis tree
		local subtreeitem = treeitem:add(sysng, tvbuffer)

		--print(ssrc_val,f_frame_time(),f_rtp_time(),skew_val,start_offset[ssrc_val],(skew_val - start_offset[ssrc_val]))

		--print("String",linelen,(tvbuffer(8,linelen):string()))


		-- Add the values to the analysis tree
		--subtreeitem:add(tvbuffer(0,2), "Source")
		--	   :set_text("Source: " .. tvbuffer(0,2))
		--if ( deja~=1 ) then print_table(pinfo.cols); deja=1; end
		local linelen = tvbuffer(40,2):le_uint();
		pinfo.cols.protocol = "sysng"
		pinfo.cols.net_dst = "SysLogs"
		pinfo.cols.net_src =  tvbuffer(42,linelen):string();
		pinfo.cols.info = tvbuffer(42,linelen):string() 

		subtreeitem:add(F_service, tvbuffer(0,20), (tvbuffer(0,20):string()))
			   :set_text("Service: " .. tvbuffer(0,20):string())
		subtreeitem:add(F_sid, tvbuffer(20,20), (tvbuffer(20,20):string()))
			   :set_text("Ident: " .. tvbuffer(20,20):string())
		subtreeitem:add(F_len, tvbuffer(40,2), (tvbuffer(40,2):le_uint()))
			   :set_text("Length: " .. tvbuffer(40,2):le_uint())
		subtreeitem:add(F_body, tvbuffer(42,linelen), (tvbuffer(42,linelen):string()))
			   :set_text("Body: " .. tvbuffer(42,linelen):string())


        end
	local dt = DissectorTable.get("ethertype");
	dt:add(0x7dff, sysng);
--	register_postdissector(sysng)
end
