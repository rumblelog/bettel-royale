# Hololive Fan Server Bettel Royale statistics in SQL

For those of us who like to work with SQL. You can now browse data up to a
specific point via this archive and query it for whatever you want.

## How is the data collected?

1.  [DiscordChatExporter](https://github.com/Tyrrrz/DiscordChatExporter) is used
    to download an archive of all messages in the respective Battle Royale
    channel.
2.  A custom-written tool filters the data and extracts information with regex
    about each game, round, interaction (users/items, alive/killed) and event
    that happened.
3.  All extracted information is written to an SQLite database and then written
    out to an SQL dump.

## Which data does the SQL dump contain?

The SQL dump itself is structured into multiple tables:

-   `game` - Every game that happened is listed here with the information of who
    hosted it (or `NULL` if it was an automatically scheduled game), which era
    it ran on, when it started, the XP multiplier, the amount of coins rewarded
    for a win, who won and Discord references such as channel, start post and
    end post IDs.
-   `interactions` - Every interaction that happened is listed here with the
    round that it occurred in. The message ID is the respective message template
    in the `interaction_messages` template.
-   `interaction_messages` - Every message template ever encountered as an
    interaction in-game. The placeholders are to be filled out with users from
    `interaction_user_mention_mappings` or items from
    `interaction_item_mappings`.
-   `interaction_item_mention_mappings` - Each mention of an item associated
    with the interaction it occurred in.
-   `interaction_user_mention_mappings` - Each mention of a user along with
    their killed/alive state and suffix associated with the interaction it
    occurred in.
-   `rounds` - Every round that happened is listed here with the game it
    occurred in, the round number within that game and the Discord post ID.
-   `users` - Contains Discord User ID of any Discord userreferenced in other
    tables. Used to contain user name but that is now in
    `user_name_observations`.
-   `user_name_observations` - Contains the observations of the tool when
    someone was first seen with what nickname. This is where you should map the
    user ID to a nickname. Usually, you want the newest entry from this for
    simplicity but you can also try and approximate the username that would be
    closest to an entry's timestamp, however these timestamps aren't exactly
    accurate to when the nickname was actually changed, only when it was first
    picked up by the tool as being used in the respective channels in any
    visible way.

## Handling username changes over time

Whenever a user is referenced, there usually will be an *ID* and a *name*
column. Out of these, the *ID* column is the "more exact" one as it allows
assocating all names a user ever had to the same user. However, that column can
rarely also be `NULL` at least temporarily.

In the rare case where the tool is unable to find a user ID associated with the
name (e.g. a Discord archive ran late and the user changed their user name so
quickly that it escaped the tool entirely), the ID will be `NULL` and only the
name column will contain a value.

If you want accurate data for analysis, you most likely want to reference via
*ID*, or at least re-resolve the latest name of a user through the ID as was
done for the example queries, rather than rely on the name column since that
value will change over time for the same user.

For examples on how to write queries against this data you can check out
[sql/queries/](sql/queries/).

## Pronouns

Rumble Royale allows users to assign their own pronouns. However, this
introduces complexity to reversing the collected data to as close to original as
possible: Especially the singular `they` pronouns can easily be mixed up with
references to multiple persons or items.

This is a known issue still being worked on. For now, we only extract literal
Discord usernames from the interaction messages but leave the pronouns intact as
if they are part of the base template of the message. That means interactions
will be duplicated but with different pronouns.

As a consequence of this, it is currently recommended to filter for interaction
messages with `LIKE '%...%'` instead of looking for specific IDs.
