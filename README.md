# 🎓 Student Result Portal

A simple React-based web application that allows students to view their academic results using their enrollment number. The system demonstrates relational database design concepts and displays semester-wise performance in a structured format.

---

## 🚀 Features

* 🔍 Enrollment number based result lookup
* 📊 Semester-wise result display
* 📈 Automatic percentage calculation
* ⚠️ Input validation with user-friendly messages
* 🎨 Clean and responsive UI

---

## 🧠 Concept

This project is based on **relational database design** using three main tables:

* **Students** – stores student details
* **Subjects** – mapped with course and semester
* **Marks** – links students with subjects

The system uses **SQL JOIN operations** to retrieve and display results efficiently.

---

## 🛠️ Tech Stack

* React.js
* JavaScript
* MySQL (Database Design)
* CSS

---

## 📂 Project Structure

```
student-result-portal
│
├── frontend
│   ├── src
│   │   ├── App.js
│   │   ├── App.css
│   │
│   └── package.json
│
└── README.md
```

---

## ⚙️ How It Works

1. User enters enrollment number
2. System fetches student data
3. Results are displayed semester-wise
4. Percentage is calculated dynamically

---

## ⚠️ Note

This project currently uses **mock data on the frontend** for demonstration purposes.
The database schema and SQL queries are designed separately and can be integrated using a backend (e.g., Node.js + Express).

---

## 🚀 Future Improvements

* Backend integration with MySQL
* Admin panel for managing results
* Authentication system
* API-based data fetching

---

## 📌 Conclusion

This project demonstrates how **relational databases and frontend technologies** can be combined to build a real-world academic result system.

---
