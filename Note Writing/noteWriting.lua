local noteWriting = {}

--[[
Takes a pid, and the cmd inputted into chat.
Returns either a structured item, or nil if the player lacks paper.
]]--
function noteWriting.CreateNote(pid,cmd)
	--Make sure there is text after /write
	if cmd[2] == nil then
		Players[pid]:Message("No text given\n")
		return nil
	end
	
	--Checks if players have the required Item(s)
	if inventoryHelper.containsItem(Players[pid].data.inventory,"sc_paper plain") then
		inventoryHelper.removeItem(Players[pid].data.inventory,"sc_paper plain",1)
		Players[pid]:Message("You made a note\n")
	else
		Players[pid]:Message("You lack the materials to make a note\n")
		return nil
	end
	
	--Declare variables here
	local noteId
	local noteName = Players[pid].name .. "'s Note"
	local noteModel = "m\\Text_Note_02.nif"
	local noteIcon = "m\\Tx_note_02.tga"
	local noteWeight = 0.20
	local noteValue = 1
	local noteText = cmd[2]
	local i = 3
	local recordTable = {}
	
	--Put the text back together
	while cmd[i] ~= nil do 
		noteText = noteText .. " " .. cmd[i]
		i = i + 1
	end
	noteText = "<DIV ALIGN=\"CENTER\">" .. noteText .. "<p>"
	recordTable["weight"] = noteWeight
	recordTable["icon"] = noteIcon
	recordTable["skillId"] = "-1"
	recordTable["model"] = noteModel
	recordTable["text"] = noteText
	recordTable["value"] = noteValue
	recordTable["scrollState"] = true
	recordTable["name"] = noteName

	noteId = noteWriting.nuCreateBookRecord(pid, recordTable)
	
	local structuredItem = { refId = noteId, count = 1, charge = -1}
	return structuredItem
end
--[[
Based on Create and store record functions from commandhandler in https://github.com/TES3MP/CoreScripts 
]]--
function noteWriting.nuCreateBookRecord(pid, recordTable)
	local recordStore = RecordStores["book"]
	local id = recordStore:GenerateRecordId()
	local savedTable = recordTable
	
	recordStore.data.generatedRecords[id] = savedTable
	for _, player in pairs(Players) do
        if not tableHelper.containsValue(Players[pid].generatedRecordsReceived, id) then
            table.insert(player.generatedRecordsReceived, id)
        end
    end
	Players[pid]:AddLinkToRecord("book", id)
	recordStore:Save()
    tes3mp.ClearRecords()
    tes3mp.SetRecordType(enumerations.recordType[string.upper("book")])
	packetBuilder.AddBookRecord(id, savedTable)
	tes3mp.SendRecordDynamic(pid, true, false)
	
	return id
end

return noteWriting
