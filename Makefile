DOTNET = dotnet

DCE_SRC_PATH = submodules/DiscordChatExporter
DCE_BUILT_BIN_PATH := $(DCE_SRC_PATH)/DiscordChatExporter.Cli/bin/Release/net8.0/DiscordChatExporter.Cli.dll
DCE_BIN_PATH = $(DCE_BUILT_BIN_PATH)
DCE_DEPS := $(DCE_BIN_PATH)
DCE_BUILD_CONFIGURATION = Release
DCE_CMD := $(DOTNET) $(DCE_BIN_PATH)

DISCORD_TOKEN = 
BATTLE_ROYALE_CHANNEL_ID = 1224009923457847428

.PHONY: build-dce
build-dce: submodules/DiscordChatExporter/DiscordChatExporter.Cli/bin/Release/net8.0/DiscordChatExporter.Cli.dll

.PHONY: discord-token
discord-token: $(DCE_DEPS)
	@[ -n $(DISCORD_TOKEN) ] || (echo "ERROR: DISCORD_TOKEN needs to be set. Here's a guide how to get this information:"; $(DCE_CMD) guide; exit 1)

###############################
# GIT SUBMODULES AUTO CHECKOUT

submodules/DiscordChatExporter: .git
	if [ ! -d $(CURDIR)/.git ]; then echo "ERROR: Need to check out with Git instead of downloading as source tarball for this to work." >&2; exit 1; fi
	git submodule update --init $@

##############################
# DISCORD CHAT EXPORTER BUILD

$(DCE_SRC_PATH)/DiscordChatExporter.Cli/bin/Release/net8.0/DiscordChatExporter.Cli.dll: $(DCE_SRC_PATH) $(DCE_SRC_PATH)/DiscordChatExporter.Cli/DiscordChatExporter.Cli.csproj
	$(DOTNET) build --configuration $(DCE_BUILD_CONFIGURATION) $(DCE_SRC_PATH)/DiscordChatExporter.Cli/DiscordChatExporter.Cli.csproj

######################
# DISCORD CHAT EXPORT

.PHONY: clean-discord-exports
clean-discord-exports:
	$(RM) -r discord-exports

dce-help: $(DCE_DEPS)
	$(DCE_CMD) --help

discord-export-channel: $(DCE_DEPS) discord-token
	$(DCE_CMD) export -t $(DISCORD_TOKEN) -f json --markdown false --utc -p 100 -o discord-exports/$(DISCORD_CHANNEL_ID)/ -c $(DISCORD_CHANNEL_ID)

discord-export: $(DCE_DEPS) discord-token
	$(MAKE) discord-export-channel DISCORD_CHANNEL_ID=$(BATTLE_ROYALE_CHANNEL_ID)

#############
# PROCESSING

.PHONY: clean-db
clean-db:
	$(RM) main.db

main.db:
	@[ -d discord-exports/$(BATTLE_ROYALE_CHANNEL_ID) ] || (echo "ERROR: No discord export of battle royale channel exists yet, run \`make discord-export\` to create one."; exit 1)
	go run -v ./cmd/process-discord-exports import

.PHONY: clean-dumps
clean-dumps:
	$(RM) sql/all.sql

.PHONY: dumps
dumps: sql/all.sql

sql/all.sql: main.db
	go run -v ./cmd/process-discord-exports dump >$@
