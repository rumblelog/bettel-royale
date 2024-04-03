package database

import "time"

type User struct {
	ID string `gorm:"primaryKey"`
}

type UserNameObservation struct {
	ID     int `gorm:"primaryKey"`
	User   User
	UserID string
	Time   time.Time
	Name   string
}

type InteractionUserMention struct {
	ID       int `gorm:"primaryKey"`
	User     *User
	UserID   *string
	UserName string
	Killed   bool
	Suffix   string
}

type Item struct {
	Name string `gorm:"primaryKey"`
}

type Interaction struct {
	ID           int `gorm:"primaryKey"`
	Round        Round
	RoundID      int
	Message      InteractionMessage
	MessageID    int
	UserMentions []InteractionUserMention `gorm:"many2many:interaction_user_mention_mappings;"`
	Items        []Item                   `gorm:"many2many:interaction_item_mappings;"`
}

type Round struct {
	ID               int `gorm:"primaryKey"`
	GameID           int `gorm:"index:game_round_idx,unique"`
	Game             Game
	RoundNumber      int `gorm:"index:game_round_idx,unique"`
	PostTime         time.Time
	DiscordMessageID string
}

type Game struct {
	ID                  int `gorm:"primaryKey"`
	DiscordChannelID    string
	DiscordMessageID    string
	Era                 string
	HostUserID          *string
	HostUser            *User
	HostUserName        *string
	StartTime           *time.Time
	EndTime             *time.Time
	Cancelled           bool
	CountdownStartTime  time.Time
	XPMultiplier        float32
	RewardCoins         uint
	DiscordEndMessageID string
	WinnerUserID        *string
	WinnerUser          *User
	WinnerUserName      *string
}

type InteractionMessage struct {
	ID    int    `gorm:"primaryKey"`
	Text  string `gorm:"index:interaction_message_text_idx,unique"`
	Event string
}
