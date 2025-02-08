import React, { useState, useEffect } from 'react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { Alert, AlertTitle } from '@/components/ui/alert';

const VectorStoreMonitor = () => {
  const [metrics, setMetrics] = useState({
    summary: {},
    history: [],
    alerts: []
  });

  // WebSocket connection for real-time updates
  useEffect(() => {
    const ws = new WebSocket('ws://localhost:8000/ws/metrics');
    
    ws.onmessage = (event) => {
      const data = JSON.parse(event.data);
      if (data.type === 'metrics_update') {
        setMetrics(prev => ({
          ...prev,
          summary: data.data
        }));
      } else if (data.type === 'alerts_update') {
        setMetrics(prev => ({
          ...prev,
          alerts: data.data
        }));
      }
    };

    return () => ws.close();
  }, []);

  return (
    <div className="p-6 space-y-6 bg-gray-50">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-2xl font-bold text-gray-900">Vector Store Monitor</h1>
        <p className="text-gray-600">Real-time system monitoring and metrics</p>
      </div>

      {/* System Health Status */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <HealthCard
          title="System Status"
          status={metrics.summary.health_status}
          score={metrics.summary.performance_score}
        />
        <MetricsCard
          title="Operations"
          value={metrics.summary.total_operations}
          subValue={`${metrics.summary.success_rate}% Success Rate`}
        />
        <MetricsCard
          title="Active Transactions"
          value={metrics.summary.active_transactions}
          subValue="Current Load"
        />
      </div>

      {/* Performance Chart */}
      <div className="bg-white p-6 rounded-lg shadow">
        <h2 className="text-lg font-semibold mb-4">Performance Trends</h2>
        <div className="h-64">
          <ResponsiveContainer width="100%" height="100%">
            <LineChart data={metrics.history}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis dataKey="timestamp" />
              <YAxis />
              <Tooltip />
              <Legend />
              <Line 
                type="monotone" 
                dataKey="metrics.success_rate" 
                stroke="#10B981" 
                name="Success Rate" 
              />
              <Line 
                type="monotone" 
                dataKey="metrics.average_latency" 
                stroke="#6366F1" 
                name="Latency" 
              />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </div>

      {/* Alerts Section */}
      <div className="space-y-4">
        <h2 className="text-lg font-semibold">Recent Alerts</h2>
        {metrics.alerts.map((alert, index) => (
          <Alert 
            key={index}
            variant={alert.level.toLowerCase() === 'critical' ? 'destructive' : 'default'}
          >
            <AlertTitle className="flex justify-between">
              <span>{alert.message}</span>
              <span className="text-sm text-gray-500">
                {new Date(alert.timestamp).toLocaleTimeString()}
              </span>
            </AlertTitle>
          </Alert>
        ))}
      </div>
    </div>
  );
};

const HealthCard = ({ title, status, score }) => (
  <div className="p-6 bg-white rounded-lg shadow">
    <h3 className="text-lg font-medium mb-2">{title}</h3>
    <div className="flex justify-between items-center">
      <span className={`px-3 py-1 rounded-full text-sm ${
        status === 'healthy' ? 'bg-green-100 text-green-800' :
        status === 'degraded' ? 'bg-yellow-100 text-yellow-800' :
                               'bg-red-100 text-red-800'
      }`}>
        {status}
      </span>
      <span className="text-2xl font-bold">{score}%</span>
    </div>
  </div>
);

const MetricsCard = ({ title, value, subValue }) => (
  <div className="p-6 bg-white rounded-lg shadow">
    <h3 className="text-lg font-medium mb-2">{title}</h3>
    <div className="text-2xl font-bold mb-1">{value}</div>
    <div className="text-sm text-gray-500">{subValue}</div>
  </div>
);

export default VectorStoreMonitor;