package database

import (
	"context"
	"fmt"
	"io"
	"log"
	"slices"
	"time"

	"github.com/schollz/sqlite3dump"
	"gorm.io/driver/sqlite"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

var _ logger.Interface = &gormLogger{}

type gormLogger struct{}

// Error implements logger.Interface.
func (g *gormLogger) Error(_ context.Context, f string, args ...interface{}) {
	log.Printf("ERROR: "+f+"\n", args...)
}

// Info implements logger.Interface.
func (g *gormLogger) Info(_ context.Context, f string, args ...interface{}) {
	log.Printf("INFO: "+f+"\n", args...)
}

// LogMode implements logger.Interface.
func (g *gormLogger) LogMode(l logger.LogLevel) logger.Interface {
	// TODO - unimplemented
	return g
}

// Trace implements logger.Interface.
func (g *gormLogger) Trace(ctx context.Context, begin time.Time, fc func() (sql string, rowsAffected int64), err error) {
	_, _ = fc()
	// TODO - unimplemented
}

// Warn implements logger.Interface.
func (g *gormLogger) Warn(_ context.Context, f string, args ...interface{}) {
	log.Printf("WARNING: "+f+"\n", args...)
}

func OpenSQLite(sqlitePath string) (*Database, error) {
	// db, err := sql.Open("sqlite", sqlitePath)

	gormDB, err := gorm.Open(sqlite.Open(sqlitePath), &gorm.Config{
		Logger: &gormLogger{},
	})
	if err != nil {
		return nil, err
	}

	wrappedDB := &Database{
		db: gormDB,
	}

	return wrappedDB, nil
}

type Database struct {
	db *gorm.DB
}

func (d *Database) GORM() *gorm.DB {
	return d.db
}

var entities []interface{} = []any{
	&User{},
	&InteractionUserMention{},
	&Item{},
	&InteractionMessage{},
	&Interaction{},
	&Round{},
	&Game{},
}

func (d *Database) AutoMigrate() error {
	return d.db.AutoMigrate(entities...)
}

func (d *Database) Export(out io.Writer) error {
	db, err := d.db.DB()
	if err != nil {
		return err
	}
	return sqlite3dump.DumpDB(
		db,
		out,
		sqlite3dump.WithTransaction(false),
		sqlite3dump.WithDropIfExists(true))
}

func (d *Database) Reset() error {
	reversedEntities := make([]any, len(entities))
	copy(reversedEntities, entities)
	slices.Reverse(reversedEntities)
	for _, entity := range entities {
		stmt := &gorm.Statement{DB: d.db}
		stmt.Parse(entity)
		tableName := stmt.Schema.Table
		if tx := d.db.Raw(fmt.Sprintf("TRUNCATE TABLE  %s;", tableName)); tx.Error != nil {
			return tx.Error
		}
	}
	return nil
}
