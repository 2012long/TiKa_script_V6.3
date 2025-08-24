local game = game
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local FileSystem = game:GetService("FileSystem")

local GITHUB_REPO = "2012long/TiKa_script_V6.3"  
local GITHUB_BRANCH = "main"   

local BOOTSTRAPPER_URL = string.format(
    "https://raw.githubusercontent.com/%s/%s/Bootstrapper.lua",
    GITHUB_REPO,
    GITHUB_BRANCH
)

local TEMP_BOOTSTRAPPER_PATH = FileSystem.TemporaryDirectory .. "Bootstrapper.lua"

local function downloadAndSaveScript(url, savePath)
    local success, content = pcall(function()
        return HttpService:GetAsync(url, true)  
    end)
    if not success then
        warn("下载脚本失败（网络错误）：", content)
        return false
    end

    local success, err = pcall(FileSystem.WriteFile, FileSystem, savePath, content)
    if not success then
        warn(("保存文件失败（%s）："):format(savePath), err)
        return false
    end
    return true
end

local function executeScript(content, scriptName)
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

    local downloadSuccess = downloadAndSaveScript(BOOTSTRAPPER_URL, TEMP_BOOTSTRAPPER_PATH)
    if not downloadSuccess then
        warn("Bootstrapper.lua 下载失败，终止流程")
        return
    end

    local success, content = pcall(FileSystem.ReadFile, FileSystem, TEMP_BOOTSTRAPPER_PATH)
    if not success then
        warn(("读取 Bootstrapper.lua 失败："):format(content))
        return
    end

    local executeSuccess = executeScript(content, "Bootstrapper.lua")
    if not executeSuccess then
        warn("Bootstrapper.lua 执行失败，终止流程")
    end
end

main()