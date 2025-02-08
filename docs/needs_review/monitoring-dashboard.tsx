import React, { useState, useEffect } from 'react';
import { LineChart, Line, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert';

const ReclamationDashboard = () => {
  const [metrics, setMetrics] = useState({
    services: {},
    alerts: [],
    recentRequests: []
  });

  // Simulated data for demonstration
  useEffect(() => {
    const demoData = {
      services: {
        'Broker A': {
          status: 'healthy',
          success_rate: 0.95,
          avg_response_time: 45.2,
          common_errors: {
            'API Timeout': 3,
            'Rate Limited': 1
          }
        },
        'Broker B': {
          status: 'degraded',
          success_rate: 0.72,
          avg_response_time: 312.5,
          common_errors: {
            'Authentication Failed': 8,
            'Server Error': 4
          }
        }
      },
      alerts: [
        { service: 'Broker B', message: 'High failure rate: 28%', severity: 'error' },
        { service: 'Broker B', message: 'Slow response time: 312.5s', severity: 'warning' }
      ],
      recentRequests: Array.from({ length: 24 }, (_, i) => ({
        hour: i,
        success: Math.floor(Math.random() * 50),
        failure: Math.floor(Math.random() * 10)
      }))
    };
    
    setMetrics(demoData);
  }, []);

  return (
    <div className="p-6 space-y-6 bg-gray-50">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-2xl font-bold text-gray-900">Data Reclamation Monitor</h1>
        <p className="text-gray-600">Real-time monitoring of data deletion requests</p>
      </div>

      {/* Alerts Section */}
      <div className="space-y-4">
        <h2 className="text-xl font-semibold text-gray-800">Active Alerts</h2>
        {metrics.alerts.map((alert, index) => (
          <Alert key={index} variant={alert.severity === 'error' ? 'destructive' : 'default'}>
            <AlertTitle>{alert.service}</AlertTitle>
            <AlertDescription>{alert.message}</AlertDescription>
          </Alert>
        ))}
      </div>

      {/* Service Health Overview */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {Object.entries(metrics.services).map(([name, data]) => (
          <div key={name} className="p-4 bg-white rounded-lg shadow">
            <div className="flex justify-between items-center mb-4">
              <h3 className="text-lg font-medium">{name}</h3>
              <span className={`px-3 py-1 rounded-full text-sm ${
                data.status === 'healthy' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
              }`}>
                {data.status}
              </span>
            </div>
            <div className="space-y-2">
              <div className="flex justify-between">
                <span className="text-gray-600">Success Rate</span>
                <span className="font-medium">{(data.success_rate * 100).toFixed(1)}%</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-600">Avg Response Time</span>
                <span className="font-medium">{data.avg_response_time.toFixed(1)}s</span>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Request Trends Chart */}
      <div className="h-96 bg-white p-4 rounded-lg shadow">
        <h2 className="text-xl font-semibold text-gray-800 mb-4">24-Hour Request Trends</h2>
        <ResponsiveContainer width="100%" height="100%">
          <LineChart data={metrics.recentRequests}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="hour" label={{ value: 'Hour', position: 'bottom' }} />
            <YAxis label={{ value: 'Requests', angle: -90, position: 'insideLeft' }} />
            <Tooltip />
            <Legend />
            <Line type="monotone" dataKey="success" stroke="#10B981" name="Successful" />
            <Line type="monotone" dataKey="failure" stroke="#EF4444" name="Failed" />
          </LineChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
};

export default ReclamationDashboard;