-- Get list of rounds won by a specific user.
--
-- name: GetWonRounds :many
SELECT DISTINCT
    g.id AS game_id,
    g.start_time AS game_start_time,
    winner_uno.name AS user_name
FROM games g
LEFT JOIN users AS winner_user
    ON g.winner_user_id = winner_user.id
LEFT JOIN user_name_observations AS winner_uno
    ON winner_uno.user_id = winner_user.id AND winner_uno.id = (
        SELECT MAX(winner_uno2.id)
        FROM user_name_observations winner_uno2
        WHERE winner_uno2.user_id = winner_user.id
    )
WHERE winner_uno.name = 'icedream';
GROUP BY g.id, uno.name;
