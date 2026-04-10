# Alumni Portal Registration (SAP BTP ABAP RAP)

A modern, full-stack enterprise application built using the **SAP ABAP RESTful Application Programming Model (RAP)** on SAP BTP. This project manages the lifecycle of alumni registrations, from initial pending status through approval, review, or rejection.

---

## 🚀 Key Features

* **Managed & Unmanaged Hybrid Approach:** Utilizes a custom save sequence and utility buffer classes to handle complex data persistence.
* **Draft Capability:** Supports "Work-in-Progress" states, allowing users to leave and return to their registration without losing data.
* **Early Numbering:** Implements a custom ID generator (`001`, `002`, etc.) that prevents key collisions in both Draft and Active tables.
* **Dynamic Feature Control:** Action buttons (Approve, Reject, Review, Deactivate) automatically enable or disable based on the current registration status.
* **Cascade Delete:** Custom logic ensures that deleting an Alumnus automatically cleans up all associated "Degrees Earned" records to prevent orphaned "ghost" data.
* **Semantic Formatting:** Enhanced UI display logic to maintain leading zeros in numeric IDs across the Fiori interface.

---

## 🛠️ Technical Stack

* **Backend:** SAP ABAP (Cloud Optimized)
* **Framework:** ABAP RESTful Application Programming Model (RAP)
* **UI:** SAP Fiori Elements (OData V4)
* **Data Modeling:** Core Data Services (CDS) with Metadata Extensions (.ddlx)
* **Database:** SAP HANA

---

## 📂 Project Structure

* `ZI_AlumniRegistration`: Base Data Definition (Header)
* `ZI_AlumniDegrees`: Base Data Definition (Items)
* `ZC_AlumniRegistration`: Consumption Projection View
* `ZBP_ALUMNI_HEADER`: Behavior Implementation Class (Actions, Early Numbering, Feature Control)
* `ZCL_ALUMNI_UTILITY`: Utility Class for Database Buffering and ID Generation

---

## 📊 Business Logic & Status Lifecycle

The system follows a strict status flow to ensure data integrity and visual clarity:

| Status | Criticality | Color | Description |
| :--- | :--- | :--- | :--- |
| **Pending** | 2 | Orange | Default state for new registrations. |
| **Active** | 3 | Green | Verified and approved alumni. |
| **Review** | 2 | Orange | Flagged for manual background check. |
| **Rejected** | 1 | Red | Application does not meet criteria. |
| **Inactive** | 1 | Red | Alumni who have opted out or are no longer active. |

---

## 🎨 UI/UX Highlights

* **List Report Tabs:** Custom Selection Variants for quick filtering between Active, Pending, and Rejected records.
* **Object Page Header:** Displays high-level **KPI Badges** for Graduation Year and Registration Status.
* **Custom KPI Cards:** Integrated dashboard-style cards showing live counts of alumni statuses.
* **Semantic Colors:** Uses Criticality Annotations to visually represent status via standard Fiori semantic colors.

---

## 🔨 Installation & Deployment

1.  Clone this repository into your **ABAP Development Tools (ADT)**.
2.  Activate all **Data Definitions**, **Metadata Extensions**, and **Behavior Definitions**.
3.  Activate the **Behavior Implementation Classes**.
4.  Publish the **Service Definition** and **Service Binding** (OData V4 - UI).
5.  Launch via the Fiori Elements Preview.

---


