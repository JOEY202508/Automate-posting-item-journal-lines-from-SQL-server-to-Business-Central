# Automate-posting-item-journal-lines-from-SQL-server-to-Business-Central
**1. Project Objective**

Automate the process of posting item journal lines in Dynamics 365 Business Central using data stored in SQL Server and Power Automate Flow.
The solution enables automatic creation and posting of inventory adjustments from SQL into BC, with results written back to SQL for tracking.

**2. System Architecture**
    flowchart LR
    SQL[(SQL: InventoryAdjustments table)] -->|Unprocessed records| PowerAutomate[Power Automate Flow]
    PowerAutomate -->|Create Item Journal Line| BCAPI["BC Custom API (AL Extension)"]
    PowerAutomate -->|Run PostSingleLine Action| BCAPI
    BCAPI -->|Executes Codeunit 'Item Jnl.-Post Batch'| BCDB[(BC Database)]
    BCDB -->|Posting result| PowerAutomate
    PowerAutomate -->|Update Processed=1 & ResultMsg| SQL

**3. AL Extension Development**

File: Page50139_ItemJournalLine.al

Features:
Exposes Item Journal Line API with OData
Automatically assigns Line No.
[ServiceEnabled] procedure PostSingleLine() action for per-line posting

**4. Power Automate Flow Design**
**Flow Steps**
>>>Trigger: Recurrence
Runs on schedule (e.g., every 15 minutes).
>>>Get rows (V2) – SQL Connector
Fetch unprocessed rows (Processed = 0) from InventoryAdjustments.
>>>Apply to each – Loop
Create record (V3) → Insert Item Journal Line into BC
Run action (V3) → Execute itemJournalLine-postSingleLine action
Update row (V2) → Mark SQL row as Processed=1, store BCId and result message

  **Key Notes:**
  Do not send Line No. (the AL extension is assigned automatically).
  Ensure Entry Type matches BC internal enum values (e.g., Purchase, Positive_x0020_Adjmt_x002E_).
  Use the returned ID (SystemId) from the Create record step for posting.

**5. Validation of Posting**

After the Flow posts Item Journal Lines via the custom API, you can verify the results in Business Central:

1. **Item Ledger Entries**  
   - Navigate: *Search → "Item Ledger Entries"*  
   - Check that the correct Item No., Location, Entry Type, Quantity, and Document No. were posted.

2. **Item Availability by Location**  
   - Navigate: *Item Card → Related → Availability → By Location*  
   - Confirm that on-hand inventory has been updated as expected.

3. **Optional Cross-Checks**  
   - Review **Value Entries** (costing impact).  
   - Review **General Ledger Entries** (if integrated with G/L).

This ensures the end-to-end flow (SQL → Power Automate → BC API → Posting) has successfully updated inventory balances.
<img width="1363" height="371" alt="{2A70760F-1065-4BA2-85C2-61023B0AF89E}" src="https://github.com/user-attachments/assets/968d0917-8d8f-4960-bbc2-39ff790c3646" />
<img width="618" height="792" alt="{AC75B07E-039A-460C-9AF3-7ABC38D2C313}" src="https://github.com/user-attachments/assets/6aa9c001-7798-4500-a0fb-a9c6cd5b8f07" />
<img width="1638" height="593" alt="{44CD6134-82C8-4F2F-A3B5-4797D9F594E3}" src="https://github.com/user-attachments/assets/8b34cf15-e313-4e03-b056-d6cbc2759b54" />

