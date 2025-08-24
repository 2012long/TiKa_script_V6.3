local game = game
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local FileSystem = game:GetService("FileSystem")

local GITHUB_REPO = "2012long/TiKa_script_V6.3"
local GITHUB_BRANCH = "main"

local TEMP_DIR = FileSystem.TemporaryDirectory .. "ProtectedSystem/"
local LOADER_PATH = TEMP_DIR .. "Loader.lua"
local PROTECTED_MAIN_PATH = TEMP_DIR .. "TiKaV6.3.lua"

local function createTempDir()
    local success, err = pcall(FileSystem.CreateDirectory, FileSystem, TEMP_DIR)
    if not success then
        warn("创建临时目录失败：", err)
        return false
    end
    return true
end

local function saveFile(path, content)
    local success, err = pcall(FileSystem.WriteFile, FileSystem, path, content)
    if not success then
        warn(("保存文件失败（%s）："):format(path), err)
        return false
    end
    return true
end

local function deleteTempFiles()
    -- 递归删除临时目录下的所有文件和子目录
    local success, err = pcall(function()
        -- 删除所有文件
        for _, fileName in ipairs(FileSystem.GetFileNames(TEMP_DIR .. "*")) do
            local filePath = TEMP_DIR .. fileName
            FileSystem.DeleteFile(filePath)
            print(("已删除临时文件：%s"):format(filePath))
        end
        FileSystem.DeleteDirectory(TEMP_DIR)
    end)
    if not success then
        warn("清理临时文件失败：", err)
    end
end

local function downloadAndSaveScript(url, savePath)
    local success, content = pcall(function()
        return HttpService:GetAsync(url, true)
    end)
    if not success then
        warn("下载脚本失败（网络错误）：", content)
        return false
    end
    return saveFile(savePath, content)
end

local function executeScriptFromFile(path, scriptName)
    local success, content = pcall(FileSystem.ReadFile, FileSystem, path)
    if not success then
        warn(("读取脚本失败（%s）："):format(path), content)
        return false
    end

    local env = {
        game = game,
        RunService = RunService,
        Players = Players,
        HttpService = HttpService,
        FileSystem = FileSystem,
        loadstring = loadstring,
        print = print,
        UserInputService = game:GetService("UserInputService"),
    }
    local chunk, err = load(content, scriptName, "t", env)
    if not chunk then
        warn(("执行 %s 失败（语法错误）："):format(scriptName), err)
        return false
    end
    chunk()
    return true
end

local function main()
    if not RunService:IsClient() then
        return
    end

    if not createTempDir() then
        warn("临时目录创建失败，终止流程")
        return
    end

    local loaderUrl = string.format(
        "https://raw.githubusercontent.com/%s/%s/Loader.lua",
        GITHUB_REPO,
        GITHUB_BRANCH
    )
    if not downloadAndSaveScript(loaderUrl, LOADER_PATH) then
        warn("Loader.lua 下载失败，终止流程")
        deleteTempFiles()  
        return
    end

    if not executeScriptFromFile(LOADER_PATH, "Loader.lua") then
        warn("Loader.lua 执行失败，终止流程")
        deleteTempFiles()
        return
    end

    Players.PlayerRemoving:Connect(function(player)
        print(("玩家 %s 退出，清理临时文件..."):format(player.Name))
        deleteTempFiles()
    end)
end

main()