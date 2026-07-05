package ai

// Plan, satın alınabilir bir kredi paketini tanımlar. MVP'de sabit kod
// olarak tutuluyor; admin panelinden yönetilmesi gerekirse bu, `plans`
// adında ayrı bir tabloya taşınabilir (bkz. migration 0003 yorum notu).
type Plan struct {
	ID           string
	Label        string
	CreditAmount int
	PriceTRY     float64
}

// Plans, Türkiye pazarı için tanımlı sabit paketlerdir.
var Plans = map[string]Plan{
	"starter": {
		ID:           "starter",
		Label:        "Başlangıç",
		CreditAmount: 100,
		PriceTRY:     499.00,
	},
	"pro": {
		ID:           "pro",
		Label:        "Profesyonel",
		CreditAmount: 500,
		PriceTRY:     1999.00,
	},
	"enterprise": {
		ID:           "enterprise",
		Label:        "Kurumsal",
		CreditAmount: 2000,
		PriceTRY:     6999.00,
	},
}

// GetPlan, plan ID'sinden Plan struct'ını döner; bulunamazsa false.
func GetPlan(planID string) (Plan, bool) {
	p, ok := Plans[planID]
	return p, ok
}
