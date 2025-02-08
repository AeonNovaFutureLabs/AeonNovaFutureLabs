import React from 'react';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { Activity, Database, Cpu, AlertTriangle } from 'lucide-react';

const SystemMetrics = () => {
  // Sample metrics data
  const performanceData = [
    { time: '00:00', latency: 120, throughput: 1000, errors: 2 },
    { time: '04:00', latency: 125, throughput: 1200, errors: 1 },
    { time: '08:00', latency: 130, throughput: 1400, errors: 3 },
    { time: '12:00', latency: 145, throughput: 1600, errors: 2 },
    { time: '16:00', latency: 160, throughput: 1800, errors: 4 },
    { time: '20:00', latency: 140, throughput: 1500, errors: 2 },
    { time: '24:00', latency: 130, throughput: 1300, errors: 1 },
  ];

  const systemStats = [
    {
      name: 'System Health',
      value: '98.5%',
      icon: Activity,
      description: 'Overall system status',
      color: 'text-green-500'
    },
    {
      name: 'Database Load',
      value: '72%',
      icon: Database,
      description: 'Current DB utilization',
      color: 'text-yellow-500'
    },
    {
      name: 'CPU Usage',
      value: '45%',
      icon: Cpu,
      description: 'Average CPU load',
      color: 'text-blue-500'
    },
    {
      name: 'Error Rate',
      value: '0.02%',
      icon: AlertTriangle,
      description: 'System error rate',
      color: 'text-red-500'
    }
  ];

  return (
    <div className="space-y-4">
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        {systemStats.map((stat, index) => {
          const Icon = stat.icon;
          return (
            <Card key={index}>
              <CardHeader className="flex flex-row items-center justify-between pb-2">
                <CardTitle className="text-sm font-medium">
                  {stat.name}
                </CardTitle>
                <Icon className={`h-4 w-4 ${stat.color}`} />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{stat.value}</div>
                <p className="text-xs text-muted-foreground">
                  {stat.description}
                </p>
              </CardContent>
            </Card>
          );
        })}
      </div>

      <Card className="col-span-4">
        <CardHeader>
          <CardTitle>System Performance</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="h-[400px]">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={performanceData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="time" />
                <YAxis yAxisId="left" />
                <YAxis yAxisId="right" orientation="right" />
                <Tooltip />
                <Legend />
                <Line 
                  yAxisId="left"
                  type="monotone" 
                  dataKey="latency" 
                  stroke="#2196F3" 
                  name="Latency (ms)"
                />
                <Line 
                  yAxisId="right"
                  type="monotone" 
                  dataKey="throughput" 
                  stroke="#4CAF50" 
                  name="Throughput (req/s)"
                />
                <Line 
                  yAxisId="right"
                  type="monotone" 
                  dataKey="errors" 
                  stroke="#f44336" 
                  name="Errors"
                />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </CardContent>
      </Card>
    </div>
  );
};

export default SystemMetrics;