# Product Requirements Document
## SPR House Maintenance Tracker

**Version:** 0.2 (Hackathon MVP)
**Date:** 2026-03-03
**Status:** Draft

---

## Revision History

| Version | Change |
|---|---|
| 0.1 | Initial draft |
| 0.2 | Removed freemium paywall logic; resolved platform, health score, geo, no-show, payment, and In Progress trigger decisions from adversarial review |

---

## 1. Problem Statement

Filipino property owners struggle with two interconnected problems:

1. **Forgetting maintenance** — Recurring tasks like aircon cleaning, pest control, and plumbing checks go undone because there is no system to track or remind them.
2. **Finding reliable vendors** — The informal referral network (Facebook groups, suki relationships, word-of-mouth) is the dominant method for finding service providers, but it is slow, inconsistent, and fails entirely for new homeowners or OFWs managing properties remotely.

Gawin.ph (Kaodim) attempted to solve this from 2015–2022 and shut down, citing **service provider fulfillment failures** as a key reason. This validates that demand exists but that the supply side (vendor experience) is the hardest problem to solve.

---

## 2. Target Users

### Primary: Filipino Homeowners
- Own or amortize a house/condo in the Philippines
- Busy, mobile-first, GCash/Shopee-native
- Forget maintenance until something breaks
- Rely on personal networks to find vendors

### Secondary: OFWs with Properties in the Philippines
- Cannot physically oversee maintenance
- Need remote visibility and a trusted vendor network

### Supply Side: Home Service Vendors
- Aircon technicians, pest control specialists, plumbers, electricians, general handymen
- Operate informally — cash-based, word-of-mouth, Facebook Marketplace
- Have inconsistent booking volume
- Low trust in platforms due to past failures (e.g., Gawin.ph)

---

## 3. Market Context

| Signal | Data |
|---|---|
| Homeowner households in PH | ~21.5 million (PSA 2020 Census) |
| Households owning additional properties | 5.32 million |
| Aircon units sold in 2023 | 922,000 |
| PH Home Care Market (2025) | USD 2.5 billion, growing at 9.81% CAGR |

Demand is validated. The opportunity is in solving vendor reliability and retention better than predecessors.

---

## 4. Tech Stack

| Layer | Decision |
|---|---|
| **Mobile** | Flutter (iOS + Android) |
| **Backend** | TBD |
| **Push Notifications** | Firebase Cloud Messaging (FCM) via `firebase_messaging` Flutter plugin — recommended; decide before day-one of hackathon |
| **Authentication** | Email + password |
| **Storage** | TBD — image uploads needed for profile photos, maintenance logs, QRPH codes |

> **Open:** Backend framework, auth method, and storage provider must be decided at hackathon kickoff before any feature work begins.

---

## 5. Core Value Proposition

> **For Filipino property owners:** Never miss a maintenance task and always have a reliable vendor one tap away.

> **For service vendors:** Get a steady stream of nearby bookings with zero upfront cost, full control over pricing, and a reputation that grows with every job.

---

## 6. Revenue Model

### Homeowner Side — Free

All homeowner features are free for the hackathon MVP. No paywall logic, no tier restrictions, no upgrade prompts. Freemium tiers are a post-launch consideration.

### Vendor Side — Admin Fee per Completed Job

| Model | Rate | Notes |
|---|---|---|
| **Per-transaction admin fee** | 10% of final confirmed job value | Charged only on completed bookings. No upfront cost, no subscription. |
| **Free during launch period** | 0% | Waived for the first 3 months to accelerate vendor onboarding. |

Vendors pay nothing to join and nothing until they earn. The final job value is confirmed by the vendor before the payment screen is shown to the homeowner — this is the number recorded for earnings tracking and future admin fee collection.

### Payment Flow (No Integration Required)

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

### Revenue Assumptions (Post-Hackathon)

| Metric | Conservative | Optimistic |
|---|---|---|
| Avg jobs per vendor/month | 8 | 20 |
| Avg job value | ₱800 | ₱1,500 |
| Admin fee per job | 10% = ₱80 | 10% = ₱150 |

---

## 7. Design Principles

These principles directly address why Gawin.ph failed on the vendor side:

1. **Earn trust before asking for anything** — No documents, no fees, no friction on vendor signup
2. **Never trap a vendor** — Easy on, easy off; no lock-in
3. **Make earnings obvious** — A clear earnings number is more motivating than any badge
4. **Zero tolerance for no-shows** — A confirmed vendor who does not show up is removed from the platform immediately; homeowners can reschedule without friction

---

## 8. MVP Scope (Hackathon)

### 8.1 Homeowner Features

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

### 8.2 Vendor Features

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

## 9. Core Demo Loop

This is the end-to-end flow that must work for a winning hackathon demo:

```
1. Homeowner sets up property (30 seconds)
          ↓
2. App suggests a maintenance schedule based on property type
          ↓
3. Push reminder fires for overdue aircon cleaning
          ↓
4. Home Health Score has dropped — homeowner sees it and acts
          ↓
5. Homeowner taps "Find a Vendor" → browses aircon techs
          ↓
6. Homeowner sends one-tap booking request
          ↓
7. Vendor receives instant push notification → taps Accept
          ↓
8. Booking status: Confirmed
          ↓
9. Vendor arrives → homeowner taps "Vendor is here" → In Progress
          ↓
10. Vendor inputs final price → job marked Completed
          ↓
11. Homeowner sees payment screen (QRPH / GCash) → taps "I've Paid"
          ↓
12. Homeowner logs completion with photo
          ↓
13. Home Health Score returns to 100
```

---

## 10. Out of Scope (Hackathon MVP)

| Feature | Reason |
|---|---|
| In-app reviews and ratings | Target V2 |
| In-app messaging | Phone number reveal used instead |
| Real payment processing | QRPH + GCash deep link handles demo flow |
| ID / background verification | Ops-heavy; target V2 |
| Multi-property management | Target V2 |
| SMS fallback notifications | Nice to have; deprioritized |
| Community / social feed | Out of core loop scope |
| Geographic / location-based vendor filtering | Removed to reduce complexity; target V2 |
| Freemium paywall and subscription tiers | Post-launch; no paywall logic in MVP |

---

## 11. Success Metrics (Post-Hackathon)

| Metric | Signal |
|---|---|
| Vendor accept rate | Are vendors engaging with bookings? |
| Vendor no-show rate | The Gawin.ph killer metric — must stay low |
| Task completion rate | Are homeowners logging completed maintenance? |
| D7 / D30 homeowner retention | Is the reminder loop driving return visits? |
| Time to first booking | How fast does a new homeowner make their first booking? |

---

## 12. Epics, User Stories & Acceptance Criteria

---

### Epic 1: Property Management
> Covers H1, H2, H3 — Setting up a property and establishing a maintenance schedule.

---

#### H1 — Property Setup

**User Story**
As a homeowner, I want to set up my property profile so that the app can suggest a relevant maintenance schedule tailored to my home.

**Acceptance Criteria**
- Given I am a new user, when I open the app for the first time, then I am guided through a property setup flow before reaching the home screen
- Given I am on the property setup screen, when I input property type (house / condo / lot) and property age, then my property profile is saved
- Given I complete property setup, when I proceed, then the app pre-loads a suggested maintenance schedule based on my inputs
- Given I want to edit my property details, when I go to settings, then I can update any field at any time
- Required fields: property type
- Optional fields: property age, property name/label

---

#### H2 — Pre-loaded Maintenance Templates

**User Story**
As a homeowner, I want to pick from pre-loaded Filipino home maintenance tasks so that I don't have to build my schedule from scratch.

**Acceptance Criteria**
- Given I have completed property setup, when I view the template list, then I see at minimum: aircon cleaning, pest control, plumbing check, septic tank pump-out, rooftop inspection, electrical check
- Given I am viewing templates, when I tap a task, then it is selected and added to my schedule
- Given I confirm my selection, when tasks are saved, then each task is assigned a default recurrence interval (e.g., aircon = quarterly, pest control = semi-annual)
- Given I want to customise, when I edit a task, then I can change the task name, recurrence interval, and add notes
- There are no limits on how many tasks a user can add

---

#### H3 — Recurring Schedule + Push Reminders

**User Story**
As a homeowner, I want to set recurring maintenance schedules with push reminders so that I am always notified when a task is due.

**Acceptance Criteria**
- Given a task is in my schedule, when its due date arrives, then I receive a push notification with the task name and a "Book a Vendor" shortcut
- Given a task is overdue, when I open the app, then the task is highlighted in red and shown at the top of my task list
- Given a task is due within 7 days, when I open the app, then the task is highlighted in yellow as "upcoming"
- Given I am creating or editing a task, when I set recurrence, then options are: monthly, quarterly, semi-annual, annual
- Given I tap a push notification, when it opens the app, then I am taken directly to the relevant task detail screen
- Given I complete and log a task, when I save the completion, then the next due date is automatically calculated and set

---

### Epic 2: Maintenance Tracking
> Covers H4, H5 — Logging completed work and visualising overall property health.

---

#### H4 — Maintenance Log with Photo

**User Story**
As a homeowner, I want to log completed maintenance tasks with photos so that I have an auditable record of all work done on my property.

**Acceptance Criteria**
- Given a task is due or overdue, when I tap "Mark as Complete," then I am prompted to confirm completion and optionally attach a photo
- Given I have completed a task, when I view maintenance history, then I see: task name, completion date, vendor name (if booked through app), and attached photo (if any)
- Given I want to review a past log entry, when I tap on it, then I see full details including the photo in full size
- Given a vendor has finished a job, when the booking is marked Completed, then both homeowner and vendor can upload photos to the job record
- Given I do not attach a photo, when I save the log entry, then the task is still recorded as completed

---

#### H5 — Home Health Score

**User Story**
As a homeowner, I want to see a Home Health Score on my dashboard so that I can understand at a glance how well I am maintaining my property.

**Acceptance Criteria**
- Given I have at least one maintenance task set up, when I open the home screen, then my Home Health Score (0–100) is displayed prominently
- Given no tasks are overdue, when I view my score, then it displays 100
- Given one or more tasks are overdue, when I view my score, then it is below 100; score decreases proportionally to the number of overdue tasks out of total tasks
- Given I complete and log all overdue tasks, when I save the last log, then my score returns to 100
- Given I am a new user with no tasks added yet, when I view the home screen, then I see a prompt to add tasks to activate my score

---

### Epic 3: Vendor Discovery & Booking
> Covers H6, H7, H8, H9 — Finding vendors, managing the booking flow, and handling no-shows.

---

#### H6 — Vendor Browse + Search

**User Story**
As a homeowner, I want to browse and search vendors by service type so that I can find the right professional for my maintenance task.

**Acceptance Criteria**
- Given I tap "Find a Vendor," when the vendor list loads, then all available vendors are shown (no geographic filter)
- Given I apply a service type filter (e.g., "Aircon Cleaning"), when the list updates, then only vendors offering that service are shown
- Given I view a vendor card in the list, when it renders, then I see: name, profile photo, services offered, price range, availability status, and completed jobs count
- Given a vendor has toggled their availability off, when I browse vendors, then they appear with an "Unavailable" badge and the Book button is disabled
- Given I search by keyword (e.g., "pest"), when results load, then vendors whose service names match the keyword are returned

---

#### H7 — One-Tap Booking Request

**User Story**
As a homeowner, I want to send a booking request to a vendor in one tap so that I can quickly schedule my maintenance service.

**Acceptance Criteria**
- Given I am on a vendor's profile, when I tap "Book," then a booking form appears with: service type (pre-selected) and preferred date
- Given I confirm the booking, when the request is submitted, then the vendor receives an instant push notification
- Given my booking request is sent, when I view my bookings list, then the status shows "Requested"
- Given a vendor declines my request, when I am notified, then I am shown a prompt to browse and book an alternative vendor

---

#### H8 — Booking Status Tracker

**User Story**
As a homeowner, I want to see the real-time status of my bookings so that I always know what is happening with my scheduled service.

**Acceptance Criteria**
- Given I have an active booking, when I view the bookings screen, then I see the current status as a step indicator: Requested → Confirmed → In Progress → Completed
- Given a vendor accepts my request, when they confirm, then my booking status updates to "Confirmed" and I receive a push notification
- Given the vendor has arrived at my property, when I tap "Vendor is here," then the booking status changes to "In Progress"
- Given the vendor inputs a final price and marks the job done, when I view the booking, then the status updates to "Completed" and the payment screen is shown
- Given I want to cancel a booking, when the status is still "Requested," then I can cancel with a confirmation dialog; cancellation after "Confirmed" shows a warning
- Given a booking request has not been responded to in 24 hours, when the timer expires, then it is auto-cancelled and I am notified to try another vendor

---

#### H9 — No-Show Reporting

**User Story**
As a homeowner, I want to report a vendor who did not show up so that the platform stays trustworthy and I can quickly rebook.

**Acceptance Criteria**
- Given my booking is in "Confirmed" status and the vendor has not arrived, when I tap "Vendor didn't show up," then I am asked to confirm the no-show report
- Given I confirm the no-show, when the report is submitted, then the vendor's account is immediately suspended and removed from the public vendor list
- Given the vendor is removed, when I view the screen, then I am shown a prompt: "Sorry about that — let's find you another vendor" with a direct link to browse alternatives
- Given I am browsing alternatives after a no-show, when the vendor list loads, then the suspended vendor does not appear

---

### Epic 4: Vendor Onboarding & Profile
> Covers V1, V8 — Getting vendors onto the platform quickly and building their public reputation.

---

#### V1 — Fast Vendor Onboarding (Under 2 Minutes)

**User Story**
As a service vendor, I want to sign up in under 2 minutes so that I can start receiving job notifications without a lengthy registration process.

**Acceptance Criteria**
- Given I download the app and select "I am a Vendor," when I complete onboarding, then the full process takes no more than 2 minutes
- Given I am onboarding, when I fill in my profile, then required fields are: full name, service type(s), contact number, profile photo
- Given I complete onboarding, when I submit, then my vendor profile is immediately active and visible to homeowners
- No documents, IDs, area coverage, or verification are required at signup
- Given I offer multiple services, when I select service types, then I can select more than one

---

#### V8 — Vendor Profile

**User Story**
As a vendor, I want a public profile that showcases my services and track record so that homeowners feel confident booking me.

**Acceptance Criteria**
- Given a homeowner views my profile, when it loads, then they see: name, photo, services offered, price range per service, availability status, and completed jobs count
- Given I complete a job logged as Completed, when the record is saved, then my completed jobs count increments by 1
- Given I update my profile, when I save, then changes are reflected immediately on my public profile
- Given I have 0 completed jobs, when a homeowner views my profile, then they see "New vendor — no completed jobs yet"

---

### Epic 5: Vendor Booking Management
> Covers V2, V3, V5 — Receiving, responding to, and managing availability.

---

#### V2 — Instant Booking Notification

**User Story**
As a vendor, I want to receive an instant push notification when a homeowner requests my service type so that I can respond quickly and secure the job.

**Acceptance Criteria**
- Given a homeowner submits a booking request for a service type I offer, when the request is created, then I receive a push notification within 30 seconds
- Given I receive the notification, when I tap it, then I am taken directly to the booking request detail screen
- The notification displays: service type and the homeowner's preferred date
- Given I have availability toggled off, when a booking request is created, then I do not receive a notification

---

#### V3 — One-Tap Accept / Decline

**User Story**
As a vendor, I want to accept or decline booking requests with a single tap so that I can manage my schedule efficiently.

**Acceptance Criteria**
- Given I am viewing a booking request, when I tap "Accept," then the homeowner is notified and the booking status changes to "Confirmed"
- Given I accept a booking, when confirmed, then the homeowner's contact details are revealed to me
- Given I tap "Decline," when confirmed, then I am prompted to select a reason: unavailable on that date / outside my service type / other
- Given a booking request has been pending for 24 hours with no response, when the timer expires, then it is automatically declined and the homeowner is notified
- Decline reasons are recorded silently for matching improvement and are not shown to the homeowner

---

#### V5 — Availability Toggle

**User Story**
As a vendor, I want to toggle my availability on and off so that I only receive bookings when I am actually able to work.

**Acceptance Criteria**
- Given I am on my vendor dashboard, when I toggle availability to "Off," then my profile shows "Currently Unavailable" and I stop receiving booking notifications
- Given I toggle availability back to "On," when activated, then I am immediately visible and bookable
- Given a homeowner views my profile while I am unavailable, when they see the status, then the "Book" button is disabled with label: "Not available for bookings"
- The availability toggle must be accessible from the main vendor dashboard — not buried in settings

---

### Epic 6: Vendor Business Tools
> Covers V4, V6, V7 — Pricing control, earnings visibility, and payment setup.

---

#### V4 — Vendor Sets Own Price Range

**User Story**
As a vendor, I want to set my own price range per service so that homeowners know what to expect and I retain full control over my earnings.

**Acceptance Criteria**
- Given I am setting up or editing my profile, when I configure pricing, then I can set a minimum and maximum price for each service type I offer
- Given I have set a price range, when a homeowner views my profile, then my price range is displayed (e.g., "₱500 – ₱800 per visit")
- Given I offer multiple services, when I set pricing, then I can assign a different price range to each service independently
- Given I want to change my price, when I edit my profile, then changes reflect immediately

---

#### V6 — Earnings Dashboard

**User Story**
As a vendor, I want to see a clear earnings summary so that I can track my income and stay motivated to use the platform.

**Acceptance Criteria**
- Given I open my vendor dashboard, when I view the earnings section, then I see: total completed jobs (all time), total gross earned, total net earned (gross minus 10% admin fee), and jobs completed this month
- Given a booking is marked Completed and final price confirmed, when the record is saved, then my earnings totals update immediately
- Given I have no completed jobs yet, when I view the earnings dashboard, then I see zero values with the message: "Complete your first job to start earning!"
- During the launch period when the admin fee is waived, net and gross amounts will be equal; the net column is shown to make the future fee obligation transparent

---

#### V7 — QRPH Payment Upload + GCash Deep Link

**User Story**
As a vendor, I want to set up my payment details so that homeowners can pay me directly after a job without cash handling or external coordination.

**Acceptance Criteria**
- Given I am setting up or editing my profile, when I upload my QR Ph code as an image (JPG or PNG), then it is saved and linked to my profile
- Given I input my GCash-registered mobile number in my profile, when saved, then it is used to generate the GCash deep link on the payment screen
- Given a booking is marked Completed and final price is confirmed, when the homeowner views the payment screen, then they see: the final amount, a scannable QRPH image, and a "Pay via GCash" button that deep-links to GCash with the amount pre-filled
- Given I have not uploaded a QR Ph code or GCash number, when a booking completes, then the payment screen shows: "Cash payment — coordinate with your vendor directly"
- Given the homeowner taps "I've Paid," when confirmed, then I receive a "Payment confirmed" push notification and the job record closes

---

### Epic 7: Final Price Confirmation
> Covers the payment handoff — vendor confirms job price before homeowner pays.

---

#### V9 — Final Price Confirmation

**User Story**
As a vendor, I want to confirm the final job price when I complete a job so that the homeowner knows exactly what to pay and my earnings are recorded accurately.

**Acceptance Criteria**
- Given a job is in "In Progress" status, when I tap "Mark as Complete," then I am prompted to input the final job price
- Given I input a final price, when I confirm, then the booking status changes to "Completed" and the homeowner receives a payment notification
- The final price input field shows my price range as a reference (e.g., "Your range: ₱500–₱800")
- Given I submit a final price of ₱0, when confirmed, then the system flags this for review — final price must be greater than zero

---

## 13. Open Questions

| # | Question | Owner | Priority |
|---|---|---|---|
| 1 | **Push notification setup** — Firebase FCM via `firebase_messaging` is recommended for Flutter. Needs backend token registration. | Backend team | Must decide Day 1 |
| 2 | **Backend framework** — TBD. Must align with Flutter and FCM requirements. | Backend team | Must decide Day 1 |
| 3 | **Vendor cold start** — How do we seed vendors for the hackathon demo? (Manual signup, mock data?) | All | Demo prep |
| 4 | **No-show appeal** — Should a suspended vendor be able to appeal or is the ban permanent? | — | Post-hackathon |
| 5 | **GCash deep link** — Confirm `gcash://send` scheme works on both iOS and Android test devices before demo. | Mobile team | Test early |
