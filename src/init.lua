--!strict

local packages = script.Parent.roblox_packages;
local DialogueMakerTypes = require(packages.dialogue_maker_types);

type Dialogue = DialogueMakerTypes.Dialogue;
type Conversation = DialogueMakerTypes.Conversation;
type ConversationSettings = DialogueMakerTypes.ConversationSettings;
type OptionalConversationSettings = DialogueMakerTypes.OptionalConversationSettings;

local Conversation = {
  defaultSettings = {
    speaker = {
      name = nil;
    };
    theme = {
      moduleScript = nil;
    };
    promptRegion = {
      basePart = nil; 
    };
    clickDetector = { 
      shouldAutoCreate = false; 
      shouldDisappearDuringConversation = true; 
      instance = nil;
    };
    proximityPrompt = { 
      shouldAutoCreate = true; 
      instance = nil; 
    };
    speechBubble = {
      shouldAutoCreate = false; 
      button = nil;
      billboardGUI = nil;
      adornee = nil;
    };
  } :: ConversationSettings;
};

function Conversation.new(dialogueServerSettings: OptionalConversationSettings?, moduleScript: ModuleScript): Conversation

  local settingsChangedEvent = Instance.new("BindableEvent");
  local settings: ConversationSettings = {
    speaker = {
      name = if dialogueServerSettings and dialogueServerSettings.speaker then dialogueServerSettings.speaker.name else Conversation.defaultSettings.speaker.name;
    };
    theme = {
      moduleScript = if dialogueServerSettings and dialogueServerSettings.theme then dialogueServerSettings.theme.moduleScript else Conversation.defaultSettings.theme.moduleScript;
    };
    promptRegion = {
      basePart = if dialogueServerSettings and dialogueServerSettings.promptRegion then dialogueServerSettings.promptRegion.basePart else Conversation.defaultSettings.promptRegion.basePart; 
    };
    clickDetector = { 
      shouldAutoCreate = if dialogueServerSettings and dialogueServerSettings.clickDetector and dialogueServerSettings.clickDetector.shouldAutoCreate ~= nil then dialogueServerSettings.clickDetector.shouldAutoCreate else Conversation.defaultSettings.clickDetector.shouldAutoCreate; 
      shouldDisappearDuringConversation = if dialogueServerSettings and dialogueServerSettings.clickDetector and dialogueServerSettings.clickDetector.shouldDisappearDuringConversation ~= nil then dialogueServerSettings.clickDetector.shouldDisappearDuringConversation else Conversation.defaultSettings.clickDetector.shouldDisappearDuringConversation; 
      instance = if dialogueServerSettings and dialogueServerSettings.clickDetector then dialogueServerSettings.clickDetector.instance else Conversation.defaultSettings.clickDetector.instance;
    };
    proximityPrompt = { 
      shouldAutoCreate = if dialogueServerSettings and dialogueServerSettings.proximityPrompt and dialogueServerSettings.proximityPrompt.shouldAutoCreate ~= nil then dialogueServerSettings.proximityPrompt.shouldAutoCreate else Conversation.defaultSettings.proximityPrompt.shouldAutoCreate; 
      instance = if dialogueServerSettings and dialogueServerSettings.proximityPrompt then dialogueServerSettings.proximityPrompt.instance else Conversation.defaultSettings.proximityPrompt.instance; 
    };
    speechBubble = {
      shouldAutoCreate = if dialogueServerSettings and dialogueServerSettings.speechBubble and dialogueServerSettings.speechBubble.shouldAutoCreate ~= nil then dialogueServerSettings.speechBubble.shouldAutoCreate else Conversation.defaultSettings.speechBubble.shouldAutoCreate; 
      billboardGUI = if dialogueServerSettings and dialogueServerSettings.speechBubble and dialogueServerSettings.speechBubble.billboardGUI ~= nil then dialogueServerSettings.speechBubble.billboardGUI else Conversation.defaultSettings.speechBubble.billboardGUI;
      button = if dialogueServerSettings and dialogueServerSettings.speechBubble and dialogueServerSettings.speechBubble.button ~= nil then dialogueServerSettings.speechBubble.button else Conversation.defaultSettings.speechBubble.button;
      adornee = if dialogueServerSettings and dialogueServerSettings.speechBubble and dialogueServerSettings.speechBubble.adornee ~= nil then dialogueServerSettings.speechBubble.adornee else Conversation.defaultSettings.speechBubble.adornee;
    }
  };

  local function getSettings(self: Conversation): ConversationSettings

    return table.clone(settings);

  end;

  local function getChildren(self: Conversation): {Dialogue}

    local children = {};
    for _, child in moduleScript:GetChildren() do

      if child:IsA("ModuleScript") and tonumber(child.Name) then

        local dialogue = require(child) :: Dialogue;
        table.insert(children, dialogue);

      end;

    end;

    return children;

  end;

  local function findNextVerifiedDialogue(self: Conversation): Dialogue?

    if self.type == "Redirect" then

      local redirectObjectValue = moduleScript:FindFirstChild("Redirect");
      assert(redirectObjectValue and redirectObjectValue:IsA("ObjectValue"), "[Dialogue Maker] Redirect object value not found.");

      local redirectModuleScript = redirectObjectValue.Value;
      assert(redirectModuleScript and redirectModuleScript:IsA("ModuleScript"), "[Dialogue Maker] Redirect object value is not a ModuleScript.");

      local redirectDialogue = require(redirectModuleScript) :: Dialogue;
      if redirectDialogue:verifyCondition() then

        return redirectDialogue;

      end;

    else 

      local children = self:getChildren();
      for _, child in children do

        if child:verifyCondition() then

          return child;

        end

      end

    end;

    return nil;

  end;

  local function setSettings(self: Conversation, newSettings: ConversationSettings): ()

    settings = newSettings;
    settingsChangedEvent:Fire(newSettings);

  end;

  local dialogueServer: Conversation = {
    getChildren = getChildren;
    getSettings = getSettings;
    setSettings = setSettings;
    findNextVerifiedDialogue = findNextVerifiedDialogue;
    moduleScript = moduleScript;
  };

  return dialogueServer;

end;

function Conversation.getFromDialogue(dialogue: Dialogue): Conversation

  local conversationModuleScript: ModuleScript?;
  local currentModuleScript = dialogue.moduleScript;
  repeat

    conversationModuleScript = currentModuleScript:FindFirstAncestorOfClass("ModuleScript");

  until not conversationModuleScript or conversationModuleScript:HasTag("DialogueMakerConversation");

  assert(conversationModuleScript, `[Dialogue Maker] Dialogue is missing an ancestor with a Conversation object.`);

  local conversation = require(conversationModuleScript) :: Conversation;

  return conversation;

end;

return Conversation;