import SearchField from "../input/SearchField";
import type { Database } from '../../database';
import { useState } from "react";
import { getUsers, GetUsersRow } from "../../database/users.sql";
import { Menu } from "react-bulma-components";
import { getInteractions, GetInteractionsRow } from "../../database/interactions.sql";

function MainPage({
  db,
}: {
  db: Database,
}) {
  const [searchWorking, setSearchWorking] = useState<boolean>(false);
  const [usersRows, setUsersRows] = useState<GetUsersRow[] | null>(null);
  const [interactionsRows, setInteractionsRows] = useState<GetInteractionsRow[] | null>(null);

  return (
    <form>
      <SearchField
        onChange={(e) => {
          setSearchWorking(true);
          try {
            if (e.target.value.length === 0) {
              setUsersRows(null);
              setInteractionsRows(null);
              return;
            }

            const users = getUsers(db, {
              userName: null,
              userNameLike: `%${e.target.value}%`,
              offset: 0,
              maxCount: -1,
            });
            setUsersRows(users);

            const interactions = getInteractions(db, {
              itemName: null,
              userId: null,
              userName: e.target.value,
              userNameLike: null,
              messageText: null,
              // messageTextLike: `%${e.target.value}%`,
              messageTextLike: null,
              offset: 0,
              maxCount: -1,
            });
            setInteractionsRows(interactions);
          } finally {
            setSearchWorking(false);
          }
        }}
        working={searchWorking}
      />
      <Menu>
        {
          usersRows && usersRows.length > 0
            ? (
              <Menu.List title="Users">
                {
                  usersRows?.map(r => <Menu.List.Item>{r.userName}</Menu.List.Item>)
                }
              </Menu.List>
            )
            : ''
        }
        {
          interactionsRows && interactionsRows.length > 0
            ? (
              <Menu.List title="Interactions">
                {
                  interactionsRows?.map(r => <Menu.List.Item>{r.text}</Menu.List.Item>)
                }
              </Menu.List>
            )
            : ''
        }
      </Menu>
    </form>
  );


}


export default MainPage;
