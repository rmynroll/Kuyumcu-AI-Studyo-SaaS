package models

import "time"

// User, uygulamaya giriş yapan kuyumcu hesabı sahibini veya ekip üyesini temsil eder.
type User struct {
	ID           string    `json:"id" db:"id"`
	Email        *string   `json:"email,omitempty" db:"email"`
	Phone        *string   `json:"phone,omitempty" db:"phone"`
	PasswordHash string    `json:"-" db:"password_hash"` // asla JSON'a serileştirilmez
	FullName     *string   `json:"full_name,omitempty" db:"full_name"`
	Role         string    `json:"role" db:"role"` // owner, member, admin
	IsActive     bool      `json:"is_active" db:"is_active"`
	CreatedAt    time.Time `json:"created_at" db:"created_at"`
	UpdatedAt    time.Time `json:"updated_at" db:"updated_at"`
}
