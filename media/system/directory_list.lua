-- list files and folders in a given directory


-- [dcunnin] There should be C++ support for this.

-- Windows
if os.getenv("OS") ~= nil then
	function get_dir_list(directory)
        assert(directory:sub(1, 1) == '/', 'Must begin with a /, got "%s"' % directory)
        directory = directory:sub(2)
	    local i, folders, popen = 0, {}, io.popen
		-- get folders
		for filename in popen('dir "'..directory..'" /b /ad'):lines() do
			i = i + 1
			folders[i] = filename
		end

		i = 0
		
		-- get files
		local files = {}

		for filename in popen('dir "'..directory..'"/b /a-d'):lines() do
			i = i + 1
			files[i] = filename
		end

	    return files, folders
	end

-- Linux
else
	function get_dir_list(directory)
        assert(directory:sub(1, 1) == '/', 'Must begin with a /, got "%s"' % directory)
        directory = directory:sub(2)
		local mtmpname = os.tmpname()
		os.execute("ls -p "..directory .. " >"..mtmpname)
		local fg = io.open(mtmpname,"r")
		local rv = fg:read("*all")
		fg:close()
		os.remove(mtmpname)

		local res = {}
		local from  = 1
		local delim_from, delim_to = string.find(rv, "\n", from  )
		while delim_from do
		        table.insert( res, string.sub(rv, from , delim_from-1 ))
		        from  = delim_to + 1
		        delim_from, delim_to = string.find( rv, "\n", from)
		end

		local files, folders = {}, {}
		
		for i = 1, #res do
			if res[i]:sub(-1) == "/" then
				folders[#folders+1] = res[i]:reverse():sub(2):reverse()
			else
				files[#files+1] = res[i]
			end
		end
		
		return files, folders
	end
end
