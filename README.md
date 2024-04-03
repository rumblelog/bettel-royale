# Hololive Fan Server Bettel Royale statistics in SQL

For those of us who like to work with SQL. You can now browse data up to a
specific point via this archive and query it for whatever you want.

## How is the data collected?

1.  [DiscordChatExporter](https://github.com/Tyrrrz/DiscordChatExporter) is used
    to download an archive of all messages in the respective Battle Royale
    channel.
2.  A custom-written tool filters the data and extracts information with regex about each game, round, interaction (users/items, alive/killed) and event that happened.
3.  All extracted information is written to an SQLite database and then written out to an SQL dump.

## Which data does the SQL dump contain?

The SQL dump itself is structured into multiple tables:

-   `game` - Every game that happened is listed here with the information of who
    hosted it (or `NULL` if it was an automatically scheduled game), which era
    it ran on, when it started, the XP multiplier and the amount of coins
    rewarded for a win.
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
    occurred in and the round number within that game.
-   `users` - Contains username of any Discord user that ever was shown to
    interact in Battle Royale.

For examples on how to write queries against this data you can check out
[sql/queries/](sql/queries/).