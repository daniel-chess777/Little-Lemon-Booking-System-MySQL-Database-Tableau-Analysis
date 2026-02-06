
# Little Lemon Database (MySQL) — Auto-generated package

## Contents
- `little_lemon_schema.sql` — Schema, views, triggers, and stored procedures.
- `little_lemon_load.sql` — CSV bulk-load script (uses LOCAL INFILE).
- `countries.csv`, `customers.csv`, `orders.csv`, `courses.csv`, `cuisines.csv`, `starters.csv`, `desserts.csv`, `drinks.csv`, `sides.csv`, `order_menu.csv`, `bookings.csv` — normalized extracts from `LittleLemon_data.xlsx`.
- `er_diagram.png` — ER diagram.
- `db_client.py` — Python client example (calls `GetMaxQuantity` and `ManageBooking`).
- `change_watcher.py` — Polls `change_log` to react to changes on `bookings`.

## How to run
1. Create database & objects:
   ```sql
   SOURCE little_lemon_schema.sql;
   ```
2. Load data (place all CSVs in the same folder and enable `--local-infile`):
   ```sql
   SOURCE little_lemon_load.sql;
   ```
3. Test stored procedures:
   ```sql
   CALL GetMaxQuantity(@maxq); SELECT @maxq;
   SET @bid=0; CALL ManageBooking('54-366-6861','2020-06-15',2,10,'Confirmed',@bid); SELECT @bid;
   CALL UpdateBooking(@bid,NULL,3,NULL,'Completed');
   CALL CancelBooking(@bid);
   ```
4. Python (requires `pip install mysql-connector-python`):
   ```bash
   python db_client.py
   python change_watcher.py
   ```

## Tableau
Use the built-in views for quick dashboards:
- `vw_sales_by_country`
- `vw_menu_popularity`
- `vw_monthly_trends`

