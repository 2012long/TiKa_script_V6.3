local game = game
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local FileSystem = game:GetService("FileSystem")

local GITHUB_REPO = "2012long/TiKa_script_V3"
local GITHUB_BRANCH = "main"

local SCRIPT_URL_MAP = {
    [6839171747] = string.format(  -- doors
        "https://raw.githubusercontent.com/%s/%s/doors(1).lua",
        GITHUB_REPO,
        GITHUB_BRANCH
    ),
    [3623096087] = string.format(  -- 力量传奇
        "https://raw.githubusercontent.com/%s/%s/%E5%8A%9B%E9%87%8F%EF%BC%881%EF%BC%89.lua",
        GITHUB_REPO,
        GITHUB_BRANCH
    ),
    [7239319209] = string.format(  -- Ohio
        "https://raw.githubusercontent.com/%s/%s/%E4%BF%84%E4%BA%A5%E4%BF%84%E5%B7%9E(1).lua",
        GITHUB_REPO,
        GITHUB_BRANCH
    ),
}

local function loadExternalScript(placeId)
    local scriptUrl = SCRIPT_URL_MAP[placeId] or string.format(
        "https://raw.githubusercontent.com/%s/%s/%E9%80%9A%E7%94%A8.lua",
        GITHUB_REPO,
        GITHUB_BRANCH
    )
    return game:HttpGet(scriptUrl, true)  
end

local function main()
    local placeId = game.PlaceId
    _G.YIJIAOBEN = "YIJIAOBEN"  

    local externalScript = loadExternalScript(placeId)
    if externalScript then
        local subScriptEnv = {
            game = game,
            print = print,
            Players = Players,
            UserInputService = game:GetService("UserInputService"),
            loadstring = loadstring,
            HttpService = HttpService,
            FileSystem = FileSystem,  
        }
        local chunk, err = load(externalScript, "ExternalScript_"..placeId, "t", subScriptEnv)
        if chunk then
            chunk()
        else
            warn(("加载子脚本失败（PlaceId: %s）："):format(placeId), err)
        end
    else
        warn("未找到对应 PlaceId 的子脚本，PlaceId：", placeId)
    end
end

main()