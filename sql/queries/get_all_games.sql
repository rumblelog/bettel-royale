-- Get list of games a specific user took part in, along with whether the user
-- won in that game or not.
--
-- The query builds off the fact that a user must have been killed once to lose
-- or must be listed as a winner even if they never did anything in a match.
--
-- name: GetAllGames :many
SELECT DISTINCT
    g.id AS game_id,
    (winner_uno.name = 'icedream') AS is_winner
FROM interactions i
LEFT JOIN rounds r
    ON i.round_id = r.id
LEFT JOIN games g
    ON r.game_id = g.id
LEFT JOIN interaction_messages m
    ON i.message_id = m.id
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
    ON g.winner_user_id = winner_user.id
LEFT JOIN user_name_observations AS winner_uno
    ON winner_uno.user_id = winner_user.id AND winner_uno.id = (
        SELECT MAX(winner_uno2.id)
        FROM user_name_observations winner_uno2
        WHERE winner_uno2.user_id = winner_user.id
    )
WHERE uno.name = 'icedream' or winner_uno.name = 'icedream'
GROUP BY g.id;
