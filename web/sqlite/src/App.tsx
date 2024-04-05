import React, { useState, useEffect } from 'react';
import logo from './logo.svg';
import './App.css';

import { getDB, importDB, initDB } from './mainDatabase';
import { Database } from '@stephen/sql.js';
import { getUsers } from './database/users.sql';
import { getGames } from './database/games.sql';
import { getItems } from './database/items.sql';
import { getInteractions } from './database/interactions.sql';

function App() {
  const [db, setDB] = useState<Database | null>(null);
  const [error, setError] = useState<unknown>(null);

  useEffect(() => {
    async function fetchDB() {
      // sql.js needs to fetch its wasm file, so we cannot immediately instantiate the database
      // without any configuration, initSqlJs will fetch the wasm files directly from the same path as the js
      // see ../craco.config.js
      try {
        await initDB();
        await importDB(new URL('db/main.db', window.location.href));
        const db = getDB();
        // window.console.info(db.exec('select count(*) from games;').values());
        console.info(getUsers(db, {
          like: '%',
          offset: 0,
          maxCount: -1
        }));
        console.info(getGames(db, {
          offset: 0,
          maxCount: -1
        }));
        console.info(getItems(db, {
          offset: 0,
          maxCount: -1
        }));
        console.info(getInteractions(db, {
          offset: 0,
          maxCount: -1
        }));
        setDB(db);
      } catch (err) {
        setError(err);
        window.console.error(err);
      }
    }

    fetchDB();
  }, []);

  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <div>
          {
            error ? <p>
              <strong>ERROR:</strong><br />
              {error.toString()}
            </p> : null
          }
          {
            !db ? <p>Loading...</p> : null
          }
        </div>
      </header>
    </div>
  );
}

export default App;
