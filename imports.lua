-- Import the ESX and ExM objects then patch ExM with metatables
-- The metatables are not shared across exports sadly, we have to do that ourselves
if exports and exports["extendedmode"] then
	-- Get the base ESX shared object and the ExM shared object acts as overrides for the ExM object we are about to create
	local ESX = exports["extendedmode"]:getSharedObject()
	local ExM_overrides = exports["extendedmode"]:getExtendedModeObject()

	do -- Keep in a seperate block to not override anything in the script
		local function addMetatables(thisTable)
			-- Create a table and set its metatable to the table we were passed
			local thisObject = setmetatable({}, {
				__index = thisTable
			})

			-- Check if the table we were passed has any more tables within it 
			for key, value in pairs(thisTable) do
				if type(value) == "table" and not value.__cfx_functionReference then
					-- if so, call this function again but passing it the table we found
					-- then set the return of that function call to the same key in our new object
					thisObject[key] = addMetatables(value)
				end
			end

			-- Finally, return our object to whatever called it
			return thisObject
		end

		-- Start the process of creating the ExM object through traversing the ESX namespaces
		ExM = addMetatables(ESX)
	end

	do
		local function copyTableToTable(table1, table2)
			-- Search through table1
			for key, value in pairs(table1) do
				if type(value) == "table" and not value.__cfx_functionReference then
					-- If this value is a table, make sure table2 has a corresponding table at this key then call this function again on the two tables
					if not rawget(table2, key) then table2[key] = {} end
					copyTableToTable(value, table2[key])
				else
					-- If this value is anything else, copy it to table2
					table2[key] = value
				end
			end
		end

		-- Start overriding our own ExM object with all the global ExM object stuff...
		copyTableToTable(ExM_overrides, ExM)
	end

	-- By this point, everything should be ready and ExM should be setup with the appropriate metatables
end