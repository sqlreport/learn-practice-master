import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'
import Home from './components/Home'
import UserList from './components/UserList'
import Navigation from './components/Navigation'

function App() {
  return (
    <Router>
      <div className="min-h-screen bg-gray-100">
        <Navigation />
        <main className="container mx-auto px-4 py-8">
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/users" element={<UserList />} />
          </Routes>
        </main>
      </div>
    </Router>
  )
}

export default App