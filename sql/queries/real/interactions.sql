-- Get list of interactions by game/round with affected players/items.
--
-- name: GetInteractions :many
SELECT
    g.`id` AS game_id,
    r.`round_number` AS round_number,
    m.`event` AS event,
    m.`text` AS text,
    COALESCE(GROUP_CONCAT(item.`name`, ';'), '') AS items,
    COALESCE(GROUP_CONCAT(uno.`name`, ';'), '') AS users
FROM `interactions` i
LEFT JOIN `rounds` r
    ON i.`round_id` = r.`id`
LEFT JOIN `games` g
    ON r.`game_id` = g.`id`
LEFT JOIN `interaction_messages` m
    ON i.`message_id` = m.`id`
LEFT JOIN `interaction_item_mappings` im
    ON i.`id` = im.`interaction_id`
LEFT JOIN `items` AS item
    ON im.`item_name` = item.`name`
LEFT JOIN `interaction_user_mention_mappings` umm
    ON i.`id` = umm.`interaction_id`
LEFT JOIN `interaction_user_mentions` um
    ON umm.`interaction_user_mention_id` = um.`id`
LEFT JOIN `users` AS u
    ON um.`user_id` = u.`id`
LEFT JOIN `user_name_observations` AS uno
    ON uno.`user_id` = u.`id` AND uno.`id` = (
        SELECT MAX(uno2.`id`)
        FROM `user_name_observations` uno2
        WHERE uno2.`user_id` = u.`id`)
GROUP BY i.`id`
ORDER BY i.`id` ASC
LIMIT sqlc.narg('max_count')
OFFSET sqlc.narg('offset')
;
