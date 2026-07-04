package models

import (
	"encoding/json"
	"time"
)

// Basitlik ilkesi: kuyumcuya serbest metin yerine sabit, kısa seçenek
// listeleri sunulur. Bu sabitler hem backend validasyonunda hem de
// mobil/web arayüzdeki seçim kartlarında referans olarak kullanılabilir.
const (
	ProductTypeRing     = "ring"
	ProductTypeNecklace = "necklace"
	ProductTypeBracelet = "bracelet"
	ProductTypeEarring  = "earring"
	ProductTypeSet      = "set"

	MetalColorYellowGold = "yellow_gold"
	MetalColorWhiteGold  = "white_gold"
	MetalColorRoseGold   = "rose_gold"
	MetalColorSilver     = "silver"

	StoneTypeDiamond      = "diamond"
	StoneTypeZircon       = "zircon"
	StoneTypePearl        = "pearl"
	StoneTypeColoredStone = "colored_stone"
	StoneTypeNone         = "none"

	ProductStatusActive   = "active"
	ProductStatusArchived = "archived"
)

// Product, kuyumcunun yüklediği bir takı ürününü temsil eder.
type Product struct {
	ID          string  `json:"id" db:"id"`
	CompanyID   string  `json:"company_id" db:"company_id"`
	Name        string  `json:"name" db:"name"`
	Description *string `json:"description,omitempty" db:"description"`

	// Basitleştirilmiş sınıflandırma alanları
	ProductType string  `json:"product_type" db:"product_type"` // ring, necklace, bracelet, earring, set
	MetalColor  *string `json:"metal_color,omitempty" db:"metal_color"`
	StoneType   *string `json:"stone_type,omitempty" db:"stone_type"`

	CollectionName *string `json:"collection_name,omitempty" db:"collection_name"`
	SKU            *string `json:"sku,omitempty" db:"sku"`

	// S3/R2 uyumlu görsel URL'leri
	OriginalImageURL string  `json:"original_image_url" db:"original_image_url"`
	CleanImageURL    *string `json:"clean_image_url,omitempty" db:"clean_image_url"`
	MaskImageURL     *string `json:"mask_image_url,omitempty" db:"mask_image_url"`
	ThumbnailURL     *string `json:"thumbnail_url,omitempty" db:"thumbnail_url"`

	Status      string          `json:"status" db:"status"` // active, archived
	AIMetadata  json.RawMessage `json:"ai_metadata,omitempty" db:"ai_metadata"`

	CreatedAt time.Time `json:"created_at" db:"created_at"`
	UpdatedAt time.Time `json:"updated_at" db:"updated_at"`
}
