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
      shouldShowResponseWhileTyping = nil;
    };
  } :: ConversationSettings;
};

export type ConstructorProperties = {
  settings: OptionalConversationSettings?;
  children: {Dialogue}?;
}

function Conversation.new(properties: ConstructorProperties?, children: {Dialogue}?): Conversation

  local settings: ConversationSettings = if properties and properties.settings then {
    speaker = if properties.settings.speaker then {
      name = if properties.settings.speaker.name ~= nil then properties.settings.speaker.name else Conversation.defaultSettings.speaker.name;
    } else Conversation.defaultSettings.speaker;
    theme = if properties.settings.theme then {
      component = if properties.settings.theme.component ~= nil then properties.settings.theme.component else Conversation.defaultSettings.theme.component;
    } else Conversation.defaultSettings.theme;
    typewriter = if properties.settings.typewriter then {
      canPlayerSkipDelay = if properties.settings.typewriter.canPlayerSkipDelay ~= nil then properties.settings.typewriter.canPlayerSkipDelay else Conversation.defaultSettings.typewriter.canPlayerSkipDelay;
      characterDelaySeconds = if properties.settings.typewriter.characterDelaySeconds ~= nil then properties.settings.typewriter.characterDelaySeconds else Conversation.defaultSettings.typewriter.characterDelaySeconds;
      shouldShowResponseWhileTyping = if properties.settings.typewriter.shouldShowResponseWhileTyping ~= nil then properties.settings.typewriter.shouldShowResponseWhileTyping else Conversation.defaultSettings.typewriter.shouldShowResponseWhileTyping;
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

  local conversation: Conversation = {
    type = "Conversation" :: "Conversation";
    children = children or if properties and properties.children then properties.children else {};
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