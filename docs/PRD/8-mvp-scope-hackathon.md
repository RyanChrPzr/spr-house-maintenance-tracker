# 8. MVP Scope (Hackathon)

## 8.1 Homeowner Features

| # | Feature | Description |
|---|---|---|
| H1 | **Property Setup** | Input property type (house/condo/lot) and property age. Used to generate smart maintenance defaults. |
| H2 | **Pre-loaded Maintenance Templates** | Common Filipino home tasks pre-populated: aircon cleaning, pest control, plumbing check, septic tank, rooftop inspection, electrical check. Homeowner picks relevant ones. |
| H3 | **Recurring Schedule + Push Reminders** | Each task has a recurrence interval (monthly, quarterly, semi-annual, annual). Push notifications fire when a task is due or overdue. |
| H4 | **Maintenance Log with Photo** | After a task is completed, homeowner (or vendor) logs it with an optional photo. Creates an auditable property history. |
| H5 | **Home Health Score** | A simple 0–100 score. Starts at 100. Any overdue task reduces the score. Completing all overdue tasks restores it to 100. |
| H6 | **Vendor Browse + Search** | Browse all vendors on the platform filtered by service type only. No geographic filtering in MVP. |
| H7 | **One-Tap Booking Request** | Homeowner taps "Book" on a vendor profile, selects service type and preferred date, and submits the request. |
| H8 | **Booking Status Tracker** | Real-time status: Requested → Confirmed → In Progress → Completed. Homeowner triggers "In Progress" when the vendor arrives. |
| H9 | **No-Show Reporting** | If a confirmed vendor does not arrive, homeowner taps "Vendor didn't show up." Vendor account is immediately suspended from the platform. Homeowner is prompted to reschedule with another vendor. |

## 8.2 Vendor Features

| # | Feature | Description |
|---|---|---|
| V1 | **Fast Onboarding (under 2 minutes)** | Vendor inputs: name, service type(s), contact number, profile photo. No location, no documents required. |
| V2 | **Instant Booking Notification** | Push alert fires when any homeowner requests a service type the vendor offers. Shows job type and homeowner's preferred date. |
| V3 | **One-Tap Accept / Decline** | Vendor accepts or declines with a single tap. Decline prompts a reason. On accept, homeowner's contact details are revealed. |
| V4 | **Vendor Sets Own Price Range** | Vendor sets a min–max price range per service type displayed on their profile. |
| V5 | **Availability Toggle** | Simple on/off toggle: "Open for bookings." Prevents notifications and bookings when unavailable. |
| V6 | **Earnings Dashboard** | Shows total completed jobs, total gross earned, total net earned (after 10% fee), and jobs this month. |
| V7 | **QRPH Payment Upload** | Vendor uploads QR Ph code image. Displayed on payment screen after job completion alongside a GCash deep link. |
| V8 | **Vendor Profile** | Public-facing profile: name, photo, services, price range, availability status, completed jobs count. |

---
