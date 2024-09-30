// Code generated by sqlc. DO NOT EDIT.
// source: games.sql

import { Database, QueryExecResult } from "@stephen/sql.js";




const getGamesStmt = `-- name: getGames :many
SELECT DISTINCT
    `+"`"+`id`+"`"+` AS id,
    `+"`"+`xp_multiplier`+"`"+` AS xp_multiplier,
    `+"`"+`discord_message_id`+"`"+` AS discord_message_id,
    `+"`"+`discord_end_message_id`+"`"+` AS discord_end_message_id,
    `+"`"+`winner_user_id`+"`"+` AS winner_user_id,
    `+"`"+`winner_user_name`+"`"+` AS winner_user_name
FROM `+"`"+`games`+"`"+` g
GROUP BY g.`+"`"+`id`+"`"+`
ORDER BY g.`+"`"+`id`+"`"+` ASC
LIMIT ?2
OFFSET ?1
`;


export type GetGamesParams = {
  offset: number | null;
  maxCount: number | null;
}



export type GetGamesRow = {
  id: number;
  xpMultiplier: number | null;
  discordMessageId: string | null;
  discordEndMessageId: string | null;
  winnerUserId: string | null;
  winnerUserName: string | null;
}





export function getGames(db: Database, arg: GetGamesParams): GetGamesRow[] {
  const result = db.exec(getGamesStmt, [arg.offset, arg.maxCount])
  if (result.length !== 1) {
    throw new Error("expected exec() to return a single query result")
  }

  const queryResult = result[0];
  const rvs: GetGamesRow[] = [];

  for (const row of queryResult.values) {
    
    
    if (typeof row[0] !== "number") { throw new Error(`expected type number for column id, but got ${typeof row[0]}`) };
    
    
    if (typeof row[1] !== "number" && row[1] !== null) { throw new Error(`expected type number | null for column xpMultiplier, but got ${typeof row[1]}`) };
    
    
    if (typeof row[2] !== "string" && row[2] !== null) { throw new Error(`expected type string | null for column discordMessageId, but got ${typeof row[2]}`) };
    
    
    if (typeof row[3] !== "string" && row[3] !== null) { throw new Error(`expected type string | null for column discordEndMessageId, but got ${typeof row[3]}`) };
    
    
    if (typeof row[4] !== "string" && row[4] !== null) { throw new Error(`expected type string | null for column winnerUserId, but got ${typeof row[4]}`) };
    
    
    if (typeof row[5] !== "string" && row[5] !== null) { throw new Error(`expected type string | null for column winnerUserName, but got ${typeof row[5]}`) };
    
    const rv: GetGamesRow = {
      id: row[0],
      xpMultiplier: row[1],
      discordMessageId: row[2],
      discordEndMessageId: row[3],
      winnerUserId: row[4],
      winnerUserName: row[5],
    };
    
    rvs.push(rv);
  }
  return rvs;
}

















