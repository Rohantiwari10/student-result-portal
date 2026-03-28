import { useState } from "react";
import "./App.css";

const data = {
  EN101: {
    name: "Rohan",
    results: [
      { subject: "Maths", marks: 75, semester: 1 },
      { subject: "C Programming", marks: 80, semester: 1 },

      { subject: "Data Structures", marks: 78, semester: 2 },
      { subject: "Digital Logic", marks: 72, semester: 2 },

      { subject: "DBMS", marks: 85, semester: 3 },
      { subject: "Operating System", marks: 82, semester: 3 }
    ]
  },

  EN102: {
    name: "Amit",
    results: [
      { subject: "Maths", marks: 65, semester: 1 },
      { subject: "C Programming", marks: 70, semester: 1 },

      { subject: "Data Structures", marks: 68, semester: 2 },
      { subject: "Digital Logic", marks: 60, semester: 2 },

      { subject: "DBMS", marks: 72, semester: 3 },
      { subject: "Operating System", marks: 75, semester: 3 }
    ]
  }
};

function App() {
  const [enrollment, setEnrollment] = useState("");
  const [student, setStudent] = useState(null);

  const handleSearch = () => {
    setStudent(data[enrollment] || null);
  };

  // Group by semester
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
            placeholder="Enter Enrollment No (EN101)"
            value={enrollment}
            onChange={(e) => setEnrollment(e.target.value)}
          />
          <button onClick={handleSearch}>View Result</button>
        </div>

        {student ? (
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

            {/* Grouped by semester */}
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
        ) : (
          <p className="no-result">No Result Found</p>
        )}
      </div>
    </div>
  );
}

export default App;