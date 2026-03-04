# 12. Epics, User Stories & Acceptance Criteria

---

## Epic 1: Property Management
> Covers H1, H2, H3 — Setting up a property and establishing a maintenance schedule.

---

### H1 — Property Setup

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

### H2 — Pre-loaded Maintenance Templates

**User Story**
As a homeowner, I want to pick from pre-loaded Filipino home maintenance tasks so that I don't have to build my schedule from scratch.

**Acceptance Criteria**
- Given I have completed property setup, when I view the template list, then I see at minimum: aircon cleaning, pest control, plumbing check, septic tank pump-out, rooftop inspection, electrical check
- Given I am viewing templates, when I tap a task, then it is selected and added to my schedule
- Given I confirm my selection, when tasks are saved, then each task is assigned a default recurrence interval (e.g., aircon = quarterly, pest control = semi-annual)
- Given I want to customise, when I edit a task, then I can change the task name, recurrence interval, and add notes
- There are no limits on how many tasks a user can add

---

### H3 — Recurring Schedule + Push Reminders

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

## Epic 2: Maintenance Tracking
> Covers H4, H5 — Logging completed work and visualising overall property health.

---

### H4 — Maintenance Log with Photo

**User Story**
As a homeowner, I want to log completed maintenance tasks with photos so that I have an auditable record of all work done on my property.

**Acceptance Criteria**
- Given a task is due or overdue, when I tap "Mark as Complete," then I am prompted to confirm completion and optionally attach a photo
- Given I have completed a task, when I view maintenance history, then I see: task name, completion date, vendor name (if booked through app), and attached photo (if any)
- Given I want to review a past log entry, when I tap on it, then I see full details including the photo in full size
- Given a vendor has finished a job, when the booking is marked Completed, then both homeowner and vendor can upload photos to the job record
- Given I do not attach a photo, when I save the log entry, then the task is still recorded as completed

---

### H5 — Home Health Score

**User Story**
As a homeowner, I want to see a Home Health Score on my dashboard so that I can understand at a glance how well I am maintaining my property.

**Acceptance Criteria**
- Given I have at least one maintenance task set up, when I open the home screen, then my Home Health Score (0–100) is displayed prominently
- Given no tasks are overdue, when I view my score, then it displays 100
- Given one or more tasks are overdue, when I view my score, then it is below 100; score decreases proportionally to the number of overdue tasks out of total tasks
- Given I complete and log all overdue tasks, when I save the last log, then my score returns to 100
- Given I am a new user with no tasks added yet, when I view the home screen, then I see a prompt to add tasks to activate my score

---

## Epic 3: Vendor Discovery & Booking
> Covers H6, H7, H8, H9 — Finding vendors, managing the booking flow, and handling no-shows.

---

### H6 — Vendor Browse + Search

**User Story**
As a homeowner, I want to browse and search vendors by service type so that I can find the right professional for my maintenance task.

**Acceptance Criteria**
- Given I tap "Find a Vendor," when the vendor list loads, then all available vendors are shown (no geographic filter)
- Given I apply a service type filter (e.g., "Aircon Cleaning"), when the list updates, then only vendors offering that service are shown
- Given I view a vendor card in the list, when it renders, then I see: name, profile photo, services offered, price range, availability status, and completed jobs count
- Given a vendor has toggled their availability off, when I browse vendors, then they appear with an "Unavailable" badge and the Book button is disabled
- Given I search by keyword (e.g., "pest"), when results load, then vendors whose service names match the keyword are returned

---

### H7 — One-Tap Booking Request

**User Story**
As a homeowner, I want to send a booking request to a vendor in one tap so that I can quickly schedule my maintenance service.

**Acceptance Criteria**
- Given I am on a vendor's profile, when I tap "Book," then a booking form appears with: service type (pre-selected) and preferred date
- Given I confirm the booking, when the request is submitted, then the vendor receives an instant push notification
- Given my booking request is sent, when I view my bookings list, then the status shows "Requested"
- Given a vendor declines my request, when I am notified, then I am shown a prompt to browse and book an alternative vendor

---

### H8 — Booking Status Tracker

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

### H9 — No-Show Reporting

**User Story**
As a homeowner, I want to report a vendor who did not show up so that the platform stays trustworthy and I can quickly rebook.

**Acceptance Criteria**
- Given my booking is in "Confirmed" status and the vendor has not arrived, when I tap "Vendor didn't show up," then I am asked to confirm the no-show report
- Given I confirm the no-show, when the report is submitted, then the vendor's account is immediately suspended and removed from the public vendor list
- Given the vendor is removed, when I view the screen, then I am shown a prompt: "Sorry about that — let's find you another vendor" with a direct link to browse alternatives
- Given I am browsing alternatives after a no-show, when the vendor list loads, then the suspended vendor does not appear

---

## Epic 4: Vendor Onboarding & Profile
> Covers V1, V8 — Getting vendors onto the platform quickly and building their public reputation.

---

### V1 — Fast Vendor Onboarding (Under 2 Minutes)

**User Story**
As a service vendor, I want to sign up in under 2 minutes so that I can start receiving job notifications without a lengthy registration process.

**Acceptance Criteria**
- Given I download the app and select "I am a Vendor," when I complete onboarding, then the full process takes no more than 2 minutes
- Given I am onboarding, when I fill in my profile, then required fields are: full name, service type(s), contact number, profile photo
- Given I complete onboarding, when I submit, then my vendor profile is immediately active and visible to homeowners
- No documents, IDs, area coverage, or verification are required at signup
- Given I offer multiple services, when I select service types, then I can select more than one

---

### V8 — Vendor Profile

**User Story**
As a vendor, I want a public profile that showcases my services and track record so that homeowners feel confident booking me.

**Acceptance Criteria**
- Given a homeowner views my profile, when it loads, then they see: name, photo, services offered, price range per service, availability status, and completed jobs count
- Given I complete a job logged as Completed, when the record is saved, then my completed jobs count increments by 1
- Given I update my profile, when I save, then changes are reflected immediately on my public profile
- Given I have 0 completed jobs, when a homeowner views my profile, then they see "New vendor — no completed jobs yet"

---

## Epic 5: Vendor Booking Management
> Covers V2, V3, V5 — Receiving, responding to, and managing availability.

---

### V2 — Instant Booking Notification

**User Story**
As a vendor, I want to receive an instant push notification when a homeowner requests my service type so that I can respond quickly and secure the job.

**Acceptance Criteria**
- Given a homeowner submits a booking request for a service type I offer, when the request is created, then I receive a push notification within 30 seconds
- Given I receive the notification, when I tap it, then I am taken directly to the booking request detail screen
- The notification displays: service type and the homeowner's preferred date
- Given I have availability toggled off, when a booking request is created, then I do not receive a notification

---

### V3 — One-Tap Accept / Decline

**User Story**
As a vendor, I want to accept or decline booking requests with a single tap so that I can manage my schedule efficiently.

**Acceptance Criteria**
- Given I am viewing a booking request, when I tap "Accept," then the homeowner is notified and the booking status changes to "Confirmed"
- Given I accept a booking, when confirmed, then the homeowner's contact details are revealed to me
- Given I tap "Decline," when confirmed, then I am prompted to select a reason: unavailable on that date / outside my service type / other
- Given a booking request has been pending for 24 hours with no response, when the timer expires, then it is automatically declined and the homeowner is notified
- Decline reasons are recorded silently for matching improvement and are not shown to the homeowner

---

### V5 — Availability Toggle

**User Story**
As a vendor, I want to toggle my availability on and off so that I only receive bookings when I am actually able to work.

**Acceptance Criteria**
- Given I am on my vendor dashboard, when I toggle availability to "Off," then my profile shows "Currently Unavailable" and I stop receiving booking notifications
- Given I toggle availability back to "On," when activated, then I am immediately visible and bookable
- Given a homeowner views my profile while I am unavailable, when they see the status, then the "Book" button is disabled with label: "Not available for bookings"
- The availability toggle must be accessible from the main vendor dashboard — not buried in settings

---

## Epic 6: Vendor Business Tools
> Covers V4, V6, V7 — Pricing control, earnings visibility, and payment setup.

---

### V4 — Vendor Sets Own Price Range

**User Story**
As a vendor, I want to set my own price range per service so that homeowners know what to expect and I retain full control over my earnings.

**Acceptance Criteria**
- Given I am setting up or editing my profile, when I configure pricing, then I can set a minimum and maximum price for each service type I offer
- Given I have set a price range, when a homeowner views my profile, then my price range is displayed (e.g., "₱500 – ₱800 per visit")
- Given I offer multiple services, when I set pricing, then I can assign a different price range to each service independently
- Given I want to change my price, when I edit my profile, then changes reflect immediately

---

### V6 — Earnings Dashboard

**User Story**
As a vendor, I want to see a clear earnings summary so that I can track my income and stay motivated to use the platform.

**Acceptance Criteria**
- Given I open my vendor dashboard, when I view the earnings section, then I see: total completed jobs (all time), total gross earned, total net earned (gross minus 10% admin fee), and jobs completed this month
- Given a booking is marked Completed and final price confirmed, when the record is saved, then my earnings totals update immediately
- Given I have no completed jobs yet, when I view the earnings dashboard, then I see zero values with the message: "Complete your first job to start earning!"
- During the launch period when the admin fee is waived, net and gross amounts will be equal; the net column is shown to make the future fee obligation transparent

---

### V7 — QRPH Payment Upload + GCash Deep Link

**User Story**
As a vendor, I want to set up my payment details so that homeowners can pay me directly after a job without cash handling or external coordination.

**Acceptance Criteria**
- Given I am setting up or editing my profile, when I upload my QR Ph code as an image (JPG or PNG), then it is saved and linked to my profile
- Given I input my GCash-registered mobile number in my profile, when saved, then it is used to generate the GCash deep link on the payment screen
- Given a booking is marked Completed and final price is confirmed, when the homeowner views the payment screen, then they see: the final amount, a scannable QRPH image, and a "Pay via GCash" button that deep-links to GCash with the amount pre-filled
- Given I have not uploaded a QR Ph code or GCash number, when a booking completes, then the payment screen shows: "Cash payment — coordinate with your vendor directly"
- Given the homeowner taps "I've Paid," when confirmed, then I receive a "Payment confirmed" push notification and the job record closes

---

## Epic 7: Final Price Confirmation
> Covers the payment handoff — vendor confirms job price before homeowner pays.

---

### V9 — Final Price Confirmation

**User Story**
As a vendor, I want to confirm the final job price when I complete a job so that the homeowner knows exactly what to pay and my earnings are recorded accurately.

**Acceptance Criteria**
- Given a job is in "In Progress" status, when I tap "Mark as Complete," then I am prompted to input the final job price
- Given I input a final price, when I confirm, then the booking status changes to "Completed" and the homeowner receives a payment notification
- The final price input field shows my price range as a reference (e.g., "Your range: ₱500–₱800")
- Given I submit a final price of ₱0, when confirmed, then the system flags this for review — final price must be greater than zero

---
