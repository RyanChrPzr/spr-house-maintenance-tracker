# 6. Revenue Model

## Homeowner Side — Free

All homeowner features are free for the hackathon MVP. No paywall logic, no tier restrictions, no upgrade prompts. Freemium tiers are a post-launch consideration.

## Vendor Side — Admin Fee per Completed Job

| Model | Rate | Notes |
|---|---|---|
| **Per-transaction admin fee** | 10% of final confirmed job value | Charged only on completed bookings. No upfront cost, no subscription. |
| **Free during launch period** | 0% | Waived for the first 3 months to accelerate vendor onboarding. |

Vendors pay nothing to join and nothing until they earn. The final job value is confirmed by the vendor before the payment screen is shown to the homeowner — this is the number recorded for earnings tracking and future admin fee collection.

## Payment Flow (No Integration Required)

```
Job marked Completed by vendor
        ↓
Vendor inputs final job price (e.g., ₱650)
        ↓
Homeowner sees payment screen:
  - Final amount: ₱650
  - [Scan QR Code]  ← vendor's QRPH image
  - [Pay via GCash] ← deep link: gcash://send?mobileNumber=09XX&amount=650
        ↓
Homeowner taps "I've Paid"
        ↓
Vendor receives "Payment confirmed" push notification
        ↓
Job record closes — vendor earnings dashboard updates
```

Admin fee collection is manual during the launch period. The platform records gross and net (gross minus 10%) in the vendor's earnings dashboard so the obligation is transparent from day one.

## Revenue Assumptions (Post-Hackathon)

| Metric | Conservative | Optimistic |
|---|---|---|
| Avg jobs per vendor/month | 8 | 20 |
| Avg job value | ₱800 | ₱1,500 |
| Admin fee per job | 10% = ₱80 | 10% = ₱150 |

---
