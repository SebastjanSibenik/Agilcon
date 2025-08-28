# Agilcon Technical Homework

## Project Overview

This project is part of the Agilcon 2025 technical homework assignment.

The homework focused on building a Salesforce application for managing students, exam dates, registrations, and subjects.
Key tasks included:

1. **Custom Object Creation**: Designing Salesforce custom objects for Student, Exam Date, Subject, and Exam Registration, along with associated fields to capture all necessary information.

2. **LWC Component for Student Entry**: Creating a Lightning Web Component to enter student information, including first name, last name, EMSO (unique identifier), and study type (full-time/part-time). Conditional fields, such as a payer checkbox for part-time students, were also implemented.

3. **EMSO Validation**: Implementing server-side validation for EMSO using an API call to a web service. The component displays success or error messages based on the validation result.

4. **LWC Component for Exam Registration Management**: Developing a component to display all students registered for a specific exam, with functionality to unregister individual students directly from the component. This component was added to the standard Exam Date page layout.

5. **Optional Apex Validation**: As an additional challenge, a custom Apex function was implemented to validate EMSO without relying on the external API.

## Authentication

Pre-configured Salesforce account:

| Username                    | Password        |
| --------------------------- | --------------- |
| sebsibagilcontest@gmail.com | AgilconTest2025 |

# Salesforce User Guide

When you log in to your Salesforce account using the provided credentials, please navigate to the **Home** page.

## Home Page Forms

On the Home page, you will find **three forms**:

### 1) Vnos Študenta Form

This form is used to enter a new student’s details, including **Name (ime)**, **Surname (priimek)**, **EMSO**, and **Type of Study (tip študija)**. All fields are required.

- **Save (shrani):** Validates the EMSO using a custom method. If correct, the student record is saved in the Salesforce **Students** object.
- **Reset (počisti):** Clears all input fields.
- **Note:** If a student with the same EMSO already exists, the system will prevent the record from being inserted.

### 2) Prijava na Izpitni Rok Form

This optional form is primarily for testing purposes. You can select a **Student (študent)** and a predefined **Exam Date (izpitni rok)**. This creates a new exam registration, visible on the **Exam Date** page.

- Only **open exam dates** are available for registration.
- Duplicate registrations are **not allowed** and will fail.

### 3) Vsi Izpitni Roki Form

This form displays links to all registered exam dates. Clicking on an exam date redirects you to its specific page, where you can:

- View all registered students (**Prijavljeni Študent**)
- Unsubscribe students from the exam (**Odjava**)

## Navigation Menu

In addition to the **Home** tab, the navigation menu includes several custom tabs:

- **Students:** Displays the students page (**študent**) and all associated fields
- **Subjects:** Displays the subjects page (**predmeti**) and all associated fields
- **Instructors:** Displays the instructors page (**profesorji**) and all associated fields
- **Exam Dates:** Displays the exam dates page (**izpitni rok**) and all associated fields
- **Exam Registrations:** Displays the exam registration page (**prijave na izpitni rok**) and all associated fields

## Salesforce Custom Objects Overview

---

### Exam Date

Represents the date and time of an exam.

| Field Name       | API Name         | Type                   | Required | Description                                             |
| ---------------- | ---------------- | ---------------------- | -------- | ------------------------------------------------------- |
| Exam Name        | Name             | Text(80)               | ✅       | Name of the exam                                        |
| Date Time        | Date_Time\_\_c   | Date/Time              | ✅       | Date and time of the exam                               |
| Subject          | Subject\_\_c     | Lookup(Subject)        | ✅       | Associated subject                                      |
| Status           | Status\_\_c      | Picklist(Open, Closed) |          | Indicates if the exam date accepts registrations or not |
| Owner            | OwnerId          | Lookup(User,Group)     | ✅       | Record owner                                            |
| Created By       | CreatedById      | Lookup(User)           |          | User who created the record                             |
| Last Modified By | LastModifiedById | Lookup(User)           |          | User who last modified the record                       |

---

### Exam Registration

Represents a student's registration for a specific exam.

| Field Name             | API Name         | Type               | Required | Description                       |
| ---------------------- | ---------------- | ------------------ | -------- | --------------------------------- |
| Exam Registration Name | Name             | Text(80)           | ✅       | Name of the registration record   |
| Student                | Student\_\_c     | Lookup(Student)    | ✅       | Associated student                |
| Exam Date              | Exam_Date\_\_c   | Lookup(Exam Date)  | ✅       | Associated exam date              |
| Subject                | Subject\_\_c     | Lookup(Subject)    | ✅       | Subject of the exam               |
| Owner                  | OwnerId          | Lookup(User,Group) | ✅       | Record owner                      |
| Created By             | CreatedById      | Lookup(User)       |          | User who created the record       |
| Last Modified By       | LastModifiedById | Lookup(User)       |          | User who last modified the record |

---

### Instructor

Represents an instructor responsible for teaching a subject.

| Field Name       | API Name         | Type                        | Required | Description                       |
| ---------------- | ---------------- | --------------------------- | -------- | --------------------------------- |
| Instructor Name  | Name             | Text(80)                    | ✅       | Name of the instructor            |
| Email            | Email\_\_c       | Email (External ID, Unique) | ✅       | Instructor email address          |
| Subject          | Subject\_\_c     | Lookup(Subject)             |          | Associated subject                |
| Owner            | OwnerId          | Lookup(User,Group)          | ✅       | Record owner                      |
| Created By       | CreatedById      | Lookup(User)                |          | User who created the record       |
| Last Modified By | LastModifiedById | Lookup(User)                |          | User who last modified the record |

---

### Student

Represents a student enrolled in the system.

| Field Name       | API Name         | Type                           | Required | Description                       |
| ---------------- | ---------------- | ------------------------------ | -------- | --------------------------------- |
| Student Name     | Name             | Text(80)                       | ✅       | Name of the student               |
| EMSO             | EMSO\_\_c        | Text(13) (External ID, Unique) | ✅       | Unique student identifier         |
| Is_Payer         | Is_Payer\_\_c    | Checkbox                       |          | Indicates if student has a payer  |
| Owner            | OwnerId          | Lookup(User,Group)             | ✅       | Record owner                      |
| Study Type       | Study_Type\_\_c  | Picklist                       | ✅       | Type of study                     |
| Created By       | CreatedById      | Lookup(User)                   |          | User who created the record       |
| Last Modified By | LastModifiedById | Lookup(User)                   |          | User who last modified the record |

---

### Subject

Represents an academic subject or course.

| Field Name       | API Name          | Type                           | Required | Description                         |
| ---------------- | ----------------- | ------------------------------ | -------- | ----------------------------------- |
| Subject Name     | Name              | Text(80)                       | ✅       | Name of the subject                 |
| Subject Code     | Subject_Code\_\_c | Text(20) (External ID, Unique) | ✅       | Unique subject code                 |
| Description      | Description\_\_c  | Text Area(255)                 | ✅       | Subject description                 |
| Owner            | OwnerId           | Lookup(User,Group)             | ✅       | Record owner                        |
| Created By       | CreatedById       | Lookup(User)                   |          | User who created the record         |
| Last Modified By | LastModifiedById  | Lookup(User)                   |          | User who last modified the record   |
| Instructor       | Instructor\_\_c   | Lookup(Instructor)             | ✅       | Instructor in charge of the subject |

---

## Support

For assistance, contact:

**Sebastjan Šibenik**  
Email: sebastjan.sibenik@gmail.com  
Phone: +386 40 172 326
