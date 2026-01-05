# Firebase Integration Guide - Doctor Pages

## Overview
This guide explains how the Doctor pages connect to Firebase, matching the web app structure in the `src` folder.

## Firebase Collections Used

### 1. **doctors** Collection
- **Structure**: Matches web app `doctors` collection
- **Key Fields**:
  - `uid`: Firebase Auth UID (used to link doctor to authentication)
  - `name`: Doctor's full name
  - `specialization`: Medical specialization
  - `department`: Department name
  - `phone`: Contact phone
  - `email`: Contact email
  - `stats`: Statistics object (activePatients, appointmentsToday, pendingLabTests)
  - `workSchedule`: Work schedule object
- **Query Method**: Query by `uid` field (not document ID)
- **Usage**: `FirebaseServices.getDoctorProfile()` queries `doctors` collection where `uid == currentUserId`

### 2. **patients** Collection
- **Structure**: Matches web app `patients` collection
- **Key Fields**:
  - `assignedDoctorId`: Doctor's UID (links to `doctors.uid`)
  - `assignedNurseId`: Nurse's UID
  - `name`: Patient name
  - `dob`: Date of birth
  - `status`: Patient status ('active', 'inactive')
  - `webData.diagnosis`: Diagnosis information
- **Query Method**: Filter by `assignedDoctorId` field
- **Usage**: `FirebaseServices.getDoctorPatients()` queries `patients` collection where `assignedDoctorId == doctorUid`

### 3. **mobile_lab_test_requests** Collection
- **Structure**: Mobile-specific collection for lab test requests
- **Key Fields**:
  - `doctorId`: Doctor's UID (should match `doctors.uid`)
  - `patientId`: Patient document ID
  - `patientName`: Patient name
  - `testType`: Type of test
  - `test`: Specific test name
  - `urgency`: Urgency level
  - `status`: Request status ('pending', 'completed')
  - `createdAt`: Timestamp
- **Query Method**: Filter by `doctorId` and `status`
- **Usage**: `FirebaseServices.getDoctorPendingLabRequests()` queries where `doctorId == doctorUid` and `status == 'pending'`

### 4. **mobile_lab_results** Collection
- **Structure**: Mobile-specific collection for lab results
- **Key Fields**:
  - `patientId`: Patient document ID
  - `requestId`: Related lab test request ID
  - `results`: Test results object
  - `doctorNotes`: Notes added by doctor
  - `notesAddedBy`: Doctor UID who added notes
  - `createdAt`: Timestamp
- **Query Method**: Filter by patient or doctor
- **Usage**: `FirebaseServices.addDoctorNotesToLabResult()` updates document with doctor notes

### 5. **mobile_medical_records** Collection
- **Structure**: Mobile-specific collection for medical records
- **Key Fields**:
  - `doctorId`: Doctor's UID
  - `patientId`: Patient document ID
  - `category`: Record category
  - `description`: Record description
  - `createdAt`: Timestamp
- **Query Method**: Filter by `doctorId`
- **Usage**: `FirebaseServices.getDoctorMedicalRecords()` queries where `doctorId == doctorUid`

### 6. **mobile_prescriptions** Collection
- **Structure**: Mobile-specific collection for prescriptions
- **Key Fields**:
  - `doctorId`: Doctor's UID
  - `patientId`: Patient document ID
  - `medicationName`: Medication name
  - `dosage`: Dosage information
  - `status`: Prescription status
  - `createdAt`: Timestamp
- **Query Method**: Filter by `doctorId` and date range
- **Usage**: `FirebaseServices.getDoctorDashboardStats()` counts recent prescriptions

### 7. **mobile_override_requests** Collection
- **Structure**: Mobile-specific collection for override requests
- **Key Fields**:
  - `doctorId`: Doctor's UID (target doctor)
  - `nurseId`: Nurse's UID (requesting nurse)
  - `patientId`: Patient document ID
  - `medicationName`: Medication name
  - `currentDosage`: Current dosage
  - `requestedDosage`: Requested dosage
  - `reason`: Reason for override
  - `status`: Request status ('pending', 'approved', 'rejected')
  - `createdAt`: Timestamp
- **Query Method**: Filter by `doctorId` and `status`
- **Usage**: `FirebaseServices.getDoctorPendingOverrideRequests()` queries where `doctorId == doctorUid` and `status == 'pending'`

### 8. **medications** Collection
- **Structure**: Medication catalog
- **Key Fields**:
  - `name`: Medication name
  - `dosage`: Dosage information
  - `category`: Medication category
- **Query Method**: Get all medications
- **Usage**: `FirebaseServices.getAllMedications()` retrieves medication catalog

### 9. **mobile_medication_orders** Collection
- **Structure**: Mobile-specific collection for medication orders
- **Key Fields**:
  - `doctorId`: Doctor's UID
  - `medicationId`: Medication document ID
  - `medicationName`: Medication name
  - `status`: Order status
  - `createdAt`: Timestamp
- **Query Method**: Filter by `doctorId`
- **Usage**: `FirebaseServices.createMedicationOrder()` creates new order

## Important Field Mappings

### Doctor Identification
- **Firebase Auth UID**: Used for authentication (`currentUserId`)
- **doctors.uid**: Should match Firebase Auth UID
- **patients.assignedDoctorId**: Should match `doctors.uid` (not document ID)
- **mobile_*.doctorId**: Should match `doctors.uid` (not document ID)

### Patient Identification
- **patients.id**: Document ID (used in mobile collections)
- **patients.assignedDoctorId**: Doctor's UID (links to `doctors.uid`)

## Page-Specific Integration

### home.dart
- **Dashboard Stats**: Uses `getDoctorDashboardStats()` which queries:
  - `patients` collection (count by `assignedDoctorId`)
  - `mobile_lab_test_requests` collection (count pending by `doctorId`)
  - `mobile_prescriptions` collection (count recent by `doctorId`)
- **Override Requests Count**: Uses `getDoctorPendingOverrideRequests()`

### doctor_detail.dart
- **Doctor Profile**: Uses `getDoctorProfile()` which queries `doctors` collection by `uid`
- **Fallback**: If doctor profile not found, falls back to `users` collection

### patient_list.dart
- **Patient List**: Uses `getDoctorPatients()` which queries `patients` collection by `assignedDoctorId`

### lab_test_request.dart
- **Patient List**: Uses `getDoctorPatients()` for dropdown
- **Pending Requests**: Uses `getDoctorPendingLabRequests()`
- **Create Request**: Uses `createLabTestRequest()` which adds to `mobile_lab_test_requests` collection

### lab_results_review.dart
- **Lab Results**: TODO - Add method to query `mobile_lab_results` by doctor
- **Add Notes**: Uses `addDoctorNotesToLabResult()` which updates `mobile_lab_results` document

### medical_records.dart
- **Medical Records**: Uses `getDoctorMedicalRecords()` which queries `mobile_medical_records` collection by `doctorId`

### medications.dart
- **Medication Catalog**: Uses `getAllMedications()` which queries `medications` collection
- **Create Order**: Uses `createMedicationOrder()` which adds to `mobile_medication_orders` collection

### override_requests.dart
- **Override Requests**: Uses `getDoctorPendingOverrideRequests()` which queries `mobile_override_requests` collection
- **Approve Request**: Uses `approveOverrideRequest()` which updates `mobile_override_requests` document

### incoming_requests.dart
- **Transfer Requests**: TODO - Implement transfer requests collection matching web app structure
- **Web App Structure**: Uses `web_transfers` collection with `assignedDoctorId` field

## Modifying Firebase Integration

### To Change Collection Names
1. Update the collection name in `FirebaseServices` method
2. Update comments in the specific Doctor page
3. Ensure field names match web app structure

### To Add New Fields
1. Update the model class (e.g., `DoctorModel`, `PatientModel`)
2. Update `FirebaseServices` method to include new fields
3. Update the Doctor page to display new fields

### To Change Query Filters
1. Modify the query in `FirebaseServices` method
2. Update comments explaining the query logic
3. Test with actual Firebase data

## Web App Compatibility

All Doctor pages are designed to work with the same Firebase structure as the web app:
- **Same Collections**: Uses same collection names as web app
- **Same Field Names**: Uses same field names (e.g., `assignedDoctorId`, `uid`)
- **Same Data Structure**: Matches web app data structure

## Notes

- All mobile-specific collections use `mobile_` prefix
- All web-specific collections use `web_` prefix
- Doctor UID is used consistently across all collections (not document ID)
- Patient document ID is used in mobile collections (not UID)

