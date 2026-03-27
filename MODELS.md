# Comeals Data Model Reference

## Entity Relationship Overview

```
                                    COMMUNITY
                                        |
            +----------+--------+-------+-------+--------+----------+
            |          |        |       |       |        |          |
         AdminUser   Unit   Resident  Meal  Rotation  Reconcil.  Event
                      |        |       |       |        |
                      +--< Resident    |       +--< Meal +--< Meal
                               |       |
                    +----------+-------+----------+
                    |          |       |          |
                   Bill    MealResident  Guest   Key
                  (cook)   (attendee)  (visitor) (auth)
                    |          |
                    +----< Meal +----< Meal
```

All financial entities flow through Meal. A Meal has cooks (Bills), attendees (MealResidents), and visitors (Guests). The cost of each meal is split among attendees proportional to their multiplier.

---

## Core Models

### Community

The top-level container. Everything belongs to a community.

```
Community
  |
  +-- has_many Units
  +-- has_many Residents
  +-- has_many Meals
  +-- has_many Rotations
  +-- has_many Reconciliations
  +-- has_many Events
  +-- has_many AdminUsers
  +-- has_many GuestRoomReservations
  +-- has_many CommonHouseReservations
```

**Key fields:**
- `name` (unique) -- "Patches Way"
- `slug` (unique, via FriendlyId) -- "patches"
- `cap` DECIMAL(12,8) -- per-multiplier-unit cost cap. NULL = no cap.
- `timezone` -- "America/Los_Angeles"

**Behavior:**
- `capped?` -- true when cap is set
- `unreconciled_ave_cost` -- average cost per adult across unreconciled meals
- `create_next_rotation` -- generates the next rotation of 12 meals
- `trigger_pusher` -- broadcasts calendar updates via WebSocket

---

### Unit

A household or apartment. Groups residents together.

```
Unit ---< Resident
```

**Key fields:**
- `name` (unique per community) -- "A", "B", etc.

**Behavior:**
- `balance` -- sum of all residents' cached balances
- `meals_cooked` -- count of cooking slots across all residents for unreconciled meals

---

### Resident

A community member. The central entity for billing.

```
Resident
  |
  +-- belongs_to Unit
  +-- has_one Key (polymorphic, for API auth)
  +-- has_one ResidentBalance (cached balance)
  +-- has_many Bills (meals they cooked)
  +-- has_many MealResidents (meals they attended)
  +-- has_many Guests (visitors they brought)
  +-- has_many GuestRoomReservations
  +-- has_many CommonHouseReservations
```

**Key fields:**
- `name` (unique per community)
- `email` (unique, required for active adult cooks)
- `multiplier` -- pricing weight: 2=adult, 1=child
- `active` -- false for residents who moved/died
- `can_cook` -- eligible for cooking rotation
- `birthday` -- used for age-based multiplier auto-setting
**Scopes:**
- `adult` -- multiplier >= 2
- `active` -- active = true

**Financial methods:**
- `calc_balance` -- bill_reimbursements - meal_resident_costs - guest_costs (unreconciled meals only)
- `balance` -- reads from ResidentBalance cache (refreshed daily by rake task)
- `bill_reimbursements` -- SQL SUM of bill amounts for unreconciled meals
- `meal_resident_costs` -- sum of (meal.unit_cost * multiplier) for attended meals
- `guest_costs` -- sum of guest costs charged to this resident

---

## Financial Models

These models implement the cost-splitting system. Money flows like this:

```
Cook pays for groceries
        |
        v
    Bill.amount         (what the cook spent, in dollars)
        |
        v
    Meal.total_cost     (sum of all bill amounts)
        |
        v
    Meal.unit_cost      (total_cost / total_multiplier)
        |
        +-------> MealResident.cost = unit_cost * resident.multiplier
        |
        +-------> Guest.cost = unit_cost * guest.multiplier
```

At reconciliation, each resident's balance is:

```
balance = money_earned_cooking - money_owed_eating - money_owed_for_guests
```

### Bill

A cook's expense for a meal. One bill per cook per meal.

```
Bill ----> Meal
Bill ----> Resident (the cook)
Bill ----> Community
```

**Key fields:**
- `amount` DECIMAL(12,8) -- what the cook spent, in dollars
- `no_cost` -- true if this cook volunteered without cost (effective_amount = 0)
- DB constraint: `CHECK (amount >= 0)`

**Financial methods:**
- `effective_amount` -- 0 if no_cost, else amount
- `unit_cost` -- capped_amount / meal.multiplier
- `capped_amount` -- proportionally reduced when meal exceeds community cap

---

### Meal

A dinner event on a specific date.

```
Meal ----> Community
Meal ----> Reconciliation (optional, NULL = unreconciled)
Meal ----> Rotation (optional, cooking schedule group)
Meal ----< Bill (1-3 cooks typically)
Meal ----< MealResident (8-25 attendees typically)
Meal ----< Guest (0-5 visitors typically)
```

**Key fields:**
- `date` (unique per community)
- `description` -- menu text
- `cap` DECIMAL(12,8) -- cost cap, copied from community at creation. NULL = no cap.
- `closed` / `closed_at` -- locks attendance
- `max` -- attendance cap when closed (NULL until closed)
- `start_time` -- 6pm Sundays, 7pm other days

**Financial methods (all computed from source data, no cached columns):**
- `multiplier` -- SUM of meal_residents.multiplier + guests.multiplier
- `total_cost` -- SQL SUM of bill amounts (excludes no_cost bills)
- `effective_total_cost` -- min(total_cost, max_cost) when capped
- `unit_cost` -- effective_total_cost / multiplier
- `max_cost` -- cap * multiplier (nil if uncapped)
- `collected` -- unit_cost * multiplier
- `subsidized?` -- true when total_cost exceeds max_cost
- `capped?` / `reconciled?`

**Scopes:**
- `unreconciled` -- reconciliation_id IS NULL

---

### MealResident

Join record: a resident attending a meal.

```
MealResident ----> Meal
MealResident ----> Resident
MealResident ----> Community
```

**Key fields:**
- `multiplier` -- copied from resident at signup time (snapshot)
- `late` -- arrived late
- `vegetarian`

**Financial methods:**
- `cost` -- meal.unit_cost * multiplier

**Attendance rules:**
- Can join open meals freely
- Can join closed meals if max is set and spots remain
- Cannot join closed meals if max is not set or is full
- Can only be removed from closed meals if signed up after close

---

### Guest

A non-resident visitor brought by a resident.

```
Guest ----> Meal
Guest ----> Resident (the host)
```

**Key fields:**
- `name`
- `multiplier` -- 2=adult, 1=child
- `late` / `vegetarian`

**Financial methods:**
- `cost` -- meal.unit_cost * multiplier (charged to the hosting resident)

---

### Reconciliation

A billing period. When created, all unreconciled meals with bills are assigned to it.

```
Reconciliation ----> Community
Reconciliation ----< Meal
                      |
                      +----< Bill ---> Resident (cooks)
```

**Key fields:**
- `date` -- when the reconciliation was created

**Behavior:**
- `assign_meals` (after_commit on create) -- assigns all unreconciled meals with bills
- `settlement_balances` -- computes per-resident balances rounded to cents using banker's rounding (ROUND_HALF_EVEN)
- Once a meal is reconciled, its bills cannot be modified

---

### ResidentBalance

Cached balance for a resident. Refreshed daily by `rake billing:recalculate`.

```
ResidentBalance ----> Resident (one-to-one)
```

**Key fields:**
- `amount` DECIMAL(12,8) -- the resident's current balance

This is a **materialized cache**, not a source of truth. It can be rebuilt at any time from bills + meal_residents + guests records.

---

## Scheduling Models

### Rotation

Groups ~12 meals together for cooking duty assignment.

```
Rotation ----> Community
Rotation ----< Meal
```

**Key fields:**
- `description` -- auto-generated date range ("2026-01-05 to 2026-02-16")
- `color` -- one of 5 colors, cycling
- `start_date` -- date of first meal
- `place_value` -- ordering position
- `residents_notified` -- flag for email notification

Rotations and Reconciliations are **fully decoupled**. A rotation is about cooking schedules. A reconciliation is about billing periods.

---

## Calendar Models

### Event

A community calendar event (meetings, anniversaries, etc.).

```
Event ----> Community
```

**Key fields:** `title`, `description`, `start_date`, `end_date`, `allday`

### GuestRoomReservation

A guest room booking. One per date per community.

```
GuestRoomReservation ----> Community
GuestRoomReservation ----> Resident
```

**Key fields:** `date` (unique per community)

### CommonHouseReservation

A common area booking. Validates no overlapping reservations.

```
CommonHouseReservation ----> Community
CommonHouseReservation ----> Resident
```

**Key fields:** `title`, `start_date`, `end_date`

---

## Authentication

### Key

Polymorphic API token for authentication. Associated with Resident or AdminUser.

```
Key ----> identity (polymorphic: Resident or AdminUser)
```

**Key fields:** `token` (auto-generated via `has_secure_token`)

### AdminUser

Devise-authenticated admin account for the ActiveAdmin interface.

```
AdminUser ----> Community
```

**Key fields:** `email`, `superuser` (elevated permissions)

---

## The Multiplier System

The multiplier is the core unit for proportional cost splitting:

```
Adult resident:  multiplier = 2
Child resident:  multiplier = 1
Adult guest:     multiplier = 2
Child guest:     multiplier = 1
```

A meal's total multiplier is the sum across all attendees and guests. Cost per multiplier unit = total_cost / total_multiplier. An adult pays 2x what a child pays.

Example: $60 meal, 3 adults + 1 child attending:
```
total_multiplier = 2 + 2 + 2 + 1 = 7
unit_cost = $60 / 7 = $8.57142857...
adult charge = $8.57142857 * 2 = $17.14285714...
child charge = $8.57142857 * 1 = $8.57142857...
```

Full precision is maintained during the billing period. At reconciliation, balances are rounded to cents using banker's rounding.

---

## Derived vs. Stored Data

All financial values (costs, balances, counts) are **computed from source data** — there are no cached counter columns. The only materialized cache is `resident_balances.amount`, refreshed daily by `rake billing:recalculate`. It can be rebuilt from scratch at any time.
