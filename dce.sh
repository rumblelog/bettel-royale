#!/usr/bin/env sh
exec dotnet "submodules/DiscordChatExporter/DiscordChatExporter.Cli/bin/Release/net8.0/DiscordChatExporter.Cli.dll" "$@"
