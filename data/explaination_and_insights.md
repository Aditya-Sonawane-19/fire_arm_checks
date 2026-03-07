# NICS Firearm Background Checks — Data Explanation

## Dataset Overview

This dataset is sourced from the FBI's **National Instant Criminal Background Check System (NICS)**
and was compiled and made publicly available by **BuzzFeed News** via their GitHub repository:
[link](https://github.com/BuzzFeedNews/nics-firearm-background-checks).

The dataset spans **November 1998 to the September 2023**, with one row per state/territory per month.
The unit of observation is a **background check transaction**, not a firearm sold.
A single transaction may cover multiple firearms, and multiple checks may relate to a single sale.

> **Important Disclaimers:** (from the nics-checks-archive.pdf)
> It is important to note that the statistics within this chart represent the number of firearm background checks initiated through the NICS.
> They do **not** represent the number of firearms sold.
> Based on varying state laws and purchase scenarios,
> a one-to-one correlation cannot be made between a firearm background check and a firearm sale.
>
> Some states may reflect lower than expected numbers for handgun checks
> based on varying state laws pertaining to handgun permits.
> Since the permit check is done in place of the NICS check in most of the affected states,
> the low handgun statistics are often balanced out by a higher number of handgun permit checks.

> **Important Disclaimers:** (from the the README of the data)
> Kentucky is a well-known outlier — it runs monthly rechecks on all active concealed carry holders,
> producing extremely large permit numbers.

---

### Permit-Related Fields

| Field | Description |
|---|---|
| `permit` | Number of checks run for permit applications. Many states require a permit or licence to purchase or carry a firearm. Some states use this permit check **in place of** a point-of-sale NICS check, which is why some states show very low handgun or long gun sale numbers but very high permit numbers. |
| `permitrecheck` | Number of checks run on individuals who already hold a permit, as a periodic renewal or recheck of their eligibility status. |

---

### Transaction Type Fields — Standard Sales

*Point-of-sale checks where a firearm is being transferred from a dealer.*

| Field | Description |
|---|---|
| `handgun` | Checks for the sale/transfer of a handgun (pistol or revolver). |
| `longgun` | Checks for the sale/transfer of a long gun (rifle or shotgun). |
| `other` | Checks for the sale/transfer of a firearm that is neither a handgun nor a long gun. This includes frames and receivers, firearms with a pistol grip that expel a shotgun shell, National Firearms Act (NFA) items such as suppressors/silencers, and other non-standard firearms. |
| `multiple` | Checks where multiple firearm types were selected on a single transaction (e.g., a handgun and a long gun purchased together). Individual firearm types are not broken out separately for these checks. |
| `admin` | Administrative checks. Not connected to a firearm transfer; run for law enforcement, licensing, or other administrative purposes. |

---

### Transaction Type Fields — Pre-Pawn

*Checks run before accepting a firearm as collateral for a pawn loan.*

| Field | Description |
|---|---|
| `prepawnhandgun` | Background check on a person pawning a handgun before a pawnbroker accepts it as security for a loan. |
| `prepawnlonggun` | Background check on a person pawning a long gun. |
| `prepawnother` | Background check on a person pawning an "other" type firearm. |

---

### Transaction Type Fields — Redemption

*Checks run when the owner retrieves a previously pawned firearm.*

| Field | Description |
|---|---|
| `redemptionhandgun` | Check run when a person redeems (retrieves) a previously pawned handgun from a pawnbroker. |
| `redemptionlonggun` | Check run when a person redeems a previously pawned long gun. |
| `redemptionother` | Check run when a person redeems a previously pawned "other" type firearm. |

---

### Transaction Type Fields — Returned / Returned Disposition

*Checks on firearms being returned after a denied or delayed sale.*

| Field | Description |
|---|---|
| `returnedhandgun` | Check on a handgun being returned to the seller after a transaction was denied or a background check came back unfavourable. |
| `returnedlonggun` | Check on a long gun being returned. |
| `returnedother` | Check on an "other" type firearm being returned. |

---

### Transaction Type Fields — Rentals

*Checks on firearms being rented, e.g., at a shooting range.*

| Field | Description |
|---|---|
| `rentalshandgun` | Background check on a person renting a handgun (e.g., at a shooting range). |
| `rentalslonggun` | Background check on a person renting a long gun. |

---

### Transaction Type Fields — Private Sale

*In some states, private-party transfers must go through a licensed dealer and therefore trigger a NICS check.*

| Field | Description |
|---|---|
| `privatesalehandgun` | Check for the private-party transfer of a handgun routed through a licensed dealer. |
| `privatesalelonggun` | Check for the private-party transfer of a long gun. |
| `privatesaleother` | Check for the private-party transfer of an "other" type firearm. |

---

### Transaction Type Fields — Return to Seller (Private Sale)

*Checks on firearms returned to a private seller after a failed transfer.*

| Field | Description |
|---|---|
| `returntosellerhandgun` | Check on a handgun being returned to the private seller after a background check denial. |
| `returntosellerlonggun` | Check on a long gun being returned to the private seller. |
| `returntosellerother` | Check on an "other" type firearm being returned to the private seller. |

---

### Summary Field

| Field | Description |
|---|---|
| `totals` | The sum of all check types for that state in that month. This is the headline figure most commonly used for trend analysis, but analysts should be aware it conflates very different transaction types (e.g., Kentucky's permit rechecks inflate its totals enormously). |

---

## POC vs. Non-POC State Classification and Federal Firearms Licenses (FFL)

Cross-state comparisons require caution because states participate in NICS in fundamentally different ways.
The FBI classifies all 56 reporting entities into four participation tiers:

| Type | Count | Mechanism |
|---|---|---|
| **Non-POC** | ~37 states/territories | FFL contacts **FBI directly** for all checks |
| **Full POC** | ~15 states | FFL contacts a **state agency**, which accesses NICS |
| **Partial POC (handgun)** | MD, NH, WI | State handles handguns; FBI handles long guns |
| **Partial POC (permit)** | NE | State permit used for handguns; FBI handles long guns |

In **Full POC** states (e.g., California, Illinois, Florida),
the state intermediary may aggregate or suppress individual check-type detail differently from Non-POC states.
This is a **root cause** of many zero-valued columns and cross-state inconsistencies and must be accounted for in any comparative analysis.

*Sources*:
FBI NICS Participation Map — [link](https://www.fbi.gov/file-repository/cjis/nics-participation-map-020124/view)
Federal Firearms Licenses — [link](https://www.atf.gov/firearms/federal-firearms-licenses)

## Key insights

### 1. Permit Checks ≠ Sales

States like Kentucky, Illinois, and North Carolina conduct large volumes of permit
checks that are **not** point-of-sale transfers.  
This means we should treat `permit` and `permitrecheck`separately from `handgun`, `longgun`, and `other` when estimating sales volumes.
For example, Kentucky routinely records over 150,000–200,000 permit checks per month alongside only ~6,000–14,000 handgun checks,
while Illinois regularly reports 40,000–70,000 permit checks with comparatively modest handgun figures.

### 2. Pre-Pawn and Redemption Reflect Economic Activity

Spikes in `prepawn` checks can indicate financial stress in a population, as people pawn firearms for cash.
The NICS defines pre-pawn checks as those,
"requested by an officially-licensed FFL on prospective firearm transferees seeking to pledge or pawn a firearm as security for the payment or repayment of money"*,
while redemption checks cover individuals
"attempting to regain possession of a firearm after pledging or pawning a firearm as security at a pawn shop."
These are **not** new firearm purchases.

### 3. Missing / Zero Values

Many states report zero for newer transaction categories (e.g., `rentals`, `privatesale`)
because either the activity does not occur in their jurisdiction or their state does not route such transactions through NICS.
The NICS reports define rentals as checks on persons
"attempting to possess a firearm when the firearm is loaned or rented for use off the premises of the business"
and private sales as checks on transfers from "a private party seller who is not an officially-licensed FFL",
categories that are absent in many state reporting pipelines.

### 4. Territories Included

Guam, Puerto Rico, the U.S. Virgin Islands, and the Mariana Islands are included in the dataset alongside the 50 states and D.C.
