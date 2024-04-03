package discord

import "time"

type Backup struct {
	Guild        Guild     `json:"guild"`
	Channel      Channel   `json:"channel"`
	DateRange    DateRange `json:"dateRange"`
	ExportedAt   time.Time `json:"exportedAt"`
	Messages     []Message `json:"messages"`
	MessageCount int       `json:"messageCount"`
}

type Guild struct {
	ID      string `json:"id"`
	Name    string `json:"name"`
	IconURL string `json:"iconUrl"`
}

type Channel struct {
	ID         string `json:"id"`
	Type       string `json:"type"`
	CategoryID string `json:"categoryId"`
	Category   string `json:"category"`
	Name       string `json:"name"`
	Topic      any    `json:"topic"`
}

type DateRange struct {
	After  any `json:"after"`
	Before any `json:"before"`
}

type Role struct {
	ID       string `json:"id"`
	Name     string `json:"name"`
	Color    any    `json:"color"`
	Position int    `json:"position"`
}

type Author struct {
	ID            string `json:"id"`
	Name          string `json:"name"`
	Discriminator string `json:"discriminator"`
	Nickname      string `json:"nickname"`
	Color         string `json:"color"`
	IsBot         bool   `json:"isBot"`
	Roles         []Role `json:"roles"`
	AvatarURL     string `json:"avatarUrl"`
}

type Thumbnail struct {
	URL    string `json:"url"`
	Width  int    `json:"width"`
	Height int    `json:"height"`
}

type Embed struct {
	Title       string      `json:"title"`
	URL         any         `json:"url"`
	Timestamp   any         `json:"timestamp"`
	Description string      `json:"description"`
	Color       string      `json:"color"`
	Thumbnail   Thumbnail   `json:"thumbnail"`
	Images      []any       `json:"images"`
	Fields      []any       `json:"fields"`
	Footer      *Footer     `json:"footer,omitempty"`
	Author      EmbedAuthor `json:"author,omitempty"`
}

type EmbedAuthor struct {
	Name    string `json:"name,omitempty"`
	URL     any    `json:"url,omitempty"`
	IconURL string `json:"iconUrl,omitempty"`
}

type Fields struct {
	Name     string `json:"name,omitempty"`
	Value    string `json:"value,omitempty"`
	IsInline bool   `json:"isInline,omitempty"`
}

type Footer struct {
	Text    string `json:"text,omitempty"`
	IconURL string `json:"iconUrl,omitempty"`
}

type Reference struct {
	MessageID string `json:"messageId"`
	ChannelID string `json:"channelId"`
	GuildID   string `json:"guildId"`
}

type User struct {
	ID            string `json:"id"`
	Name          string `json:"name"`
	Discriminator string `json:"discriminator"`
	Nickname      string `json:"nickname"`
	Color         string `json:"color"`
	IsBot         bool   `json:"isBot"`
	Roles         []Role `json:"roles"`
	AvatarURL     string `json:"avatarUrl"`
}

type Interaction struct {
	ID   string `json:"id"`
	Name string `json:"name"`
	User User   `json:"user"`
}

type Message struct {
	ID                 string       `json:"id"`
	Type               string       `json:"type"`
	Timestamp          time.Time    `json:"timestamp"`
	TimestampEdited    *time.Time   `json:"timestampEdited"`
	CallEndedTimestamp *time.Time   `json:"callEndedTimestamp"`
	IsPinned           bool         `json:"isPinned"`
	Content            string       `json:"content"`
	Author             Author       `json:"author"`
	Attachments        []any        `json:"attachments"`
	Embeds             []Embed      `json:"embeds"`
	Stickers           []any        `json:"stickers"`
	Reactions          []Reaction   `json:"reactions"`
	Mentions           []User       `json:"mentions"`
	Reference          *Reference   `json:"reference,omitempty"`
	Interaction        *Interaction `json:"interaction,omitempty"`
}

type Reaction struct {
	Emoji Emoji  `json:"emoji"`
	Count int    `json:"count"`
	Users []User `json:"users"`
}

type Emoji struct {
	ID         string `json:"id"`
	Name       string `json:"name"`
	Code       string `json:"code"`
	IsAnimated bool   `json:"isAnimated"`
	ImageURL   string `json:"imageUrl"`
}
