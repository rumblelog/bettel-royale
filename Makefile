DOTNET = dotnet
GIT = git
GO = go

DCE_SRC_PATH = submodules/DiscordChatExporter
DCE_BUILT_BIN_PATH := $(DCE_SRC_PATH)/DiscordChatExporter.Cli/bin/Release/net8.0/DiscordChatExporter.Cli.dll
DCE_BIN_PATH = $(DCE_BUILT_BIN_PATH)
DCE_DEPS := $(DCE_BIN_PATH)
DCE_BUILD_CONFIGURATION = Release
DCE_CMD := $(DOTNET) $(DCE_BIN_PATH)

DISCORD_TOKEN = 
BATTLE_ROYALE_CHANNEL_ID = 1224009923457847428

.PHONY: all
all: dumps

.PHONY: build-dce
build-dce: submodules/DiscordChatExporter/DiscordChatExporter.Cli/bin/Release/net8.0/DiscordChatExporter.Cli.dll

.PHONY: discord-token
discord-token: $(DCE_DEPS)
	@[ -n $(DISCORD_TOKEN) ] || (echo "ERROR: DISCORD_TOKEN needs to be set. Here's a guide how to get this information:"; $(DCE_CMD) guide; exit 1)

###############################
# GIT SUBMODULES AUTO CHECKOUT

submodules/DiscordChatExporter: .git
	@[ -d $(CURDIR)/.git ] || (echo "ERROR: Need to check out with Git instead of downloading as source tarball for this to work." >&2; exit 1)
	$(GIT) submodule update --init $@

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
	$(DCE_CMD) export -t $(DISCORD_TOKEN) -f json --markdown false --utc -p 100 \
		-o discord-exports/$(DISCORD_CHANNEL_ID)/$(shell date +%s)/ \
		-c $(DISCORD_CHANNEL_ID) \
		--after $(shell $(MAKE) -s discord-export-last-message-id DISCORD_CHANNEL_ID=$(DISCORD_CHANNEL_ID))

discord-export: $(DCE_DEPS) discord-token
	$(MAKE) discord-export-channel DISCORD_CHANNEL_ID=$(BATTLE_ROYALE_CHANNEL_ID)

# Returns last message ID in local archives, if no archive exists will output 0
# instead of an ID.
discord-export-last-message-id:
	([ ! -d ./discord-exports/$(DISCORD_CHANNEL_ID) ] || find ./discord-exports/$(DISCORD_CHANNEL_ID) -name '*.json' -exec cat {} \;) |\
	(jq -r '.messages .[] .id' && echo 0) |\
	sort -n |\
	uniq |\
	tail -n1

#############
# PROCESSING

.PHONY: clean-db
clean-db:
	$(RM) main.db

main.db:
	@[ -d discord-exports/$(BATTLE_ROYALE_CHANNEL_ID) ] || (echo "ERROR: No discord export of battle royale channel exists yet, run \`make discord-export\` to create one."; exit 1)
	$(GO) run -v ./cmd/process-discord-exports import

.PHONY: clean-dumps
clean-dumps:
	$(RM) sql/all.sql

.PHONY: dumps
dumps: sql/all.sql

sql/all.sql: main.db
	$(GO) run -v ./cmd/process-discord-exports dump >$@

commit-sql-dump:
	git diff --exit-code ./sql/all.sql && echo "Nothing to be committed." || $(GIT) commit -m "Update SQL dump up to $(shell grep -Po '^-- Latest game time considered in this dump: \K.+' sql/all.sql)." -- ./sql/all.sql