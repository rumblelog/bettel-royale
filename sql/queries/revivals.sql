-- Return amount of revivals recorded by user.
--
-- name: GetRevivesByUser :many
SELECT DISTINCT
    user_name,
    count(*) AS revival_count
FROM (
    SELECT
        g.id AS game_id,
        r.round_number AS round_number,
        i.id AS interaction_id,
        m.text AS message,
        m.event AS event,
        um.killed AS killed,
        LAG(um.killed,1,0) OVER (
            PARTITION BY g.id, uno.name
            ORDER BY i.id
        ) was_killed,
        uno.name AS user_name,
        item.name AS item
    FROM interactions i
    LEFT JOIN rounds r
        ON i.round_id = r.id
    LEFT JOIN games g
        ON r.game_id = g.id
    LEFT JOIN interaction_messages m
        ON i.message_id = m.id
    LEFT JOIN interaction_item_mappings iim
        ON i.id = iim.interaction_id
    LEFT JOIN items item
        ON item.name = iim.item_name
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
    LEFT JOIN users AS winner_user
        ON um.user_id = winner_user.id
    LEFT JOIN user_name_observations AS winner_uno
        ON winner_uno.user_id = winner_user.id AND winner_uno.id = (
            SELECT MAX(winner_uno2.id)
            FROM user_name_observations winner_uno2
            WHERE winner_uno2.user_id = winner_user.id
        )
)
WHERE was_killed != killed
    AND killed IS FALSE
GROUP BY user_name
ORDER BY revival_count DESC;
