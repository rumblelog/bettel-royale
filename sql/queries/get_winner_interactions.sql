-- Get each round's winner and how many interactions they had in those games.
--
-- name: GetWinnerInteractions :many
SELECT DISTINCT
    g.id AS game_id,
    g.start_time AS game_start_time,
    winner_uno.name AS winner_user_name,
    sum(uno.name = winner_uno.name) AS winner_interactions,
    concat('https://canary.discord.com/channels/558322816416743459/', g.discord_channel_id, '/', g.discord_message_id) AS game_discord_message_link
FROM games g
LEFT JOIN users AS winner_user
    ON g.winner_user_id = winner_user.id
LEFT JOIN user_name_observations AS winner_uno
    ON winner_uno.user_id = winner_user.id AND winner_uno.id = (
        SELECT MAX(winner_uno2.id)
        FROM user_name_observations winner_uno2
        WHERE winner_uno2.user_id = winner_user.id
    )
LEFT JOIN rounds r
    ON r.game_id = g.id
LEFT JOIN interactions i
    ON i.round_id = r.id
LEFT JOIN interaction_messages m
    ON i.message_id = m.id
LEFT JOIN interaction_item_mappings im
    ON i.id = im.interaction_id
LEFT JOIN items AS item
    ON im.item_name = item.name
LEFT JOIN interaction_user_mention_mappings umm
    ON i.id = umm.interaction_id
LEFT JOIN interaction_user_mentions um
    ON umm.interaction_user_mention_id = um.id
LEFT JOIN users AS user
    ON um.user_id = user.id
LEFT JOIN user_name_observations AS uno
    ON uno.user_id = user.id AND uno.id = (
        SELECT MAX(uno2.id)
        FROM user_name_observations uno2
        WHERE uno2.user_id = user.id
    )
GROUP BY g.id, winner_uno.name
ORDER BY winner_interactions ASC;
