local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "shitass comp script",
    SubTitle = "🙏🙏🙏",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local MainTab = Window:AddTab({ Title = "Main", Icon = "list" })

local tweenService = game:GetService("TweenService")
local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")

local player = players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local remote = replicatedStorage.Shared.Framework.Network.Remote.Event

local eggPositions = {
    ["Common Egg"] = Vector3.new(-83.86031341552734, 10.116671562194824, 1.5749061107635498),
    ["Spotted Egg"] = Vector3.new(-93.96259307861328, 10.116673469543457, 7.4115400314331055),
    ["Iceshard Egg"] = Vector3.new(-117.0664291381836, 10.116671562194824, 7.745338916778564),
    ["Spikey Egg"] = Vector3.new(-124.588134765625, 10.116671562194824, 4.580596446990967),
    ["Magma Egg"] = Vector3.new(-133.02085876464844, 10.116593360900879, -1.5519139766693115),
    ["Crystal Egg"] = Vector3.new(-140.2029571533203, 10.116671562194824, -8.3678560256958),
    ["Lunar Egg"] = Vector3.new(-143.85606384277344, 10.116650581359863, -15.931164741516113),
    ["Void Egg"] = Vector3.new(-145.9164276123047, 10.116620063781738, -26.1324405670166),
    ["Hell Egg"] = Vector3.new(-145.17674255371094, 10.116671562194824, -36.78310775756836),
    ["Nightmare Egg"] = Vector3.new(-142.350341796875, 10.116673469543457, -45.15552520751953),
    ["Rainbow Egg"] = Vector3.new(-134.49424743652344, 10.116379737854004, -52.360511779785156),
}

local taskAutomationEnabled = false

local function tweenToPosition(position)
    local distance = (humanoidRootPart.Position - position).Magnitude
    local speed = 16
    local time = distance / speed
    local tweenInfo = TweenInfo.new(time, Enum.EasingStyle.Linear)
    local goal = {CFrame = CFrame.new(position)}
    local tween = tweenService:Create(humanoidRootPart, tweenInfo, goal)
    tween:Play()
    return tween
end

local function hatchEgg(eggName)
    local eggPosition = eggPositions[eggName]
    if eggPosition then
        local tween = tweenToPosition(eggPosition)
        tween.Completed:Wait()
        local maxAttempts = 50
        local threshold = 3
        local attempts = 0
        while (humanoidRootPart.Position - eggPosition).Magnitude > threshold and attempts < maxAttempts do
            task.wait(0.1)
            attempts += 1
        end
        if attempts < maxAttempts then
            task.wait(0.2)
            remote:FireServer("HatchEgg", eggName, 6)
        end
    end
end

local function rerollTask()
    remote:FireServer("CompetetiveReroll", 3)
end

local function extractEggName(fullText)
    local text = fullText:gsub("Hatch", "")
    text = text:gsub("^%s*%d+%s*", "")
    text = text:gsub("%s*Eggs?$", "")
    text = text:match("^%s*(.-)%s*$")
    return text
end

local function deepFindHatchLabel(frame)
    for _, child in ipairs(frame:GetChildren()) do
        if child:IsA("TextLabel") then
            if child.Text:lower():find("hatch") then
                return child
            end
        elseif child:IsA("Frame") then
            local found = deepFindHatchLabel(child)
            if found then
                return found
            end
        end
    end
end

local function completeTask(taskFrame)
    local hatchLabel = deepFindHatchLabel(taskFrame)
    if not hatchLabel then
        return false
    end
    local fullTitle = hatchLabel.Text
    if fullTitle:lower():find("mythic") then
        rerollTask()
        return true
    end
    local extractedEggName = extractEggName(fullTitle)
    for eggName, _ in pairs(eggPositions) do
        if extractedEggName:lower():find(eggName:lower():gsub(" egg", "")) then
            hatchEgg(eggName)
            return true
        end
    end
    return false
end

local function taskManager()
    while taskAutomationEnabled do
        local success = pcall(function()
            local tasksFolder = player.PlayerGui
                :WaitForChild("ScreenGui")
                :WaitForChild("Competitive")
                :WaitForChild("Frame")
                :WaitForChild("Content")
                :WaitForChild("Tasks")
            local taskHandled = false
            for _, taskFrame in ipairs(tasksFolder:GetChildren()) do
                if taskFrame:IsA("Frame") then
                    local handled = completeTask(taskFrame)
                    if handled then
                        taskHandled = true
                        break
                    end
                end
            end
            if not taskHandled then
                hatchEgg("Common Egg")
            end
        end)
        task.wait(1)
    end
end

local AutoTasksToggle = MainTab:AddToggle("AutoTasks", {
    Title = "Auto Complete Tasks",
    Default = false
})

AutoTasksToggle:OnChanged(function()
    taskAutomationEnabled = AutoTasksToggle.Value
    if taskAutomationEnabled then
        Fluent:Notify({
            Title = "auto task",
            Content = "you enabled the script!!",
            Duration = 5
        })
        task.spawn(taskManager)
    else
        Fluent:Notify({
            Title = "auto task",
            Content = "you disabled the script",
            Duration = 5
        })
    end
end)

Window:SelectTab(1)

Fluent:Notify({
    Title = "auto task",
    Content = "script worked yay",
    Duration = 5
})
