package models

import "time"

// BrandColors, firmanın marka renk paletini tutar.
type BrandColors struct {
	Primary   string `json:"primary,omitempty"`
	Secondary string `json:"secondary,omitempty"`
}

// Company, kuyumcu firma/mağaza hesabını temsil eder.
type Company struct {
	ID              string       `json:"id" db:"id"`
	OwnerUserID     string       `json:"owner_user_id" db:"owner_user_id"`
	Name            string       `json:"name" db:"name"`
	Phone           *string      `json:"phone,omitempty" db:"phone"`
	City            *string      `json:"city,omitempty" db:"city"`
	InstagramHandle *string      `json:"instagram_handle,omitempty" db:"instagram_handle"`
	WebsiteURL      *string      `json:"website_url,omitempty" db:"website_url"`
	LogoURL         *string      `json:"logo_url,omitempty" db:"logo_url"` // S3/R2 uyumlu URL
	BrandColors     *BrandColors `json:"brand_colors,omitempty" db:"brand_colors"`
	CreditBalance   int          `json:"credit_balance" db:"credit_balance"`
	Plan            string       `json:"plan" db:"plan"` // trial, starter, pro, enterprise
	CreatedAt       time.Time    `json:"created_at" db:"created_at"`
	UpdatedAt       time.Time    `json:"updated_at" db:"updated_at"`
}
