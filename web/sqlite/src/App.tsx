import { useState, useEffect } from 'react';
import logo from './logo.svg';
import './App.css';

import { getDB, importDB, initDB } from './database';
import { Database } from '@stephen/sql.js';
import MainPage from './components/pages/main';

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
        <div>
          {
            error ? <p>
              <strong>ERROR:</strong><br />
              {error.toString()}
            </p> : null
          }
          {
            !db
              ? (
                <div>
                  <img src={logo} className="App-logo" alt="logo" />
                  <p>Loading...</p>
                </div>
              )
              : <MainPage db={db} />
          }
        </div>
      </header>
    </div>
  );
}

export default App;
