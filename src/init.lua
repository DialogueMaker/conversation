--!strict

local packages = script.Parent.roblox_packages;
local DialogueMakerTypes = require(packages.DialogueMakerTypes);

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
      component = nil;
    };
    typewriter = {
      canPlayerSkipDelay = nil;
      characterDelaySeconds = nil;
      soundTemplate = nil;
    };
  } :: ConversationSettings;
};

export type ConstructorProperties = {
  settings: OptionalConversationSettings?;
  children: {Dialogue}?;
}

function Conversation.new(properties: ConstructorProperties?): Conversation

  local settings: ConversationSettings = if properties and properties.settings then {
    speaker = if properties.settings.speaker then {
      name = properties.settings.speaker.name or Conversation.defaultSettings.speaker.name;
    } else Conversation.defaultSettings.speaker;
    theme = if properties.settings.theme then {
      component = properties.settings.theme.component or Conversation.defaultSettings.theme.component;
    } else Conversation.defaultSettings.theme;
    typewriter = if properties.settings.typewriter then {
      canPlayerSkipDelay = properties.settings.typewriter.canPlayerSkipDelay or Conversation.defaultSettings.typewriter.canPlayerSkipDelay;
      characterDelaySeconds = properties.settings.typewriter.characterDelaySeconds or Conversation.defaultSettings.typewriter.characterDelaySeconds;
      soundTemplate = properties.settings.typewriter.soundTemplate or Conversation.defaultSettings.typewriter.soundTemplate;
    } else Conversation.defaultSettings.typewriter;
  } else Conversation.defaultSettings;

  local function findNextVerifiedDialogue(self: Conversation): Dialogue?

    for _, child in self.children do
      
      if child:verifyCondition() then

        return child;

      end

    end

    return nil;

  end;

  local function getNextVerifiedDialogue(self: Conversation): Dialogue

    local nextDialogue = self:findNextVerifiedDialogue();
    assert(nextDialogue, "No verified dialogue found in conversation.");

    return nextDialogue;

  end;

  local children = if properties and properties.children then properties.children else {};

  local conversation: Conversation = {
    type = "Conversation" :: "Conversation";
    children = children;
    settings = settings;
    findNextVerifiedDialogue = findNextVerifiedDialogue;
    getNextVerifiedDialogue = getNextVerifiedDialogue;
  };

  for index, dialogue in conversation.children do

    if dialogue.parent ~= conversation then

      conversation.children[index] = dialogue:clone({
        parent = conversation;
      });
      
    end;

  end;

  return conversation;

end;

return Conversation;