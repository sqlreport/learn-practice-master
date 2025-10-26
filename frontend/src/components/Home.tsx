import React from 'react';

const Home: React.FC = () => {
  return (
    <div className="max-w-4xl mx-auto">
      <h1 className="text-4xl font-bold text-gray-800 mb-8">
        Welcome to React Flask App
      </h1>
      
      <div className="grid md:grid-cols-2 gap-8">
        <div className="bg-white rounded-lg shadow-md p-6">
          <h2 className="text-2xl font-semibold text-gray-700 mb-4">
            Frontend Technologies
          </h2>
          <ul className="space-y-2 text-gray-600">
            <li>• React 18 with TypeScript</li>
            <li>• Vite for fast development</li>
            <li>• Tailwind CSS for styling</li>
            <li>• React Router for navigation</li>
            <li>• Axios for API calls</li>
          </ul>
        </div>

        <div className="bg-white rounded-lg shadow-md p-6">
          <h2 className="text-2xl font-semibold text-gray-700 mb-4">
            Backend Technologies
          </h2>
          <ul className="space-y-2 text-gray-600">
            <li>• Flask with SQLAlchemy</li>
            <li>• PostgreSQL database</li>
            <li>• JWT authentication</li>
            <li>• RESTful API design</li>
            <li>• Docker containerization</li>
          </ul>
        </div>
      </div>

      <div className="mt-8 bg-blue-50 rounded-lg p-6">
        <h2 className="text-2xl font-semibold text-blue-800 mb-4">
          Architecture Overview
        </h2>
        <p className="text-blue-700">
          This application demonstrates a modern full-stack architecture with a React TypeScript 
          frontend, Flask backend, PostgreSQL database, all served through nginx in a single 
          Docker container. The setup provides a production-ready foundation for scalable web applications.
        </p>
      </div>
    </div>
  );
};

export default Home;