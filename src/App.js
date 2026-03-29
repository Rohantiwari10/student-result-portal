import { useState } from "react";
import "./App.css";

const data = {
  EN101: {
    name: "Rohan",
    results: generateResults(75)
  },
  EN102: {
    name: "Amit",
    results: generateResults(65)
  },
  EN103: {
    name: "Neha",
    results: generateResults(85)
  },
  EN104: {
    name: "Priya",
    results: generateResults(78)
  },
  EN105: {
    name: "Karan",
    results: generateResults(70)
  },
  EN106: {
    name: "Anjali",
    results: generateResults(88)
  },
  EN107: {
    name: "Rahul",
    results: generateResults(60)
  },
  EN108: {
    name: "Sneha",
    results: generateResults(82)
  },
  EN109: {
    name: "Vikas",
    results: generateResults(68)
  },
  EN110: {
    name: "Pooja",
    results: generateResults(90)
  }
};

// Function to generate consistent 8 semester data
function generateResults(base) {
  return [
    // Sem 1
    { subject: "Maths I", marks: base + 0, semester: 1 },
    { subject: "C Programming", marks: base + 5, semester: 1 },
    { subject: "Physics", marks: base - 5, semester: 1 },

    // Sem 2
    { subject: "Maths II", marks: base - 2, semester: 2 },
    { subject: "Data Structures", marks: base + 3, semester: 2 },
    { subject: "Electronics", marks: base - 4, semester: 2 },

    // Sem 3
    { subject: "DBMS", marks: base + 6, semester: 3 },
    { subject: "Operating System", marks: base + 4, semester: 3 },
    { subject: "Computer Networks", marks: base + 2, semester: 3 },

    // Sem 4
    { subject: "Software Engineering", marks: base + 5, semester: 4 },
    { subject: "Java Programming", marks: base + 3, semester: 4 },
    { subject: "Microprocessors", marks: base + 1, semester: 4 },

    // Sem 5
    { subject: "Web Development", marks: base + 7, semester: 5 },
    { subject: "Theory of Computation", marks: base - 1, semester: 5 },
    { subject: "Compiler Design", marks: base - 2, semester: 5 },

    // Sem 6
    { subject: "Machine Learning", marks: base + 6, semester: 6 },
    { subject: "Cloud Computing", marks: base + 8, semester: 6 },
    { subject: "Data Mining", marks: base + 2, semester: 6 },

    // Sem 7
    { subject: "Artificial Intelligence", marks: base + 7, semester: 7 },
    { subject: "Big Data", marks: base + 4, semester: 7 },
    { subject: "Cyber Security", marks: base + 5, semester: 7 },

    // Sem 8
    { subject: "Project", marks: base + 10, semester: 8 },
    { subject: "Internship", marks: base + 8, semester: 8 },
    { subject: "Seminar", marks: base + 6, semester: 8 }
  ];
}

function App() {
  const [enrollment, setEnrollment] = useState("");
  const [student, setStudent] = useState(null);
  const [searched, setSearched] = useState(false);

  const handleSearch = () => {
    if (!enrollment.trim()) return;
    setStudent(data[enrollment] || null);
    setSearched(true);
  };

  const handleClear = () => {
    setEnrollment("");
    setStudent(null);
    setSearched(false);
  };

  // Group results by semester
  const groupBySemester = (results) => {
    const grouped = {};
    results.forEach((r) => {
      if (!grouped[r.semester]) grouped[r.semester] = [];
      grouped[r.semester].push(r);
    });
    return grouped;
  };

  return (
    <div className="container">
      <div className="card">
        <h2>🎓 Student Result System</h2>

        <div className="search-box">
          <input
            type="text"
            placeholder="Enter Enrollment No (e.g., EN101)"
            value={enrollment}
            onChange={(e) => setEnrollment(e.target.value.toUpperCase())}
            onKeyDown={(e) => e.key === "Enter" && handleSearch()}
          />

          <button onClick={handleSearch}>Search</button>
          <button onClick={handleClear} style={{ background: "#ccc", color: "#000" }}>
            Clear
          </button>
        </div>

        {/* Result Found */}
        {student && (
          <div className="result">
            <h3>{student.name}</h3>

            {/* Percentage */}
            <p>
              Percentage:{" "}
              {(
                student.results.reduce((acc, r) => acc + r.marks, 0) /
                student.results.length
              ).toFixed(2)}
              %
            </p>

            {/* Semester-wise display */}
            {Object.entries(groupBySemester(student.results))
              .sort((a, b) => a[0] - b[0])
              .map(([sem, subjects]) => (
                <div key={sem}>
                  <h4>Semester {sem}</h4>
                  <table>
                    <thead>
                      <tr>
                        <th>Subject</th>
                        <th>Marks</th>
                      </tr>
                    </thead>
                    <tbody>
                      {subjects.map((r, i) => (
                        <tr key={i}>
                          <td>{r.subject}</td>
                          <td>{r.marks}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              ))}
          </div>
        )}

        {/* No Result */}
        {!student && searched && (
          <p className="no-result">❌ No result found. Please check Enrollment No.</p>
        )}
      </div>
    </div>
  );
}

export default App;