local StoryboardConverter = require(workspace.StoryboardConverter)

local s = os.clock()
local data = StoryboardConverter(workspace.Storyboards.Test)
print("Load completed, took", os.clock()-s)

