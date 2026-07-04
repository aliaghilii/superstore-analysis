## Decision 001 — Move address fields from customers to orders
Date: [today]
Problem: Initial schema assumed city/state/region were stable 
         customer attributes.
Evidence: 780/793 (98.4%) customers appeared with multiple cities.
          Order-level consistency confirmed (0/5,009 inconsistent).
Decision: Move ship_city, ship_state, ship_region, ship_postal_code 
          to orders table.
Alternatives considered: Keep in customers (rejected — data proves 
          it's wrong); separate addresses table (rejected — 
          overengineering for this dataset's needs).

"Verified: no NULLs in columns constrained as NOT NULL by schema 
    (expected, enforced at import time) and in the one nullable column 
    (ship_postal_code). This does NOT cover duplicates, business-rule 
    validity, or logical consistency — deferred to Phase 3."