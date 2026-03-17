-- by: CatchMoon
-- 文件夹管理:
--  1. 根据路径创建文件夹

local FolderUtil = {}

-- 根据路径创建文件夹
-- path: 路径格式为用.连接 
-- parent: 在该instance下面创建文件夹
function FolderUtil.CreateFoldersByPath(path: string, parent: Instance?): Folder
	if parent == nil then parent = workspace end
	
	local newParent = parent
	local folderNameList = path:split(".")
	
	for _, folderName in ipairs(folderNameList) do
		local folder = newParent:FindFirstChild(folderName)
		if folder == nil then
			folder = Instance.new("Folder", newParent)
			folder.Name = folderName
		end
		newParent = folder
	end
	
	return newParent
end

return FolderUtil